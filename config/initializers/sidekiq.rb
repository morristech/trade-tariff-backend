require "sidekiq"

# PaaS Redis is not ready for prod
if ENV['VCAP_SERVICES'].present?
  redis_url = JSON.parse(ENV["VCAP_SERVICES"])["redis"].select{ |s| s["name"] == ENV["REDIS_INSTANCE_NAME"] }[0]["credentials"]["uri"]
else
  redis_url = ENV["REDIS_URL"]
end

redis_db = ENV["REDIS_DB"] || 0

redis_config = { url: redis_url, db: redis_db }

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
