$: << File.dirname(__FILE__) + "/../lib/"
require "amqp-ws"
require "amqp"
EM.run do
  AMQP.connect("amqp://guest:guest@localhost:5672") do |client|
    server = AMQP::WS::Server.new(client)
    server.start(:host => "0.0.0.0", :port => 8080)
  end
end