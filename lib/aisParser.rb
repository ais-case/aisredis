
class AisParser
  def initialize()
    @@patSentence = /^[0-9]{10}\.[0-9]{9}!AIVDM,\d,\d,\d?,[A-B],.*/
    @@patMessage  = /^[0-9]{10}\.[0-9]{9},\d,[A-B],.*/
  end
  def isSentence?(sentence)
    if sentence.match(@@patSentence) then
      #looks like we have an ais sentence
      left, aivdm = sentence.split('!')
      payload, check = aivdm.split('*')
      # is it a valid sentence?
      checksum(payload,check.strip.hex) ? true : false
    else
      false
    end
  end
  def isMessage?(message)
    message.match(@@patMessage) ? true : false
  end
  private
  def checksum(msg, value)
    sum = 0	
    msg.each_byte do |c|
      sum^=c
    end
    return sum == value ? true : false
  end
end # AisParser

