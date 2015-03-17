class PingometerController < ApplicationController
  def webhook
    monitor = PingMonitor.find_or_create_by! pingometer_id: webhook_params[:monitor_id]
    open_incident = web_service.open_monitor_incident

    # refresh the Monitor data, which holds the data for last_event
    monitor.fetch

    event_data = monitor.last_event_data
    timestamp = DateTime.parse event_data['utc_timestamp']

    if webhook_params[:monitor_status] == 'down'
      unless open_incident
        open_incident = monitor.monitor_incidents.create! started_at: timestamp
      end

      event = open_incident.monitor_events.create! status: webhook_params[:monitor_status],
        triggered_at: timestamp
      ScreenshotEvent.enqueue event.id

    elsif webhook_params[:monitor_status] == 'up'
      if open_incident
        event = open_incident.monitor_events.create! status: webhook_params[:monitor_status],
          triggered_at: timestamp
        ScreenshotEvent.enqueue event.id

        open_incident.update! finished_at: timestamp
      end
    end

    render json: { '200' => 'Ok' }
  end

  private

  def webhook_params
    post_params = params.require(:pingometer).permit :monitor_id, :monitor_status, :utc_timestamp
    post_params.require(:monitor_id)
    post_params.require(:monitor_status)
    post_params.require(:utc_timestamp)
    post_params
  end
end
