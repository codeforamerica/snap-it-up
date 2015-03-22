# == Schema Information
#
# Table name: screenshots
#
#  id                    :integer          not null, primary key
#  pingometer_monitor_id :integer
#  pingometer_event_id   :integer
#  image_id              :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_screenshots_on_pingometer_event_id    (pingometer_event_id)
#  index_screenshots_on_pingometer_monitor_id  (pingometer_monitor_id)
#

class Screenshot < ActiveRecord::Base
  belongs_to :pingometer_monitor
  belongs_to :pingometer_event

  attachment :image

  validates :image, presence: true

  def fetch
    self.image = Browserstack.screenshot pingometer_monitor.url
    save!
  end

  def pingometer_event=(event)
    super(event)
    self.pingometer_monitor = event.incident.pingometer_monitor
    event
  end
end
