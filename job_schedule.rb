require 'clockwork'
require './app.rb'

module Clockwork
  every(5.minutes, "pingometer.etl") { LoadPingometerEvents.enqueue }
end
