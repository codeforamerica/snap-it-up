require './app'
require 'raven'

use Raven::Rack
run Sinatra::Application
