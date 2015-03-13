class MonitorIncident < ActiveRecord::Base
  belongs_to :web_service
  has_many :monitor_events
end
