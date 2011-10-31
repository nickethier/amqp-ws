require "em-websocket"
require "amqp"
require "uuid"
require "amqp-ws/message"
require "amqp-ws/client"

class AMQP::WS::Server
  require "amqp-ws/message_types"
  def initialize(connection)
    @amqp_connection = connection
    @clients = {}
    @uuid = UUID.new
  end
  
  def start(options)
    EM.run do
      @server = EM::WebSocket.start(:host => options[:host], :port => options[:port]) do |ws|
        ws.onopen do
          @clients[ws] = AMQP::WS::Client.new(
            :id => @uuid.generate, 
            :channel => AMQP::Channel.new(@amqp_connection), 
            :ws => ws
          )
        end
        ws.onmessage do |payload|
          handle(AMQP::WS::Message.new(:json => payload), @clients[ws])
        end
        
        ws.onclose do
          @clients[ws].destroy
          @clients[ws] = nil
        end
        
      end
    end
  end
  
  def stop
    @amqp_connection.close
    @server.stop
    EM.stop
  end
  

  def handle(msg, client)
    puts msg.inspect
    case msg.type
    when ERROR
      #log error here
    when REQUESTID
      client.send({:type => ASSIGNID, :id => client.id, :payload => client.id}.to_json)
    when SETKEYS
      client.keys = []
      msg.payload.split(',').each do | key |
        client.keys << key
      end
    when START
      client.keys.each do |key|
        client.queue.bind("logstash", :routing_key => key)
      end
      client.queue.subscribe do |metadata, payload|
        msg = RosieWS::Message.new(:type => EVENT, :id => client.id, :payload => payload)
        client.send(msg.to_json)
      end
    when PING
      client.send({:type => PONG, :id => client.id, :payload => "PONG"}.to_json);
    when STOP
      client.queue.unbind
    end
  end
end

