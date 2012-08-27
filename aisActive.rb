
require 'rubygems'
require 'redis'
require 'thread'
$LOAD_PATH << './lib'
require 'aisDomainFactories.rb'

include AisDomainFactories

rsub  = Redis.new
redis = Redis.new

# receive vessel & status messages (with timestamps) from Redis
queue = SizedQueue.new(10)
thrSub = Thread.new do
  rsub.psubscribe('ais.vessel.*', 'ais.status.*') do |on|
    on.pmessage do |pat, key, msg|
      queue << "#{key} #{msg}"
    end
  end
end # Thread.new

aisActiveFactory = AisActiveFactory.new()
loop {

  key, msg = queue.pop().split(' ')
  activeVessel = aisActiveFactory.load(msg)

  # set the key in redis
  redis.set("#{activeVessel.key()}.#{activeVessel.mmsi}", activeVessel.dump())
  # set the key to expire after 200 seconds, vessels should report at least every 3 minutes
  redis.expire("#{activeVessel.key()}.#{activeVessel.mmsi}", 360)

}

