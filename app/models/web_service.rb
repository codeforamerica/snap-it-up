# == Schema Information
#
# Table name: web_services
#
#  id            :integer          not null, primary key
#  pingometer_id :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class WebService < ActiveRecord::Base
  has_many :monitor_incidents

  has_one :open_monitor_incident, -> { where(finished_at: nil).includes(:monitor_events).limit(1) }, class_name: 'MonitorIncident'
end
