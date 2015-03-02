namespace :s3 do
  desc 'Load snapshots metadata and save in local DB.'
  task :load_snapshots do |t|
    db_events = DB["monitor_events"]
    db_snapshots = DB["snapshots"]
    
    s3 = Aws::S3::Resource.new
    s3.bucket(AWS_BUCKET).objects.each do |snapshot|
      # Check whether we already have data for this snapshot
      snapshot_data = db_snapshots.find_one(:name => snapshot.key)
      if snapshot_data && snapshot_data["event_id"]
        next
      end
      
      # If not, start parsing metadata
      info = /^(\w\w)-(\w+)-(?:(UP|DOWN)-)?([^\.]+)(?:\.png)?$/.match(snapshot.key)
      if !info.nil?
        state = info[1]
        monitor_id = info[2]
        pingometer_event_id = info[4]
        begin
          date = Time.parse(pingometer_event_id)
          pingometer_event_id = nil
        rescue
          date = snapshot.last_modified
        end
        
        # Try to find the appropriate event if we can
        # 1. By pingometer event ID. Not present on old data :(
        # 2. By exact date + monitor match
        # 3. By most recent event to snapshot date + monitor match
        monitor_event = nil
        if pingometer_event_id
          monitor_event = db_events.find_one("pingometer_id" => pingometer_event_id)
        end
        if !monitor_event
          monitor_event = db_events.find_one("date" => date, "monitor" => monitor_id)
        end
        if !monitor_event
          # otherwise find the closest date...
          monitor_event = db_events.find(:date => {"$lte" => date}, "monitor" => monitor_id).sort(:date => :desc).first
        end
        
        if !monitor_event
          puts "Couldn't find event corresponding to #{snapshot.key}"
        else
          db_data = {
            state: state,
            monitor: monitor_id,
            status: monitor_event["status"] != 0 ? "UP" : "DOWN",
            event_id: monitor_event["_id"],
            event_pingometer_id: pingometer_event_id,
            date: date,
            name: snapshot.key,
            url: snapshot.object.public_url,
          }
          if snapshot_data
            db_snapshots.update({"_id" => snapshot_data["_id"]}, db_data)
          else
            db_snapshots.insert(db_data)
          end
        end
      end
    end
  end
end
