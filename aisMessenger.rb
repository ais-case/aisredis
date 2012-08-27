# service 
# publish ais messages by types on redis

require 'rubygems'
require 'redis'
require 'thread'
$LOAD_PATH << './lib'
require 'aisDomainClasses.rb'
require 'aisDomainFactories.rb'

include AisDomainClasses
include AisDomainFactories

rsub  = Redis.new
rpub  = Redis.new
queue = SizedQueue.new(10)


# receive ais raw sentences from redis
subThr = Thread.new do
  rsub.subscribe("ais.sentence") do |on|
    on.message do |key, msg|
      queue << msg 
    end
  end
end # Thread.new

# ais single sentence 
# ais.sentence,1339846648.566813946,!AIVDM,1,1,,B,63@0Wl00UBf006P0p0,4*08
# ais multi sentence with two parts
# ais.sentence,1339846648.422811031,!AIVDM,2,1,0,B,53ntof42:3Mph5EG@008uN0<hU10E8000000001B0bo@@5WG0C4m4`30FH0Q,0*19
# ais.sentence,1339846648.430813074,!AIVDM,2,2,0,B,DU200000000,2*34

# create ais messages and publish them to redis
mesgFactory = AisDomainFactories::AisMessageFactory.new

loop do

  begin
    aisSentence = queue.pop
    msg = mesgFactory.load(aisSentence);
  rescue ArgumentError => err
    rpub.publish("ais.error", "#{$0},#{err},#{aisSentence}")
    retry
  end
  
  if msg != nil then
    rpub.publish("ais.msg.#{msg.type}", msg.dump)
  end

end # loop


