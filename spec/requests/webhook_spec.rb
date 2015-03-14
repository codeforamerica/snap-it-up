require 'rails_helper'

RSpec.describe 'Pingometer Webhook', type: :request do
  it 'is persisted appropriately in the database' do
    monitor_id = 'b74014410cc1236a3d0h7400'

    pingometer_data = {
      monitor_id: monitor_id,
      monitor_host: 'pingometer.com',
      monitor_status: 'down' # or 'up'
    }
    post '/hooks/event', pingometer_data.to_json, format: :json
    expect(response).to be_success

    # WebServices should found or be created if they don't exist
    web_service = WebService.find_by_pingometer_id monitor_id
    expect(web_service).to exist

    # A webservice without an open incident should result in
    # the creation of a new incident
    incident = webservice.most_recent_monitor_incident
    expect(incident).to be_a MonitorIncident
    expect(incident.open?).to eq true

    # Incidents should have Events
    event = incident.monitor_events.first
    expect(event.status).to eq 'down'

    # TODO: ensure screenshot takes place

    # Subsequent down events should spool onto the existing open incident
    pingometer_data = {
      monitor_id: monitor_id,
      monitor_host: 'pingometer.com',
      monitor_status: 'down' # or 'up'
    }
    post '/hooks/event', pingometer_data.to_json, format: :json

    # Ensure no new incidents have been created
    web_service.reload!
    expect(webservice.incidents.count).to eq 1

    # Ensure that the incident's new event has been attached
    # and the incident remains open
    incident.reload!
    expect(incident.monitor_events.count).to eq 2
    expect(incident.open?).to eq true

    # An up event will attach to the incident and close it
    pingometer_data = {
      monitor_id: monitor_id,
      monitor_host: 'pingometer.com',
      monitor_status: 'up' # or 'up'
    }
    post '/hooks/event', pingometer_data.to_json, format: :json

    # Ensure no new incidents have been created
    web_service.reload!
    expect(webservice.incidents.count).to eq 1

    # Ensure that the incident's new event has been attached
    # and that the incident has been closed
    incident.reload!
    expect(incident.monitor_events.count).to eq 3
    expect(incident.open?).to eq false

    # Supsequent up events with no open incidents are discarded
    pingometer_data = {
      monitor_id: monitor_id,
      monitor_host: 'pingometer.com',
      monitor_status: 'up' # or 'up'
    }
    post '/hooks/event', pingometer_data.to_json, format: :json

    expect(Incident.count).to eq 3
  end
end
