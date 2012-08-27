$LOAD_PATH << './lib'
require 'aisDomainClasses.rb'
require 'aisDecoder.rb'
require 'aisEncoder.rb'
require 'aisChecker.rb'

include AisDomainClasses
include AisDecoder
include AisEncoder
include AisChecker

module AisDomainFactories

  class AisSentenceFactory
    # input:  raw ais sentence from the base station
    # return: new Sentence : ArgumentError
    # ais single sentence 
    # 1339846648.566813946!AIVDM,1,1,,B,63@0Wl00UBf006P0p0,4*08
    # ais multi sentence with two parts
    # 1339846648.422811031!AIVDM,2,1,0,B,53ntof42:3Mph5EG@008uN0<hU10E8000000001B0bo@@5WG0C4m4`30FH0Q,0*19
    # 1339846648.430813074!AIVDM,2,2,0,B,DU200000000,2*34
    @@key = "ais.sentence.factory"
    @@patSentenceRaw = /^[0-9]{10}\.[0-9]{9}!AIVDM,\d,\d,\d?,[A-B],.*/
    def load(sentenceString)
      if @@patSentenceRaw.match(sentenceString) then
        ts, sen = sentenceString.split('!')
        return AisDomainClasses::AisSentence.new(ts, "!#{sen}")
      else
        raise ArgumentError, @@key
      end
    end
  end

  class AisMessageFactory 
    @@key = "ais.message.factory"
    @@patSentenceString = /^ais.sentence,[0-9]{10}\.[0-9]{9},!AIVDM,\d,\d,\d?,[A-B],.*/
    def initialize()
      @timeStamp = ''
      @mesgType  = ''
      @channel   = ''
      @payload   = ''
    end
    def load(aisSentence)
      # input:  raw ais sentence from the base station
      # return: new AisMessage : nil
      # ais single sentence 
      # ais.sentence,1339846648.566813946,!AIVDM,1,1,,B,63@0Wl00UBf006P0p0,4*08
      # ais multi sentence with two parts
      # ais.sentence,1339846648.422811031,!AIVDM,2,1,0,B,53ntof42:3Mph5EG@008uN0<hU10E8000000001B0bo@@5WG0C4m4`30FH0Q,0*19
      # ais.sentence,1339846648.430813074,!AIVDM,2,2,0,B,DU200000000,2*34
      if @@patSentenceString.match(aisSentence) then
        # looks like a ais.sentence, now is it a valid one?
        left, right       = aisSentence.split('!')   # checksum is done from on everything between '!' and '*'
        chkSentence, chk  = right.split('*')           
        if AisChecker::checksum(chkSentence,chk.strip.hex) then 
          # apparently, a correct sentence, as well, so split up and decode it
          key, timestamp, aivdm, number, sequence, order, channel, payload, right = aisSentence.split(',')
          msgType = (AisDecoder::decode(payload[0].chr))[0..5].to_i(2)  # extract message type
          # ---------------------------------------------------------------------
          if number == '1' and sequence == '1' and order == '' then 
            # looks like a single-sentence, so make AisMessage and return it
            return AisDomainClasses::AisMessage.new(timestamp, msgType, channel, payload)
          elsif number == '2' and sequence == '1' then
            # looks like first part of a muli-sentence
            @timeStamp = timestamp 
            @mesgType  = msgType
            @channel   = channel
            @payload   = payload
            return nil
          elsif number == '2' and sequence == '2' then
            # looks like second part of a multi-sentence
            @payload << payload
            return AisDomainClasses::AisMessage.new(@timeStamp, @mesgType, @channel, @payload)
          else
            initialize() # reset state
            return nil
          end # if number == '1' ....
        end
      end
      raise ArgumentError, @@key
    end # def fromRaw
  end # class AisSentenceFactory

  

  class AisVesselFactory
    @@key = "ais.vessel.factory"
    @@patMessageString = /^ais.message,[0-9]{10}\.[0-9]{9},[0-9]{1,2},[A-B],*/
    def load(msgString)
      # ais.message,1340711638.494832039,1,A,14`Vlj0000PBtcpMfqD<U1=f0<<F
      # ais.message,1340711634.786833048,2,A,23aDrRwP00PDWhfMeDwklwwd20SG
      # ais.message,1340711634.974828959,3,A,33aDArhP1UPDOb6MdgOR1wwd21NA
      if @@patMessageString.match(msgString) then
        # looks like a valid ais message string
        key, ts, tp, ch, py = msgString.split(',')
        binPayload = AisDecoder::decode(py)
        mmsi = binPayload[8..37].to_i(2)
        if tp == '5' then
          # static voyage data class A
          type = binPayload[232..239].to_i(2)
          name = AisEncoder.encode(binPayload[112..231])
        elsif tp == '19' then
          # extended position report class B
          type = binPayload[263..270].to_i(2)
          name = AisEncoder.encode(binPayload[143..262])
        else
          raise ArgumentError, @@key
        end
        # correct vessel
        return AisVessel.new(mmsi, ts, type, name)
      end # not a valid message
      raise ArgumentError, @@key
    end # def load()
  end # class AisVesselFactory
  


  class AisActiveFactory
    @@key = "ais.active.factory"
    @@patVesselString = /^ais.vessel,/
    @@patStatusString = /^ais.status,/
    def load(activeString)
      if @@patVesselString.match(activeString) then
        # looks like a vessel message with timestamp
        key, mmsi, timestamp, type, name = activeString.split(',')
      elsif @@patStatusString.match(activeString) then
        # looks like a status message with timestamp
        key, mmsi, timestamp, lat, lon, course, heading, speed, status = activeString.split(',')
      else
        raise ArgumentError, @@key
      end # if ...
      return AisActive.new(mmsi, timestamp)
    end
  end



  class AisStatusFactory
    @@key = "ais.status.factory"
    @@patMessageString = /^ais.message,[0-9]{10}\.[0-9]{9},[0-9]{1,2},[A-B],*/
    def load(msgString)
      if @@patMessageString.match(msgString) then
        key, ts, tp, ch, py = msgString.split(',')
        binPayload = AisDecoder::decode(py)
        mmsi = binPayload[8..37].to_i(2)
        if tp == '1' or tp == '2' or tp == '3' then
          # class A vessels
          lat = binPayload[89..115].to_i(2) / 600_000.0
          lon = binPayload[61..88].to_i(2) / 600_000.0
          course = binPayload[116..127].to_i(2)
          heading = binPayload[128..136].to_i(2)
          speed = binPayload[50..59].to_i(2) / 10.0
          status = binPayload[38..41].to_i(2)
        elsif tp == '18' or tp == '19' then
          # class B vessels
          lat = binPayload[85..111].to_i(2) / 600_000.0
          lon = binPayload[57..84].to_i(2) / 600_000.0
          course = binPayload[112..123].to_i(2)
          heading = binPayload[124..132].to_i(2)
          speed = binPayload[46..55].to_i(2) / 10.0
          status = 15 # class B vessels have no navigation status, default is 15 (not defined)
        else
          raise ArgumentError, @@key
        end
        return AisStatus.new(mmsi, ts, lat, lon, course, heading, speed, status)
      else
        raise ArugemntError, @@key
      end
    end # def load()
  end # class AisStatusFactory

  class AisDestinationFactory
    @@key = "ais.destination.factory"
    @@patMessageString = /^ais.message,[0-9]{10}\.[0-9]{9},[0-9]{1,2},[A-B],*/
    def load(msgString)
      if @@patMessageString.match(msgString) then
        key, ts, tp, ch, py = msgString.split(',')
        binPayload = AisDecoder::decode(py)
        mmsi = binPayload[8..37].to_i(2)
        dest = AisEncoder::encode(binPayload[302..421])
        return AisDestination.new(mmsi, ts, dest)
      else
        raise ArgumentError, @@key
      end
    end
  end # class AisDestinationFactory

end # module AisDomainFactories
