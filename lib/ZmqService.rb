require 'rubygems'
require 'ffi-rzmq'

class ZmqPub
  def initialize(address, topic)
    @address = address
    @topic   = topic
    @context = ZMQ::Context.new(1)
    @socket  = @context.socket(ZMQ::PUB)
    @socket.bind(address)
  end
  def puts(msg)
    @socket.send_string("#{@topic} #{msg}")
  end
end

class ZmqSub
  def initialize(address, topic)
    @address = address
    @topic   = topic
    @context = ZMQ::Context.new(1)
    @socket  = @context.socket(ZMQ::SUB)
    @socket.connect(address)
    @socket.setsockopt(ZMQ::SUBSCRIBE, topic)
  end
  def gets
    msg = ''
    @socket.recv_string(msg)
    return msg
  end
end
