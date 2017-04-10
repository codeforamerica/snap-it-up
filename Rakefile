if ENV['SENTRY_DSN'] && ENV['SENTRY_ACTIVE'] != 'false'
  require 'raven'
end

require './app.rb'
require 'sinatra/activerecord/rake'

# Don't dump DB in production; we don't need it and it doesn't work on Heroku
# http://stackoverflow.com/questions/17300341/migrate-not-working-on-heroku
if ENV['RACK_ENV'] == 'production'
  Rake::Task['db:structure:dump'].clear
end

Dir.glob('tasks/*.rake').each { |r| load r}
