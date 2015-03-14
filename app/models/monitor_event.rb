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
#
# Indexes
#
#  index_monitor_events_on_monitor_incident_id  (monitor_incident_id)
#

class MonitorEvent < ActiveRecord::Base
  belongs_to :monitor_incident

  validates :subdomain, inclusion: { in: ['down', 'up'] }

  def self.pingometer_time(timestamp)
    # It's almost ISO8601, except it's missing the time zone :(
    # Hopefully Pingometer will fix this, so be future proof by trying to parse before fixing.
    time = Time.parse(timestamp)
    if !time.utc?
      time = Time.parse("#{timestamp}Z")
    end
    time
  end
end
