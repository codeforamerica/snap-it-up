namespace :pingometer do
  desc 'Load all events from Pingometer and save them locally in the database.'
  task :load_events, [:monitor] do |t, args|
    PingClient = Pingometer.new(PINGOMETER_USER, PINGOMETER_PASS)
    
    def load_monitor(monitor)
      puts "Loading events for #{monitor['id']}"
      
      state_abbreviation = monitor_state(monitor)['state_abbreviation']
      
      PingClient.events(monitor).each do |event|
        model = MonitorEvent.from_pingometer(event, monitor['id'], state_abbreviation)
        if !MonitorEvent.where(monitor: model.monitor, date: model.date).exists?
          model.save
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
