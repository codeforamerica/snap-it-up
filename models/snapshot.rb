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
end
