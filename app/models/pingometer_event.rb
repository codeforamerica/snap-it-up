# == Schema Information
#
# Table name: pingometer_events
#
#  id            :integer          not null, primary key
#  incident_id   :integer
#  status        :string
#  triggered_at  :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  screenshot_id :string
#  screenshot_at :datetime
#
# Indexes
#
#  index_pingometer_events_on_incident_id  (incident_id)
#

class PingometerEvent < ActiveRecord::Base
  belongs_to :incident
  attachment :screenshot

  validates :status, inclusion: { in: ['down', 'up'] }

  def fetch_screenshot
    monitor = incident.pingometer_monitor

    self.screenshot = Browserstack.screenshot monitor.url
    self.screenshot_at = DateTime.now
    save!
  end
end
