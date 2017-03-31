class SnapshotMonitor
  def self.perform(monitor_id)
    self.new.perform(monitor_id)
  end
  
  def perform(monitor_id)
    puts "Snapshotting #{monitor_id}"
    
    begin
      monitor = Pingometer.new(PINGOMETER_USER, PINGOMETER_PASS).monitor(monitor_id)
    rescue
      # FIXME: should got to stdout
      puts "  Failed getting info on monitor #{monitor_id} from Pingometer"
      return
    end
    
    page_url = monitor_url(monitor)
    state_abbreviation = monitor_state(monitor)['state_abbreviation']
    last_event = MonitorEvent.where(monitor: monitor_id).latest
    state_status = last_event.up? ? "UP" : "DOWN"
    file_name = "#{state_abbreviation}-#{monitor_id}-#{state_status}-#{last_event.pingometer_id}.png"
    url = save_snapshot(file_name, take_snapshot(page_url))
  
    Snapshot.create(
      state: state_abbreviation,
      monitor: monitor_id,
      status: state_status,
      event_id: last_event.id,
      date: Time.now,
      name: file_name,
      url: url
    )
  
    puts "  Snapshot saved: #{file_name}, #{url}"
  end
  
  def take_snapshot(url)
    begin
      Snapshotter.snapshot url
    rescue Net::OpenTimeout
      File.read("public/images/unreachable.png")
    end
  end
end
