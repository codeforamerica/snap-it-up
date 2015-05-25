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

  def get(path, options={})
    options.merge!({basic_auth: @auth})
    response = self.class.get(path, options)
    if response.code != 200
      raise response.body
    end
    response
  end

end
