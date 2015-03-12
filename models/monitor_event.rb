class MonitorEvent
  include Mongoid::Document
  
  # pingometer_id will often not be filled in because it was, until recently,
  # available only for the latest event in Pingometer's API.
  field :pingometer_id, type: String
  
  field :monitor, type: String
  field :status, type: Integer
  field :date
  field :state, type: String
  
  def up?
    status != 0
  end
end
