# == Schema Information
#
# Table name: pingometer_events
#
#  id           :integer          not null, primary key
#  incident_id  :integer
#  status       :string
#  triggered_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_pingometer_events_on_incident_id  (incident_id)
#

class PingometerEvent < ActiveRecord::Base
  belongs_to :incident
  has_one :screenshot

  validates :status, inclusion: { in: ['down', 'up'] }

  def build_screenshot
    super.tap do |screenshot|
      screenshot.pingometer_monitor = incident.pingometer_monitor
    end
  end
end
