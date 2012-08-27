
# service
# translates ais vessel messages into vessel objects
# saves the vessel objects to redis
# publishes vessel objects to redis

require 'rubygems'
require 'redis'
$LOAD_PATH << './lib'
require 'aisDomainFactories.rb'

include AisDomainFactories

rsub  = Redis.new
rpub  = Redis.new
queue = SizedQueue.new(10)

# receive vessel messages from Redis
thrSub = Thread.new do
  rsub.subscribe('ais.msg.1', 'ais.msg.2', 'ais.msg.3', 'ais.msg.5', 'ais.msg.18', 'ais.msg.19') do |on|
    on.message do |key, msg|
      queue << "#{key} #{msg}"
    end
  end
end # Thread.new

vFactory = AisDomainFactories::AisVesselFactory.new
dFactory = AisDomainFactories::AisDestinationFactory.new
sFactory = AisDomainFactories::AisStatusFactory.new

loop do
  
  begin
    # ais.msg.1 ais.message,1341521007.030829906,1,B,13aGrpgP?w<tSF0l4Q@>4?wvPVRd
    # ais.msg.2 ais.message,1341521007.058850050,2,B,23`jcmhP0f0Cw2dMdEJ7sgvkpH?m
    # ais.msg.3 ais.message,1341521007.110826969,3,A,33aI9>?P?w<tSF0l4Q@>4?wp0S71
    channel, msg = queue.pop.split(' ')
    if channel == 'ais.msg.5' or channel == 'ais.msg.19' then
      # make a vessel from static messages
      vessel = vFactory.load(msg)
      redisKey   = "ais.vessel.#{vessel.mmsi}"
      redisValue = vessel.dump()
      # store vessel in redis
      rpub.set(redisKey, redisValue)
      # publish vessel
      rpub.publish(redisKey, redisValue)
      
      if channel == 'ais.msg.5' then
        # figure out vessel destinations
        destination = dFactory.load(msg)
        redisKey    = "ais.destination.#{vessel.mmsi}"
        redisValue  = destination.dump()
        # store destination in redis
        rpub.set(redisKey, redisValue)
        # publish destination
        rpub.publish(redisKey, redisValue)
      end
    end
    
    if channel == 'ais.msg.1' or channel == 'ais.msg.2' or channel == 'ais.msg.3' or channel == 'ais.msg.18' or channel == 'ais.msg.19' then
      # make position, direction, and speed from dynamic messages
      status = sFactory.load(msg)
      redisKey   = "ais.status.#{status.mmsi}"
      redisValue = status.dump()
      # store status in redis
      rpub.set(redisKey, redisValue)
      # publish status
      rpub.publish(redisKey, redisValue)
    end

  rescue ArgumentError => err
    rpub.publish("ais.error", "#{$0},#{err},#{msg}")
    retry
  end

end # loop
