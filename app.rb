require 'sinatra'
require 'sinatra/content_for'
require 'net/https'
require 'uri'
require 'json'
require 'fileutils'
require './lib/pingometer.rb'
require './lib/pagesnap.rb'
require './lib/browserstack.rb'
require 'aws-sdk'
require 'httparty'
require 'mongoid'
require 'qu-mongoid'
require './models/monitor_event.rb'
require './models/snapshot.rb'
require './models/incident.rb'
require './jobs/load_pingometer_events.rb'
require './jobs/snapshot_monitor.rb'

PINGOMETER_USER = ENV['PINGOMETER_USER']
PINGOMETER_PASS = ENV['PINGOMETER_PASS']
AWS_KEY = ENV['AWS_KEY']
AWS_SECRET = ENV['AWS_SECRET']
AWS_BUCKET = ENV['AWS_BUCKET']
AWS_REGION = ENV['AWS_REGION']
PRODUCTION = ENV['RACK_ENV'] == 'production'
MONGO_URI = ENV['MONGO_URI'] || ENV['MONGOLAB_URI'] || "mongodb://localhost:27017/snap_it_up"
PAGESNAP_URL = ENV['PAGESNAP_URL']
BROWSERSTACK_USER = ENV['BROWSERSTACK_USER']
BROWSERSTACK_KEY = ENV['BROWSERSTACK_KEY']
USE_WEBHOOK = (ENV['USE_WEBHOOK'] || '').downcase == 'true'

configure do
  Mongoid.configure do |config|
    config.sessions = { 
      :default => {
        :uri => MONGO_URI
      }
    }
  end
end

Aws.config.merge!({
  credentials: Aws::Credentials.new(AWS_KEY, AWS_SECRET),
  region: AWS_REGION || 'us-east-1'
})

if BROWSERSTACK_USER && BROWSERSTACK_KEY
  Snapshotter = Browserstack.new(BROWSERSTACK_USER, BROWSERSTACK_KEY)
else
  Snapshotter = PageSnap.new(PAGESNAP_URL)
end

MonitorList = JSON.parse(File.read('public/data/pingometer_monitors.json'))

get '/' do
  # Get all states into a hash
  @state_status = Hash[MonitorList.collect {|meta| [meta["state_abbreviation"], true]}]
  
  # mark current incidents as down
  Incident.current.each do |incident|
    @state_status[incident.state] = false
  end
  
  now = Time.now
  week_ago = (now.utc.to_date - 6.days).to_time
  week_ago = week_ago + week_ago.utc_offset
  @state_week_uptime = state_uptimes_between(week_ago, now)
  
  erb :index
end

get '/states/:state_abbreviation' do
  state_abbreviation = params[:state_abbreviation].downcase
  monitors = MonitorList.find_all {|monitor_info| monitor_info["state_abbreviation"].downcase == state_abbreviation}
  if monitors.empty?
    monitor = MonitorList.find {|monitor_info| monitor_info["state"].downcase == state_abbreviation}
    if monitor
      redirect "/states/#{monitor['state_abbreviation']}"
    else
      raise Sinatra::NotFound
    end
    return
  end
  
  state = monitors[0]["state"]
  snapshots = Snapshot.where(state: state_abbreviation.upcase).sort(date: -1)
  
  begin
    all_monitors = Pingometer.new(PINGOMETER_USER, PINGOMETER_PASS).monitors
  rescue
    @error_message = "Our status monitoring system, Pingometer, appears to be having problems."
    return erb :error
  end
  
  monitors_data = []
  all_monitors.each do |monitor_data|
    meta = monitors.find {|monitor| monitor["hostname"] == monitor_hostname(monitor_data)}
    if meta
      monitor_snaps = snapshots.find_all {|snapshot| snapshot.name.start_with? "#{state_abbreviation.upcase}-#{monitor_data['id']}"}
      monitors_data << {
        :name => monitor_data["name"],
        :url => monitor_url(monitor_data),
        :status => monitor_data['last_event']['type'] == -1 ? :unknown : (monitor_data['last_event']['type'] == 0 ? :down : :up),
        :meta => meta,
        :details => monitor_data,
        :snapshots => monitor_snaps,
        :snapshots_up => monitor_snaps.find_all {|snapshot| snapshot.status == "UP" },
        :snapshots_down => monitor_snaps.find_all {|snapshot| snapshot.status != "UP" }
      }
    end
  end
  
  erb :state, {:locals => {
    state: state,
    monitors: monitors_data
  }}
end

post '/hooks/event' do
  content_type :json
  
  if !USE_WEBHOOK
    logger.info "IGNORING event hook for monitor #{params[:monitor_id]}"
    status 501
    return { error: "Webhooks are currently ignored." }.to_json
  end
  
  logger.info "Received event hook for monitor #{params[:monitor_id]}"
  
  if !params[:monitor_id]
    status 400
    return { error: "No `monitor_id` included in POST." }.to_json
  end
  
  begin
    monitor = Pingometer.new(PINGOMETER_USER, PINGOMETER_PASS).monitor(params[:monitor_id])
  rescue
    logger.error "Failed getting info on monitor #{params[:monitor_id]} from Pingometer"
    status 500
    return { error: "Our status monitoring system, Pingometer, appears to be having problems." }.to_json
  end
  
  state_abbreviation = monitor_state(monitor)['state_abbreviation']
  
  local_event = MonitorEvent.create_from_pingometer(monitor['last_event'], params[:monitor_id], state_abbreviation)
  
  # Update incidents
  last_incident = Incident.where(monitor: params[:monitor_id]).current.first || Incident.new
  last_incident.add_event(local_event)
  last_incident.save
  
  Qu.enqueue(SnapshotMonitor, params[:monitor_id])
  
  return { message: "Event saved." }.to_json
end

# Kind of hacky thing to get an ensured hostname
# (transactional tests don't have hostnames, so get the hostname of the URL it first loads).
# Not in Pingometer API class because there's not a real generic solution to this. (Or should it be?)
def monitor_hostname(monitor)
  monitor['hostname'].empty? ? monitor['commands']['1']['get'].match(/^[^\/]+\/\/([^\/]*)/)[1] : monitor['hostname']
end

def monitor_state(monitor)
  MonitorList.find {|monitor_info| monitor_info['hostname'] == monitor_hostname(monitor)}
end

def monitor_url(monitor)
  if monitor["hostname"] && !monitor["hostname"].empty?
    protocol = monitor['type'] && !monitor['type'].empty? ? monitor["type"] : "http"
    host = monitor["hostname"]
    path = monitor["path"] || ""
    query = monitor["querystring"] && !monitor["querystring"].empty? ? "?#{monitor["querystring"]}" : ""
    
    "#{protocol}://#{host}#{path}#{query}"
  else
    monitor["commands"]["1"]["get"]
  end
end

def save_snapshot(name, data)
  if PRODUCTION
    s3 = Aws::S3::Resource.new
    s3.bucket(AWS_BUCKET).object(name).put(
      body: data,
      acl: "public-read",
      content_type: "image/png")
    s3.bucket(AWS_BUCKET).object(name).public_url
  else
    Dir.mkdir("./tmp") unless File.exist?("./tmp")
    if !File.exist?(File.dirname("./tmp/#{name}"))
      FileUtils.mkdir_p(File.dirname("./tmp/#{name}"))
    end
    File.open("./tmp/#{name}", "w") do |file|
      file << data
    end
    nil
  end
end

def state_uptimes_between(t1, t2)
  # Get incidents over a time period, trimmed to the time period
  incidents = Incident.or(
    {:start_date.lte => t2, :end_date.gte => t1},
    {:start_date => nil, :end_date.gte => t1},
    {:start_date.lte => t2, :end_date => nil}
  ).collect do |incident|
    if incident.start_date.nil? || incident.start_date < t1
      incident.start_date = t1
    end
    if incident.end_date.nil? || incident.end_date > t2
      incident.end_date = t2
    end
    incident
  end
  
  # Group by state and calculate uptime for each.
  timeframe = t2 - t1
  uptimes = Hash[MonitorList.collect {|meta| [meta["state_abbreviation"], 100]}]
  incidents.group_by {|incident| incident.state}.each do |state, incidents|
    downtimes = incidents.group_by {|incident| incident.monitor}.collect do |monitor, incidents|
      incidents.inject(0) {|downtime, incident| downtime + (incident.end_date - incident.start_date)}
    end
    downtime = downtimes.max
    uptimes[state] = 100 * (timeframe - downtime) / timeframe
  end
  
  uptimes
end
