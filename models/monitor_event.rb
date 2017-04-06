class MonitorEvent < ActiveRecord::Base
  belongs_to :incident, inverse_of: :events
  has_many :snapshots, foreign_key: 'event_id', inverse_of: :event
  
  # NOTE: the `pingometer_id` field will often not be filled in because it was,
  # until recently, available only for the latest event in Pingometer's API.
  
  # The `accepted` field represents whether an event should be considered. Some
  # monitors are known to have been incorrectly configured during certain time
  # periods -- we want to collect all event data, but mark event from those
  # time periods as not accepted.
  # TODO: only include accepted events in the default scope?
  
  default_scope { order(:date) }
  
  def self.latest
    self.last
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
  
  def in_date_range?(start_date, end_date)
    self.date >= start_date && self.date <= end_date
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
