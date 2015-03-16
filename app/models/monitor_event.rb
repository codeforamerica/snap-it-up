# == Schema Information
#
# Table name: monitor_events
#
#  id                  :integer          not null, primary key
#  monitor_incident_id :integer
#  status              :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  triggered_at        :datetime         not null
#  screenshot_id       :string
#  screenshot_at       :datetime
#
# Indexes
#
#  index_monitor_events_on_monitor_incident_id  (monitor_incident_id)
#

class MonitorEvent < ActiveRecord::Base
  belongs_to :monitor_incident
  attachment :screenshot

  validates :status, inclusion: { in: ['down', 'up'] }

  def fetch_screenshot
    web_service = monitor_incident.web_service

    self.screenshot = Browserstack.screenshot web_service.monitor_url
    self.screenshot_at = DateTime.now
    save!
  end
end
