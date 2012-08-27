# aisRedisDefault.rb
# loads some ais standard keys into redis

require 'rubygems'
require 'redis'
require 'aisDomainConcepts.rb'
include AisDomainConcepts

redis = Redis.new

# store the message types as key-values in redis
redis.set("ais.message.type.default", "Unknown")
MessageType.each do |key, value|
  redis.set("ais.message.type.#{key}", value)
end

# store the vessel types as key-values in redis
redis.set("ais.vessel.type.default", "Unknown")
VesselType.each do |key, value|
  if key.class == Range then
    key.each do |k|
      redis.set("ais.vessel.type.#{k}", value)
    end
  else
    redis.set("ais.vessel.type.#{key}", value)
  end
end

# store the naviation status as key-values in redis
redis.set("ais.navigation.status.default", "Not defined (default)")
NavigationStatus.each do |key, value|
  if key.class == Range then
    key.each do |k|
      redis.set("ais.navigation.status.#{k}", value)
    end
  else
      redis.set("ais.navigation.status.#{key}", value)
  end
end
