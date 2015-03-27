require 'clockwork'
require './app.rb'

module Clockwork
  every(2.minutes, "pingometer.etl") { Qu.enqueue LoadPingometerEvents }
end
