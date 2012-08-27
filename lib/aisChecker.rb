
module AisChecker

  def checksum(msg, value)
    sum = 0	
    msg.each_byte do |c|
      sum^=c
    end
    return sum == value ? true : false
  end

end
