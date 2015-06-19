class ScreenshotEvent < Que::Job
  def run(event_id)
    event = PingometerEvent.find event_id

    ActiveRecord::Base.transaction do
      screenshot = event.build_screenshot
      screenshot.fetch
      screenshot.save!
      destroy
    end
  rescue => e
    # Don't rerun on error
    destroy
  end
end
