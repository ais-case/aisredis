# ais sentence server

require 'rubygems'
require 'json'
require 'net/http'
require 'redis'

$LOAD_PATH << './lib'
require 'aisDomainFactories.rb'

uri = URI('http://82.210.120.176:21000/SUBSCRIBE/ais.sentence')
redis = Redis.new
sentenceFactory = AisDomainFactories::AisSentenceFactory.new

Net::HTTP.start(uri.host, uri.port) do |http|
  request = Net::HTTP::Get.new uri.request_uri

  http.request request do |response|
    response.read_body do |chunk|
      json = JSON::parse(chunk)
      json.each_value do |array|
        if array[0] == 'message'
          raw = array[2]
          sentence = sentenceFactory.load(raw)
          redis.publish(sentence.key, sentence.dump())
        end
      end
    end
  end
end

