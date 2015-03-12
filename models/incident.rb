class Incident
  include Mongoid::Document
  
  field :monitor, type: String
  field :state, type: String
  field :start_date
  field :end_date
  field :events, type: Array, default: []  # of BSON IDs
  field :milliseconds
  
  def add_event(event)
    # Don't re-add events or add UP events to a closed incident
    if events.include?(event.id) || (!ongoing? && event.status != 0)
      return false
    end
    
    self.events << event.id
    
    # If unset, populate various attributes from event
    if start_date.nil? || (event.status == 0 && event.date < start_date)
      self.start_date = event.date
    end

    if state.nil? || state.empty?
      self.state = event.state
    end

    if monitor.nil?
      self.monitor = event.monitor
    end
    
    # Close out the incident if it's an UP event.
    if event.status != 0
      self.end_date = event.date
      self.milliseconds = ((end_date - start_date) * 1000).round
    end
    
    return true
  end
  
  def ongoing?
    self.end_date.nil?
  end
end
