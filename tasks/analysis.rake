namespace :analysis do
  desc 'Create incidents (timeframes a site was down) based on monitor events.'
  task :create_incidents, [:monitor] do |t, args|
    def create_incidents_for(monitor)
      puts "Creating incidents for #{monitor['id']}"
      
      # Roll through events in date order and create incidents representing consecutive series of down events
      # NOTE: a lot the ifs here are necessary because sometimes we have consecutive up or down events :\
      incident = nil
      MonitorEvent.where(monitor: monitor['id']).sort({date: 1}).each do |event|
        if event.status == 0
          # TODO: skip all the everything if we find an existing incident with an end_date
          incident ||= Incident.find_or_initialize_by(monitor: event.monitor, start_date: event.date)
          incident.add_event(event)
        else
          if incident
            incident.add_event(event)
            incident.save
            incident = nil
          end
        end
      end
      
      # We got to the end with an ongoing incident
      if incident
        incident.save
      end
    end

    PingClient = Pingometer.new(PINGOMETER_USER, PINGOMETER_PASS)
    if args[:monitor]
      monitor = PingClient.monitor(args[:monitor])
      create_incidents_for(monitor)
    else
      monitors = PingClient.monitors
      monitors.each do |monitor|
        create_incidents_for(monitor)
      end
    end
  end
end
