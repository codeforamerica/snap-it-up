helpers do
  def snapshot_url(snapshot, args=nil)
    querystring = ''
    if !args.nil?
      querystring = "?"
      if args.kind_of? String
        querystring += "#{args}"
      else
        querystring += args.collect {|k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"}.join("&")
      end
    end
    return "//snap-it-up.imgix.net/#{snapshot['name']}#{querystring}"
  end
end