class Incident < ActiveRecord::Base
  has_many :events, class_name: 'MonitorEvent', inverse_of: :incident
  
  # The `accepted` field represents whether an incident should be used. Some
  # monitors are known to have been incorrectly configured during certain time
  # periods -- we want to collect all event data, but mark events/incidents
  # from those time periods as not accepted.
  
  # TODO: only include accepted incidents in the default scope?
  # TODO: remove `milliseconds`. This can just as easily be computed on demand
  
  def self.current
    where(end_date: nil).order(start_date: :desc)
  end
  
  def self.intersecting(start_date, end_date)
    values = {start_date: start_date, end_date: end_date}
    where('start_date <= :end_date AND end_date >= :start_date', values)
      .or(where('start_date IS NULL AND end_date >= :start_date', values))
      .or(where('start_date <= :end_date AND end_date IS NULL', values))
  end
  
  # TODO: make this a `before_add` and `after_add` callback?
  # (This method is a legacy of our old Mongoid setup)
  def add_event(event)
    begin
      add_event!(event)
    rescue
      return false
    end
    true
  end
  
  def add_event!(event)
    # Don't add UP events to a closed incident
    if !ongoing? && event.up?
      raise 'Cannot add an "UP" event to a closed incident'
    end
    
    self.events << event
    
    # If unset, populate various attributes from event
    if start_date.nil? || (!event.up? && event.date < start_date)
      self.start_date = event.date
    end

    if state.nil? || state.empty?
      self.state = event.state
    end

    if monitor.nil?
      self.monitor = event.monitor
    end
    
    # Close out the incident if it's an UP event.
    if event.up?
      self.end_date = event.date
      self.milliseconds = ((end_date - start_date) * 1000).round
    end
    
    # inherit unacceptedness
    if !event.accepted?
      self.accepted = false
    end
    
    self.save
  end
  
  def ongoing?
    self.end_date.nil?
  end
  
  def in_date_range?(start_date, end_date)
    (self.start_date <= end_date && self.end_date >= start_date) ||
    (self.start_date.nil? && self.end_date >= start_date) ||
    (self.start_date <= end_date && self.end_date.nil?)
  end
end
