namespace :analysis do
  desc 'Create incidents (timeframes a site was down) based on monitor events.'
  task :create_incidents, [:monitor] do |t, args|
    def create_incidents_for(monitor)
      puts "Creating incidents for #{monitor['id']}"
      
      # Roll through events in date order and create incidents representing consecutive series of down events
      incident = nil
      DB["monitor_events"].find({"monitor" => monitor["id"]}).sort({date: 1}).each do |event|
        if event["status"] == 0
          if incident
            incident["events"] << event["_id"]
          else
            incident = {
              "monitor" => event["monitor"],
              "state" => event["state"],
              "start_date" => event["date"],
              "end_date" => nil,
              "events" => [event["_id"]]
            }
          end
        else
          if incident
            incident["events"] << event["_id"]
            incident["end_date"] = event["date"]
            incident["milliseconds"] = ((incident["end_date"] - incident["start_date"]) * 1000).round
            DB["incidents"].update({monitor: incident["monitor"], start_date: incident["start_date"]}, incident, {upsert: true})
            incident = nil
          end
        end
      end
      
      if incident
        DB["incidents"].update({monitor: incident["monitor"], start_date: incident["start_date"]}, incident, {upsert: true})
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
