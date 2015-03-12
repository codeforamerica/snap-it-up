class Snapshot
  include Mongoid::Document
  
  field :monitor, type: String
  
  # FIXME: This is "UP" or "DOWN", which is basically idiotic given that we
  # have 0/1/[status code] for events. Should fix.
  field :status, type: String
  
  field :event_id, type: BSON::ObjectId
  field :event_pingometer_id, type: String
  field :date
  field :name, type: String
  field :url, type: String
  field :state, type: String
end
