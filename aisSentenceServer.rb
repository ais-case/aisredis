# service
# publish ais messages on redis.publish
# messages are fetched from the zmq server 

require 'rubygems'
require 'redis'

$LOAD_PATH << './lib'
require 'ZmqService.rb'
require 'aisDomainClasses.rb'
require 'aisDomainFactories.rb'

# subscribe to zmq ais message server
sub = ZmqSub.new('tcp://82.210.120.176:21000','')
red = Redis.new

sentenceFactory = AisDomainFactories::AisSentenceFactory.new
loop {
  
  # publish the each ais message on redis
  raw = sub.gets
  sentence = sentenceFactory.load(raw)
  red.publish(sentence.key, sentence.dump())

}
