require 'amqp'
class AMQP::WS::Client
  attr_reader :id
  attr_reader :ws
  attr_accessor :channel
  attr_accessor :queue
  attr_accessor :consumer
  attr_accessor :keys
  
  def initialize(options)
    @id = options[:id]
    @channel = options[:channel]
    @ws = options[:ws]
    @queue = @channel.queue("amqp.ws.client.#{@id}", :persistent => false, :auto_delete => true)
    
  end
  
  def PING
    
  end
  
  def PONG
    
  end
  
  def send(msg)
    @ws.send(msg)
  end
  
  def destroy
    @queue.delete
    @channel.close
    @ws.close_websocket
  end
end