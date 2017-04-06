if ENV['SENTRY_DSN'] && ENV['SENTRY_ACTIVE'] != 'false'
  require 'raven'
end

require './app.rb'
require 'sinatra/activerecord/rake'

Dir.glob('tasks/*.rake').each { |r| load r}
