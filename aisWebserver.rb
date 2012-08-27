# web server for providing the basic map
# web server for providing an http interface to redis

require 'rubygems'
require 'redis'
require 'thread'
require 'webrick'
$LOAD_PATH << './gui'
require 'aisServlets.rb' 
require 'jsServlets.rb'

include WEBrick
include AisServlets
include JsServlets

$redis = Redis.new
s = HTTPServer.new( :Port => 3000 )

# map
s.mount("/",                AisMapServlet)
# redis
s.mount("/ais.vessel",      AisVesselServlet) 
s.mount("/ais.destination", AisDestinationServlet)
s.mount("/ais.status",      AisStatusServlet)
s.mount("/ais.active",      AisActiveServlet)
s.mount("/ais.sentence",    AisSentenceServlet)

s.mount("/ais.active.kml",  AisKmlServlet)


s.mount("/ais.message.type", AisMessageTypeServlet)
s.mount("/ais.vessel.type",  AisVesselTypeServlet)
s.mount("/ais.navigation.status", AisNavigationStatusServlet)

# javascript
s.mount("/javascript",      JavascriptServlet)


trap("INT"){ s.shutdown } 
s.start
