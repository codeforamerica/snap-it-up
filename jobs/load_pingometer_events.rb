class LoadPingometerEvents
  def self.perform(monitor_id=nil)
    self.new.perform(monitor_id)
  end 
  
  def perform(monitor_id=nil)
    monitor_log = monitor_id ? " for #{monitor_id}" : ""
    puts "Loading events from Pingometer#{monitor_log}"

    @monitor_id = monitor_id
    load_events
    create_incidents
  end
  
  def client
    @client ||= Pingometer.new(PINGOMETER_USER, PINGOMETER_PASS)
  end
  
  def monitors
    @monitors ||= @monitor_id ? [client.monitor(@monitor_id)] : client.monitors
  end
  
  def load_events
    with_new_events = monitors.find_all &method(:load_monitor_events)
    with_new_events.each do |monitor|
      Qu.enqueue(SnapshotMonitor, monitor['id'])
    end
  end
  
  def load_monitor_events(monitor)
    puts "  Loading events for #{monitor['id']}"
    
    state_abbreviation = monitor_state(monitor)['state_abbreviation']
    
    new_events = false
    client.events(monitor).each do |event|
      model = MonitorEvent.from_pingometer(event, monitor['id'], state_abbreviation)
      if !MonitorEvent.where(monitor: model.monitor, date: model.date).exists?
        model.save
        new_events = true
      end
    end
    
    new_events
  end
  
  def create_incidents
    monitors.each &method(:create_monitor_incidents)
  end
  
  def create_monitor_incidents(monitor)
    puts "  Creating incidents for #{monitor['id']}"
    
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
end
