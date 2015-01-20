require 'sinatra'
require 'net/https'
require 'uri'
require 'json'

PINGOMETER_USER = ENV['PINGOMETER_USER']
PINGOMETER_PASS = ENV['PINGOMETER_PASS']

get '/' do
  uri = URI.parse("https://app.pingometer.com/api/v1.0/monitors/")

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri.request_uri)
  request.basic_auth(PINGOMETER_USER, PINGOMETER_PASS)
  response = http.request(request)
  
  # FIXME: Not even trying to check for errors ha ha yep not production.
  data = JSON.parse(response.body)
  down = data['monitors']
    .select {|monitor| monitor['last_event']['type'] == 0}
    .map {|monitor| monitor['name']}
  
  content_type :json
  down.to_json
end
