if ENV['SENTRY_DSN'] && ENV['SENTRY_ACTIVE'] != 'false'
  require 'raven'
end

require './app.rb'
# require 'qu/tasks'
require 'sinatra/activerecord/rake'

# namespace :db do
#   task :load_config do
#     require './app.rb'
#   end
# end

Dir.glob('tasks/*.rake').each { |r| load r}
