require 'rails_helper'

RSpec.describe 'Pingometer Webhook', type: :request do
  before :each do
    ActionController::Base.allow_forgery_protection = true
  end

  after :each do
    ActionController::Base.allow_forgery_protection = false
  end

  it 'is persisted appropriately in the database' do
    monitor_id = 'b74014410cc1236a3d0h7400'

    # Expect a pre-existing monitor
    monitor = PingometerMonitor.create pingometer_id: monitor_id,
      raw_data: {
        'hostname': 'test.com'
      }

    # Expect a screenshot
    expect(Browserstack).to receive(:screenshot) {
      File.new(Rails.root.join('spec', 'fixtures', 'screenshot.png'), 'r')
    }.at_least(:once)

    stub_request(:get, %r(https://.*app.pingometer.com/api/v1.0/monitor/b74014410cc1236a3d0h7400))
      .to_return(status: 200, body: {
        "monitor" => [{
          "hostname": "test.com",
          "last_event" => {
            "id"=>"54fb515919ad89639917ebe9",
            "type"=>1,
            "utc_timestamp"=>"2015-03-07T19:28:25.250000+00:00"
          },
        }]
      }.to_json, headers: {'Content-Type' => 'application/json'})

    pingometer_data = {
      monitor_id: monitor_id,
      monitor_host: 'pingometer.com',
      monitor_status: 'down',
      utc_timestamp: '2015-03-10T13:13:19' # Pingometer uses ISO8601 but without the Z
    }

    post '/pingometer/webhook', pingometer_data.to_json, 'Content-Type' => 'application/json'
    expect(response).to be_success

    # WebServices should found or be created if they don't exist
    # monitor = WebService.find_by_pingometer_id monitor_id
    # expect(monitor).to_not be_nil

    # A webservice without an open incident should result in
    # the creation of a new incident
    incident = monitor.open_incident
    expect(incident).to be_an Incident
    expect(incident.open?).to eq true

    # Incidents should have Events
    event = incident.pingometer_events.first
    expect(event).to be_a PingometerEvent
    expect(event.status).to eq 'down'

    # Events should have screenshots
    screenshot = event.screenshot
    expect(screenshot).to be_a Screenshot
    expect(screenshot.image).to_not be_nil

    # TODO: ensure screenshot takes place

    # Subsequent down events should spool onto the existing open incident
    pingometer_data = {
      monitor_id: monitor_id,
      monitor_host: 'pingometer.com',
      monitor_status: 'down',
      utc_timestamp: '2015-03-10T13:14:19'
    }
    post '/pingometer/webhook', pingometer_data.to_json, 'Content-Type' => 'application/json'

    # Ensure no new incidents have been created
    monitor.reload
    expect(monitor.incidents.count).to eq 1

    # Ensure that the incident's new event has been attached
    # and the incident remains open
    incident.reload
    expect(incident.pingometer_events.count).to eq 2
    expect(incident.open?).to eq true

    # An up event will attach to the incident and close it
    pingometer_data = {
      monitor_id: monitor_id,
      monitor_host: 'pingometer.com',
      monitor_status: 'up',
      utc_timestamp: '2015-03-10T13:16:19'
    }
    post '/pingometer/webhook', pingometer_data.to_json, 'Content-Type' => 'application/json'

    # Ensure no new incidents have been created
    monitor.reload
    expect(monitor.incidents.size).to eq 1

    # Ensure that the incident's new event has been attached
    # and that the incident has been closed
    incident.reload
    expect(incident.pingometer_events.size).to eq 3
    expect(incident.open?).to eq false

    # Supsequent up events with no open incidents are discarded
    pingometer_data = {
      monitor_id: monitor_id,
      monitor_host: 'pingometer.com',
      monitor_status: 'up',
      utc_timestamp: '2015-03-10T13:17:19'
    }
    post '/pingometer/webhook', pingometer_data.to_json, 'Content-Type' => 'application/json'

    incident.reload
    expect(incident.pingometer_events.size).to eq 3
  end
end
