source "https://rubygems.org"
ruby "2.2.0"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "sinatra"
gem 'rails', '4.2.0'
# Use postgresql as the database for Active Record
gem 'pg'

# gem "mongoid", "~> 4.0"
gem "puma"
gem "rack-timeout"

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets

gem "mini_magick"
gem "refile", require: ["refile/rails", "refile/image_processing"]
gem "que"
gem "httparty"
gem "aws-sdk", '< 2'
gem 'pry-rails'

# For browserstack
gem "selenium-webdriver"

gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

group :production do
  gem 'heroku-deflater'
  gem 'newrelic_rpm'
  gem 'lograge'
  gem 'rails_12factor'
  gem 'sentry-raven'
end

group :development, :test do
  gem 'pry-byebug'# put `byebyg` to debug
  gem 'rspec'
  gem 'rspec-rails'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'webmock'
end

group :development do
  gem 'annotate'
  gem 'guard-rspec', require: false
  gem 'terminal-notifier-guard', require: false
end
