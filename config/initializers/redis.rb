# frozen_string_literal: true

# config/initializers/redis.rb
require 'redis'

REDIS = Redis.new(url: ENV.fetch('REDIS_URL'))
