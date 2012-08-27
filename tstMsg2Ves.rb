require 'rubygems'
require 'redis'

redis = Redis.new

redis.psubscribe('ais.destination.*', 'ais.vessel.*', 'ais.status.*') do |on|
  on.pmessage do |pattern, channel, msg| 
    puts "#{channel} #{msg}"
  end
end
  

