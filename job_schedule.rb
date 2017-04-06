require 'clockwork'
require './app.rb'

module Clockwork
  every(2.minutes, "pingometer.etl") { LoadPingometerEvents.enqueue }
end
