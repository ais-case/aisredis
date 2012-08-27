require 'webrick'

module JsServlets
  include WEBrick
  
  def getResource(requestString)
    # split up request_line "GET /javascript?jquery HTTP/1.1" and extract resource
    left, resource, right = requestString.split(' ')
    # strip / from resource /javascript?jquery
    return resource.delete!('/')
  end

  class JavascriptServlet < HTTPServlet::AbstractServlet
    # servlet for sending our local javascripts
    def do_GET(req, res)
      content = ""
      resource = getResource(req.request_line)
      puts resource
      if resource == "javascript?jquery" then
        file    = File.open('gui/jquery-1.7.2.js', 'r')
        content = file.read()
        file.close
      elsif resource == "javascript?openlayers" then
        file    = File.open('gui/OpenLayers.js', 'r')
        content = file.read()
        file.close
      end
      res['Content-Type'] = "application/x-javascript"
      res.body = content
    end
  end # class

  


end # module
