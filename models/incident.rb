class Incident
  include Mongoid::Document
  
  field :monitor, type: String
  field :state, type: String
  field :start_date
  field :end_date
  field :events, type: Array, default: []  # of BSON IDs
  field :milliseconds
  field :accepted, type: Boolean, default: true
  
  def self.current
    self.where(end_date: nil).order({start_date: -1})
  end
  
  def self.intersecting(start_date, end_date)
    self.or(
      {:start_date.lte => end_date, :end_date.gte => start_date},
      {:start_date => nil, :end_date.gte => start_date},
      {:start_date.lte => end_date, :end_date => nil}
    )
  end
  
  def add_event(event)
    # Don't re-add events or add UP events to a closed incident
    if events.include?(event.id) || (!ongoing? && event.up?)
      return false
    end
    
    self.events << event.id
    
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
    
    return true
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
