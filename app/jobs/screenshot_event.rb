class ScreenshotEvent < Que::Job

  def run(event_id)
    event = PingometerEvent.find event_id

    ActiveRecord::Base.transaction do
      event.fetch_screenshot
      destroy
    end
  rescue ActiveRecord::RecordNotFound
    destroy # something was deleted, don't re-run the job
  end
end
