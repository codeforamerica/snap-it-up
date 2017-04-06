class Snapshot < ActiveRecord::Base
  belongs_to :event, class_name: 'MonitorEvent', inverse_of: :snapshots
  
  before_save :ensure_date
  
  # FIXME: The `status` field is "UP" or "DOWN", which is basically idiotic
  # given that we have 0/1/[status code] for events.
  
  def render_url(args=nil)
    querystring = ""
    if !args.nil?
      querystring = "?"
      if args.kind_of? String
        querystring += "#{args}"
      else
        querystring += args.collect {|k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"}.join("&")
      end
    end
    return "//snap-it-up.imgix.net/#{self.name}#{querystring}"
  end
  
  protected
  
  def ensure_date
    if !self.date
      self.date = Time.now
    end
  end
end
