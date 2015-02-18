require 'sinatra'
require 'net/https'
require 'uri'
require 'json'
require './lib/pingometer.rb'
require 'aws-sdk'
require 'httparty'

PINGOMETER_USER = ENV['PINGOMETER_USER']
PINGOMETER_PASS = ENV['PINGOMETER_PASS']
AWS_KEY = ENV['AWS_KEY']
AWS_SECRET = ENV['AWS_SECRET']
AWS_BUCKET = ENV['AWS_BUCKET']
AWS_REGION = ENV['AWS_REGION']

Aws.config.merge!({
  credentials: Aws::Credentials.new(AWS_KEY, AWS_SECRET),
  region: AWS_REGION || 'us-east-1'
})

MonitorList = JSON.parse(File.read('public/data/pingometer_monitors.json'))

get '/' do
  # Get basic info on all monitors.
  begin
    monitors = Pingometer.new(PINGOMETER_USER, PINGOMETER_PASS).monitors
  rescue
    @error_message = "Our status monitoring system, Pingometer, appears to be having problems."
    return erb :error
  end
  
  @down = monitors
    .select {|monitor| monitor['last_event']['type'] == 0}
    .map {|monitor| monitor['name'].partition(' |')[0].downcase}
  
  @state_status = {}
  @state_week_uptime = {}
  encounters = Hash.new(0)
  
  monitors.each do |monitor|
    # An event type of `-1` means a monitor is paused/non-operating.
    # For now, treat that like there's no monitor at all.
    if monitor['last_event']['type'] == -1
      next
    end
    
    state = monitor_state(monitor)['state'].downcase
    # We can have multiple monitors per state (e.g. California).
    # If any are down, we want to count all as down.
    if @state_status[state] != false
      @state_status[state] = monitor['last_event']['type'] != 0
    end
    
    days_checked = 0
    # NOTE: no straightforward way to get the UTC date, so we convert a Time object :\
    today = Time.now.utc.to_date
    total_uptime = ((today - 6)..today).reduce(0) do |sum, date|
      date_data = monitor['reports']['raw'][date.strftime('%Y-%m-%d')]
      if date_data
        days_checked += 1
        sum += date_data['uT']
      end
      sum
    end
    week_uptime = days_checked > 0 ? (total_uptime / days_checked) : 0
    if encounters[state] > 0
      week_uptime = (@state_week_uptime[state] * encounters[state] + week_uptime) / (encounters[state] + 1)
    end
    @state_week_uptime[state] = week_uptime

    encounters[state] += 1
  end
  
  erb :index
end

post '/hooks/event' do
  content_type :json
  
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
  
  page_url = monitor_url(monitor)
  
  logger.info "Snapshotting #{page_url}"
  snapshot = nil
  begin
    snapshot = HTTParty.get("http://pagesnap.herokuapp.com/#{CGI.escape(page_url)}.png", :timeout => 20).parsed_response
  rescue
    snapshot = File.read("public/images/unreachable.png")
  end
  
  state_abbreviation = monitor_state(monitor)['state_abbreviation']
  s3_name = "#{state_abbreviation}-#{params[:monitor_id]}-#{DateTime.now.iso8601}.png"
  s3 = Aws::S3::Resource.new
  s3.bucket(AWS_BUCKET).object(s3_name).put(
    body: snapshot,
    acl: "public-read",
    content_type: "image/png")
  
  logger.info "Snapshot uploaded to S3: #{s3_name}"
  
  return { url: "http://pagesnap.herokuapp.com/#{CGI.escape(page_url)}.png" }.to_json
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
