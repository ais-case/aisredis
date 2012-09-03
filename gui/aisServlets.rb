require 'webrick'
require 'net/http'
require 'uri'

module AisServlets 
  include WEBrick

  def getResource(requestString)
    # split up request_line "GET /ais.xyz?244670878 HTTP/1.1" and extract resource
    left, resource, right = requestString.split(' ')
    # strip / from resource /ais.xyz?244670878
    return resource.delete!('/')
  end # getResource


  class AisMapServlet < HTTPServlet::AbstractServlet
    # send the basic map "gui/basicMap.html"
    def do_GET(req, res)
      file = File.open('gui/basicMap.html', 'r')
      html = file.read()
      file.close
      res['Content-Type'] = "text/html"
      res.body = html
    end
  end # class


  class AisSentenceServlet < HTTPServlet::AbstractServlet
    def do_GET(req, res)
      res["content-type"] = "text/plain"
      r, w = IO.pipe
      res.body = r
      Thread.start do
        loop {
          w.write("hello")
          sleep(1)
        }
      end
      w.close
    end
  end # class
  

  class AisMessageTypeServlet < HTTPServlet::AbstractServlet
    # send a list with all message types
    # send a particular message type
    def do_GET(req, res)
      resource = getResource(req.request_line)
      if resource.match(/ais.message.type$/) then
        # reply on "ais.message.type" request -> return all message type keys as text
        reply = ''
        $redis.keys("ais.message.type.*").each do |k|
          reply << k << "\n"
        end
      elsif resource.match(/ais.message.type\?[0-9]*/) then
        #reply on "ais.message.type.15" -> return entry for this key as text
        key, num = resource.split('?')
        reply = $redis.get("#{key}.#{num}")
      end # if
      res['Content-Type'] = "text/plain"
      res.body = reply
    end
  end # class


  class AisVesselTypeServlet < HTTPServlet::AbstractServlet
    def do_GET(req, res)
      resource = getResource(req.request_line)
      if resource.match(/ais.vessel.type$/) then
        # reply on "ais.vessel.type" request -> return all message type keys as text
        reply = ''
        $redis.keys("ais.vessel.type.*").each do |k|
          reply << k << "\n"
        end
      elsif resource.match(/ais.vessel.type\?[0-9]*/) then
        #reply on "ais.vessel.type.15" -> return entry for this key as text
        key, num = resource.split('?')
        reply = $redis.get("#{key}.#{num}")
      end # if
      res['Content-Type'] = "text/plain"
      res.body = reply
    end
  end

  
  class AisNavigationStatusServlet < HTTPServlet::AbstractServlet
    def do_GET(req, res)
      resource = getResource(req.request_line)
      if resource.match(/ais.navigation.status$/) then
        # reply on "ais.vessel.type" request -> return all message type keys as text
        reply = ''
        $redis.keys("ais.navigation.status.*").each do |k|
          reply << k << "\n"
        end
      elsif resource.match(/ais.navigation.status\?[0-9]*/) then
        #reply on "ais.vessel.type.15" -> return entry for this key as text
        key, num = resource.split('?')
        reply = $redis.get("#{key}.#{num}")
      end # if
      res['Content-Type'] = "text/plain"
      res.body = reply
    end
  end


  class AisVesselServlet < HTTPServlet::AbstractServlet
    def do_GET(req, res)
      resource = getResource(req.request_line)
      if resource.match(/ais.vessel$/) then
        # reply on "ais.vessel" request -> return all vessel keys as text
        reply = ""
        $redis.keys("ais.vessel.*").each do |k|
          reply << k << "\n"
        end
      elsif resource.match(/ais.vessel\?[0-9]*/) then
        # reply on a particular key "ais.vessel?244670878" -> return entry for this key as text
        key, num = resource.split('?')
        reply = $redis.get("#{key}.#{num}")
      end # if
      res['Content-Type'] = "text/plain"
      res.body = reply
    end
  end # class


  class AisDestinationServlet < HTTPServlet::AbstractServlet
    def do_GET(req, res)
      resource = getResource(req.request_line)
      reply = ""
      if resource.match(/ais.destination$/) then
        # reply on "ais.destination" request -> return all destination keys as text
        $redis.keys("ais.destination.*").each do |k|
          reply << k << "\n"
        end
      elsif resource.match(/ais.destination\?[0-9]*/) then
        # reply on a particular key "ais.destination?244670878" -> return entry for this key as text
        key, num = resource.split('?')
        reply = $redis.get("#{key}.#{num}")
      end
      res['Content-Type'] = "text/plain"
      res.body = reply
    end
  end # class


  class AisStatusServlet < HTTPServlet::AbstractServlet
    def do_GET(req, res)
      resource = getResource(req.request_line)
      if resource.match(/ais.status$/) then
        # reply on "ais.status" request -> return all status keys as text
        reply = ""
        $redis.keys("ais.status.*").each do |k|
          reply << k << "\n"
        end
      elsif resource.match(/ais.status\?[0-9]*/) then
        # reply on a particular key "ais.status?244670878" -> return entry for this key as text
        key, num = resource.split('?')
        reply = $redis.get("#{key}.#{num}")
      end
      res['Content-Type'] = "text/plain"
      res.body = reply
    end
  end # class

  def activeVesselArea(lonlatString)
    # expecting lonlat lonlat string
    # 3.2565869140626,51.463222026363,5.8685864257812,52.336011418411
    lonlat = lonlatString.split(',')
    lon1 = lonlat[0].to_f
    lat1 = lonlat[1].to_f
    lon2 = lonlat[2].to_f
    lat2 = lonlat[3].to_f
    actVesString = ""
    $redis.keys("ais.active.*").each do |k|
      mmsi = k.delete("ais.active.")
      activeString = $redis.get("ais.status.#{mmsi}")
      # "ais.status,244750217,1342016369.990824938,51.91542,4.48328333333333,2278.0,511.0,0.0,15"
      next if activeString.nil?
      substr = activeString.split(',')
      lon = substr[4].to_f
      lat = substr[3].to_f
      if lon > lon1 and lat > lat1 and lon < lon2 and lat < lat2 then
        actVesString << k << "\n"
      end
    end
    return actVesString
  end

  class AisActiveServlet < HTTPServlet::AbstractServlet
    def do_GET(req, res)
      resource = getResource(req.request_line)
      if resource.match(/ais.active$/) then
        # reply on "ais.active" request -> return all active keys as text
        reply = ""
        $redis.keys("ais.active.*").each do |k|
          reply << k << "\n"
        end
      elsif resource.match(/ais.active\?area=/) then
        # reply on "ais.active" request -> return all active keys in an geo area 
        # ais.active?area=3.2565869140626,51.463222026363,5.8685864257812,52.336011418411
        key, val = resource.split('?')
        lonlatString = val.delete("area=")
        # now check which active.vessel is in this area
        reply = activeVesselArea(lonlatString)
      elsif resource.match(/ais.active\?[0-9]*/) then
        # reply on a particular key -> return ent-ry for this key
        key, num = resource.split('?')
        reply = $redis.get("#{key}.#{num}")      
      end
      res['Content-Type'] = "text/plain"
      res.body = reply
    end
  end # class


  def makeKmlPlacemark(redisKey) 
    placeMark = ""
    ais, act, mmsi = redisKey.split('.')       # extract mmsi from redis key
    mmsi.strip!                                # remove potential \n from redisKey
    status = $redis.get("ais.status.#{mmsi}")  # get the status string for this mmsi
    vessel = $redis.get("ais.vessel.#{mmsi}")  # get the vessel string for this mmsi
    key, mm, ts, lat, lon, right = status.split(',') unless status == nil
    key, mm, ts, ty, name        = vessel.split(',') unless vessel == nil
    # make a kml placemark
    placeMark << "<Placemark><name>#{mmsi}</name>"
    placeMark << "<description>#{name}</description>" << "\n"
    placeMark << "    <Point><coordinates>#{lon},#{lat}, 0</coordinates></Point>"
    placeMark << "</Placemark>" << "\n"
    return placeMark
  end

  class AisKmlServlet < HTTPServlet::AbstractServlet
    # publish active vessel data as kml-xml text on localhost:3000/ais.active.kml
    # req.request_line from openlayers looks like so:
    # "GET /ais.active.kml?key=0.1246874020434916&bbox=3.0711926269532,51.559375755527,5.6831921386718,52.430313922221 HTTP/1.1"
    def do_GET(req, res)
      # start formatting the kml output
      reply =  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
      reply << "<kml xmlns=\"http://www.opengis.net/kml/2.2\"><Document>" << "\n"
      # what kind of request was it? ALL active vessels OR only part of active vessels?
      resource = getResource(req.request_line)
      if resource.match(/ais.active.kml$/) then
        # return ALL active vessels in redis "ais.active.*"
        $redis.keys("ais.active.*").each do |k|
          if k != nil then
            reply << makeKmlPlacemark(k)
          end
        end 
      elsif resource.match(/ais.active.kml\?key=*/) then
        # return only Vessels in the requested area
        # key=0.1246874020434916&bbox=3.0711926269532,51.559375755527,5.6831921386718,52.430313922221
        left, bbox   = resource.split('&')     # get rid of the key
        lonlatString = bbox.delete('bbox=')    # extract the area-lonlats
        # lonlatString => 4.214671974183,51.847577447242,4.541171913148,51.95667113574
        aisActive = activeVesselArea(lonlatString)
        aisActive.each_line do |k|
          reply << makeKmlPlacemark(k)
        end
      end
      reply << "</Document></kml>" << "\n"
      res['Content-Type'] = "text/plain"
      res.body = reply
    end
  end # class

end # module
