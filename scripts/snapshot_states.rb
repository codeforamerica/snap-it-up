# Snapshot a series of sites by state abbreviations or time zones.

require 'optparse'
require './app.rb'

states = []
time_zones = []
monitors = []

OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-s", "--states STATES", "List of states to snapshot, e.g. 'NY,MA'") do |state_list|
    states = state_list.split(",").collect {|item| item.strip.upcase}.uniq
  end
  
  opts.on("-tz", "--time-zones ZONES", "List of timezones in which to snapshot states, e.g. 'EST,CST'") do |zones|
    time_zones = zones.split(",").collect {|item| item.strip.upcase}.uniq
  end
end.parse!

MonitorList.each do |monitor_info|
  if states.include? monitor_info["state_abbreviation"]
    monitors << monitor_info
  elsif time_zones.any? {|zone| monitor_info["time_zone"].include? zone}
    monitors << monitor_info
  end
end

all_monitors = Pingometer.new(PINGOMETER_USER, PINGOMETER_PASS).monitors

monitors.each do |monitor_info|
  monitor = all_monitors.find {|monitor| monitor_hostname(monitor) == monitor_info["hostname"]}
  page_url = monitor_url(monitor)
  
  puts "Snapshotting #{page_url}"
  snapshot = nil
  begin
    snapshot = HTTParty.get("http://pagesnap.herokuapp.com/#{CGI.escape(page_url)}.png", :timeout => 20).parsed_response
  rescue
    snapshot = File.read("public/images/unreachable.png")
  end
  
  state_abbreviation = monitor_state(monitor)['state_abbreviation']
  state_status = monitor['last_event']['type'] != 0 ? "UP" : "DOWN"
  event_id = monitor['last_event']['id']
  file_name = "catalog/#{state_abbreviation}-#{monitor_info["id"]}-#{DateTime.now.iso8601}.png"
  save_snapshot(file_name, snapshot)
end
