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

  validates :status, inclusion: { in: ['down', 'up'] }
end
