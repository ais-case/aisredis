
require 'rubygems'
require 'redis'
$LOAD_PATH << './lib'
require 'aisDomainClasses.rb'

include AisDomainClasses

redis  = Redis.new

loop {
  
  kml = File.new("gui/activeVessel.kml", "w")
  kml.puts("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
  kml.puts("<kml xmlns=\"http://www.opengis.net/kml/2.2\">")
  kml.puts("<Document>")

  activeVessels = redis.keys("ais.active.*")
  if activeVessels != nil then
    # only make kml if there is activity
    activeVessels.each do |v|
      ais, act, mmsi = v.split('.')
      statusStr = redis.get("ais.status.#{mmsi}")
      key, mmsi, ts, lat, lon, right = statusStr.split(',')
      kml.puts("<Placemark>")
      kml.puts("    <name>#{mmsi}</name>")
      kml.puts("    <description>Vessel</description>")
      kml.puts("    <Point>")
      kml.puts("        <coordinates>#{lon},#{lat}</coordinates>")
      kml.puts("    </Point>")
      kml.puts("</Placemark>")
    end

    kml.puts("</Document>")
    kml.puts("</kml>")
    kml.close()
  end
  sleep(3)
}





