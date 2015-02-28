require './app.rb'

namespace :pingometer do
  desc 'Load all events from Pingometer and save them locally in the database.'
  task :load_events, [:monitor] do |t, args|
    PingClient = Pingometer.new(PINGOMETER_USER, PINGOMETER_PASS)
    
    def load_monitor(monitor)
      puts "Loading events for #{monitor['id']}"
      
      state_abbreviation = monitor_state(monitor)['state_abbreviation']
      
      PingClient.events(monitor).each do |event|
        # It's almost ISO8601, except it's missing the time zone :(
        # Hopefully Pingometer will fix this, so be future proof by trying to parse before fixing.
        event_time = Time.parse(event['utc_timestamp'])
        if !event_time.utc?
          event_time = Time.parse("#{event['utc_timestamp']}Z")
        end
        
        found = DB["monitor_events"].find_one({
          monitor: monitor['id'],
          date: event_time
        })
        
        if !found
          DB["monitor_events"].insert({
            state: state_abbreviation,
            monitor: monitor['id'],
            status: event['type'],
            date: event_time
          })
        end
      end
    end
    
    if args[:monitor]
      monitor = PingClient.monitor(args[:monitor])
      load_monitor(monitor)
    else
      monitors = PingClient.monitors
      monitors.each do |monitor|
        load_monitor(monitor)
      end
    end
  end
end
