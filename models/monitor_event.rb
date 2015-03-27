class MonitorEvent
  include Mongoid::Document
  
  # pingometer_id will often not be filled in because it was, until recently,
  # available only for the latest event in Pingometer's API.
  field :pingometer_id, type: String
  
  field :monitor, type: String
  field :status, type: Integer
  field :date
  field :state, type: String
  
  default_scope ->{ order({date: 1}) }
  
  def self.latest
    self.order({date: -1}).first
  end
  
  def self.from_pingometer(pingometer_event, monitor=nil, state=nil)
    self.new(
      status: pingometer_event['type'],
      date: self.pingometer_time(pingometer_event['utc_timestamp']),
      pingometer_id: pingometer_event['id'],
      monitor: monitor,
      state: state
    )
  end
  
  def self.create_from_pingometer(*args)
    event = self.from_pingometer(*args)
    event.save
    event
  end
  
  def up?
    status != 0
  end
  
  protected
  
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
