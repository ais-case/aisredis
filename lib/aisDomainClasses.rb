$LOAD_PATH << './lib'
require 'aisDomainConcepts.rb'

include AisDomainConcepts

module AisDomainClasses

  class AisSentence
    @@key = "ais.sentence"
    attr_reader :timestamp  # String
    attr_reader :sentence   # String
    def initialize(ts, sen)
      @timestamp = ts.to_s
      @sentence  = sen.to_s
    end
    def key()
      return @@key
    end
    def dump()
      return "#{@@key},#{timestamp},#{sentence}"
    end
    def load(sentenceString)
      key, ts, sen = sentenceString.split(',')
      if key == @@key then
        initialize(ts, sen)
      else 
        raise ArgumentError, @@key
      end
    end
  end

  class AisMessage
    @@key = "ais.message"
    attr_reader :timestamp   # String
    attr_reader :type        # Integer
    attr_reader :channel     # String
    attr_reader :payload     # String
    def initialize(ts, ty, ch, py)
      @timestamp = ts.to_s
      @type = ty.to_i
      @channel = ch.to_s
      @payload = py.to_s
    end
    def key()
      return @@key
    end
    def dump()
      return "#{@@key},#{@timestamp},#{@type},#{@channel},#{@payload}"
    end
    def load(aisMessageString)
      key, ts, ch, py = aisMessageString.split(',')
      if key == @@key then
        initialize(ts, ty.to_i, ch, py)
      else
        raise ArgumentError, @@key
      end
    end
    def getTypestring() 
      return AisDomainConcepts::MessageType[@type]
    end
  end # class AisMessage
  
  class AisStatus
    @@key = "ais.status"
    attr_reader :mmsi        # Integer
    attr_reader :timestamp   # String
    attr_reader :lat         # Float
    attr_reader :lon         # Float
    attr_reader :course      # Float
    attr_reader :heading     # Float
    attr_reader :speed       # Float
    attr_reader :status      # Integer
    def initialize(mmsi, timestamp, lat, lon, course, heading, speed, status)
      @mmsi      = mmsi.to_i
      @timestamp = timestamp.to_s
      @lat       = lat.to_f
      @lon       = lon.to_f
      @course    = course.to_f
      @heading   = heading.to_f
      @speed     = speed.to_f
      @status    = status.to_i
    end
    def key()
      return @@key
    end
    def dump()
      return "#{@@key},#{@mmsi},#{@timestamp},#{@lat},#{@lon},#{@course},#{@heading},#{@speed},#{@status}"
    end
    def load(aisStatusString)
      key, mmsi, ts, lat, lon, cou, hea, sp, st = aisStatusString.split(',')
      if key == @@key then
        initialize(mmsi, ts, lat, lon, cou, hea, sp, st)
      else
        raise @@key
      end
    end
    def getNavigationstatus()
      return NavigationStatus[@status]
    end
  end


  class AisDestination
    @@key = "ais.destination"
    attr_reader :mmsi           # Integer
    attr_reader :timestamp      # String
    attr_reader :destination    # String
    def initialize(mmsi, timestamp, destination)
      @mmsi        = mmsi.to_i
      @timestamp   = timestamp.to_s
      @destination = destination.to_s
    end
    def dump()
      return "#{@@key},#{mmsi},#{@timestamp},#{@destination}"
    end
    def load(aisDestinationString)
      key, mmsi, timestamp, destination = aisDestinationString.split(',')
      if key == @@key then
        initialize(mmsi.to_i, timestamp, destination)
      else
        rasie ArgumentError, @@key
      end
    end
  end

  class AisVessel  
    @@key = "ais.vessel"
    attr_reader :mmsi       # Integer
    attr_reader :timestamp  # String
    attr_reader :type       # Integer
    attr_reader :name       # String
    def initialize(mmsi, ts, type, name)
      @mmsi      = mmsi.to_i
      @timestamp = ts.to_s
      @type      = type.to_i
      @name      = name.to_s
    end
    def key()
      return @@key
    end
    def dump()
      return "#{@@key},#{@mmsi},#{@timestamp},#{@type},#{@name}"
    end
    def load(aisVesselString)
      key, mmsi, ts, type, name = aisVesselString.split(',')
      if key == @@key then
        initialize(mmsi, ts, type, name)
      else
        raise ArgumentError, @@key
      end
    end
    def getVesseltype()
      return VesselType[@type]
    end
  end # class AisVessel

  class AisActive
    # currently active vessel with mmsi and latest timestamp
    @@key = "ais.active"
    attr_reader :mmsi       # Integer
    attr_reader :timestamp  # String
    def initialize(mmsi, ts)
      @mmsi      = mmsi.to_i
      @timestamp = ts.to_s
    end
    def key()
      return @@key
    end
    def dump()
      return "#{@@key},#{@mmsi},#{@timestamp}"
    end
    def load(aisActiveString)
      key, mmsi, ts = aisActiveString.split(',')
      initialize(mmsi, ts)
    end
  end # class AisActive

end # module AisDomainClasses
