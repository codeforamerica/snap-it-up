# config/initializers/refile.rb
require "refile/backend/s3"

if ENV['AWS_KEY']
  aws = {
    access_key_id: ENV['AWS_KEY'],
    secret_access_key: ENV['AWS_SECRET'],
    bucket: ENV['AWS_BUCKET'],
    region: ENV['AWS_REGION']
  }

  Refile.cache = Refile::Backend::S3.new(prefix: "cache", **aws)
  Refile.store = Refile::Backend::S3.new(prefix: "store", **aws)
end
