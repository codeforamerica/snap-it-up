require 'rack-timeout'
use Rack::Timeout
Rack::Timeout.timeout = 30

require './app'
run Sinatra::Application
