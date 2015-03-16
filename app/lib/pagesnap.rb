class PageSnap
  def initialize(base_url=nil)
    @base_url = base_url || "http://pagesnap.herokuapp.com"
  end
  
  def snapshot(url)
    HTTParty.get("#{@base_url}/#{CGI.escape(url)}.png", :timeout => 20).parsed_response
  end
end
