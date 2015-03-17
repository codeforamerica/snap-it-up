# == Schema Information
#
# Table name: incidents
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
#  index_incidents_on_pingometer_monitor_id  (pingometer_monitor_id)
#

class Incident < ActiveRecord::Base
  belongs_to :pingometer_monitor
  has_many :pingometer_events

  def open?
    finished_at.nil?
  end
end
