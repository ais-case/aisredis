require 'rubygems'
require 'redis'

redis = Redis.new

redis.subscribe("ais.sentence") do |recv|
  recv.message do |key,msg|
    puts "#{key} #{msg}"
  end
end
