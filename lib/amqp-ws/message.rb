require "json"

class AMQP::WS::Message
  

  attr_reader :type
  attr_reader :id
  attr_reader :payload
  
  def initialize (options)
    if options[:json]
      from_json options[:json]
    else
      @type = options[:type]
      @id = options[:id]
      @payload = options[:payload]
    end
  end
  
  def to_json
    {
      :type     => @type,
      :id       => @id,
      :payload  => @payload
    }.to_json
  end
  
  def from_json (json)
    puts json
    body = JSON.parse(json)
    puts body
    @type = body["type"]
    @id = body["id"]
    @payload = body["payload"]
  end
  
end
  
    