require 'httparty'

class Pingometer
  include HTTParty
  base_uri 'https://app.pingometer.com/api/v1.0'
  headers 'Accept' => 'application/json'

  def initialize(user, pass)
    @auth = {username: user, password: pass}
  end

  def monitors
    get('/monitors/')['monitors']
  end

  def monitor(id)
    get("/monitor/#{id}/")['monitor'][0]
  end

  def events(monitor=nil)
    if monitor.nil?
      get("/events/")['events']
    else
      id = monitor.kind_of?(Hash) ? monitor['id'] : monitor
      get("/monitor/#{id}/events/")['events']
    end
  end


  protected

  def get(path, options={}, retries = 3)
    options.merge!({basic_auth: @auth})
    response = self.class.get(path, options)
    
    # For bad gateways, timeouts, etc, give Pingometer a break then retry
    if response.code > 501 && response.code < 600 && retries > 0
      sleep([4 - retries, 0].max * 5)
      get(path, options, retries - 1)
    elsif response.code != 200
      raise "Error code #{response.code} from '#{path}':\n#{response.body}"
    end
    
    response
  end

end
