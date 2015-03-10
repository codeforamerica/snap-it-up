class Incident
  include Mongoid::Document
  
  field :monitor, type: String
  field :state, type: String
  field :start_date
  field :end_date
  field :events, type: Array  # of BSON IDs
  field :milliseconds
end
