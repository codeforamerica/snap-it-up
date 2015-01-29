require 'sinatra'
require 'net/https'
require 'uri'
require 'json'
require './lib/pingometer.rb'

PINGOMETER_USER = ENV['PINGOMETER_USER']
PINGOMETER_PASS = ENV['PINGOMETER_PASS']

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
  monitors.each do |monitor|
    # An event type of `-1` means a monitor is paused/non-operating.
    # For now, treat that like there's no monitor at all.
    if monitor['last_event']['type'] == -1
      next
    end
    
    name = monitor['name'].partition(' |')[0].downcase
    # We can have multiple monitors per state (e.g. California).
    # If any are down, we want to count all as down.
    if @state_status[name] != false
      @state_status[name] = monitor['last_event']['type'] != 0
    end
  end
  
  erb :index
end
