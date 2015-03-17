# == Schema Information
#
# Table name: monitor_incidents
#
#  id                    :integer          not null, primary key
#  pingometer_monitor_id :integer
#  started_at            :datetime
#  finished_at           :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_monitor_incidents_on_pingometer_monitor_id  (pingometer_monitor_id)
#

class MonitorIncident < ActiveRecord::Base
  belongs_to :web_service
  has_many :monitor_events

  def open?
    finished_at.nil?
  end
end
