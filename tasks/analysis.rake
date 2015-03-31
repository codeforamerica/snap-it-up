namespace :analysis do
  desc 'Create incidents (timeframes a site was down) based on monitor events.'
  task :create_incidents, [:monitor] do |t, args|
    def create_incidents_for(monitor)
      puts "Creating incidents for #{monitor['id']}"
      
      # Roll through events in date order and create incidents representing consecutive series of down events
      # NOTE: a lot the ifs here are necessary because sometimes we have consecutive up or down events :\
      incident = nil
      MonitorEvent.where(monitor: monitor['id']).each do |event|
        if !event.up?
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
  
  desc 'Accept/reject events/incidents based on monitors JSON metadata'
  task :accept_events, [:monitor] do |t, args|
    def accept_for(monitor)
      puts "Accept/rejecting incidents for #{monitor['id']}"
      monitor_meta = MonitorList.find {|monitor_meta| monitor_meta["hostname"] == monitor_hostname(monitor)}
      if monitor_meta['ignore_dates']
        monitor_meta['ignore_dates'].each do |dates|
          start_date = (dates[0] && dates[0].to_time) || Time.new(2000, 1, 1)
          end_date = (dates[1] && dates[1].to_time) || Time.new(3000, 1, 1)
          
          # TODO: should probably be built into the event model
          MonitorEvent.where(:monitor => monitor['id'], :date.gte => start_date, :date.lte => end_date).each do |event|
            event.accepted = false
            event.save
          end
          
          # TODO: should probably be built into the incident model
          Incident.where(monitor: monitor['id']).intersecting(start_date, end_date).each do |incident|
            incident.accepted = false
            incident.save
          end
        end
      end
    end
    
    PingClient = Pingometer.new(PINGOMETER_USER, PINGOMETER_PASS)
    if args[:monitor]
      monitor = PingClient.monitor(args[:monitor])
      accept_for(monitor)
    else
      monitors = PingClient.monitors
      monitors.each do |monitor|
        accept_for(monitor)
      end
    end
  end
end
