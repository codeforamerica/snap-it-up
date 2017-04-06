require 'httparty'

class Pingometer
  include HTTParty
  base_uri 'https://api.pingometer.com/v1.1'
  headers 'Accept' => 'application/json'

  def initialize(user, pass)
    @auth = {username: user, password: pass}
  end

  def monitors
    get('/monitors/')['monitors']
  end

  def monitor(id)
    get("/monitors/#{id}/")['monitor'][0]
  end

  def events(monitor=nil)
    if monitor.nil?
      # Pingometer's API has a method to get all events:
      #   get("/events/")['events']
      # But it appears to fail often (it looks like it is taking too long and
      # their load balancer or some proxy is killing the request) so instead
      # get the events from each monitor individually. Really high overhead,
      # but at least it works reliably :(
      monitors.flat_map &method(:events)
    else
      id = monitor.kind_of?(Hash) ? monitor['id'] : monitor
      get("/monitors/#{id}/events/")['events']
    end
  end


  protected

  def get(path, options={}, retries = 3)
    options.merge!({basic_auth: @auth})
    response = self.class.get(path, options)
    
    # For bad gateways, timeouts, etc, give Pingometer a break then retry
    if response.code > 501 && response.code < 600 && retries > 0
      wait_time = [4 - retries, 0].max * 5
      sleep(wait_time)
      get(path, options, retries - 1)
    elsif response.code != 200
      raise "Error code #{response.code} from '#{path}':\n#{response.body}"
    end
    
    response
  end

end
