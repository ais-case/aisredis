require 'rubygems'
require 'redis'

redis = Redis.new

redis.psubscribe("ais.msg.*", "ais.error") do |on|
  on.pmessage do |pattern, channel, message|
    puts "#{channel} #{message}"
  end
end
