require 'rack-timeout'
use Rack::Timeout
Rack::Timeout.timeout = 30

require './app'
require 'raven'

use Raven::Rack
run Sinatra::Application
