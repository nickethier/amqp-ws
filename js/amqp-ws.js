function AMQP() {}

AMQP.Type = {
  ERROR : -1,
  ASSIGNID : 0,
  REQUESTID : 1,
  SETKEYS : 2,
  EVENT : 3,
  START : 4,
  STOP : 5,
  PING : 6,
  PONG : 7
};
AMQP.prototype.handle = function(msg){
  try {
    var json = eval("(" + msg + ")");
  } catch (e) {
    console.log("AMQP: bad msg from server: " + e + msg);
  }
  switch(json.type){
    case this.ERROR:
      console.log("AMQP: error from server: " + json.payload);
      break;

    case AMQP.Type.ASSIGNID:
      this.id = json.payload;
      break;

    case AMQP.Type.EVENT:
      this.post(json.payload);
      break;

    case AMQP.Type.PING:
      this.pong();
      break;

    case AMQP.Type.PONG:
      console.log("AMQP: PONG from server");
      break;

    default:
      console.log("AMQP: unknown msg from server: " + msg);
      break;
  }
};

AMQP.prototype.post = function(msg){
  this.onevent(msg+"\n");
};
AMQP.prototype.pong = function(){
  this.ws.send('{ "id":"' + this.id + '", "type":' + AMQP.Type.PONG + ', "payload":"PONG"}');
};

AMQP.prototype.ping = function(){
  this.ws.send('{ "id":"' + this.id + '", "type":' + AMQP.Type.PING + ', "payload":"PING"}');
};

AMQP.prototype.send = function(msg){
  this.ws.send(msg);
};

AMQP.prototype.setkeys = function(keys){
  this.ws.send('{ "id":"' + this.id + '", "type":' + AMQP.Type.SETKEYS + ', "payload":"'+ keys +'"}');
};

AMQP.prototype.start = function(){
  this.ws.send('{ "id":"' + this.id + '", "type":' + AMQP.Type.START + ', "payload":"START"}');

};

AMQP.prototype.stop = function(){
  this.ws.send('{ "id":"' + this.id + '", "type":' + AMQP.Type.STOP + ', "payload":"STOP"}');
};

AMQP.prototype.disconnect = function(){
  this.ws.close();
}

AMQP.prototype.isConnected = function(){
  return this.ws.readyState == 1;
}

AMQP.prototype.connect = function(host, port){
  try{
    this.ws = new WebSocket("ws://"+host+":"+port+"/");
    var _self = this;
    this.ws.onopen = function(){
      //_self.post("Connection Established!")
      this.send('{"type":'+AMQP.Type.REQUESTID+'}');
      _self.onconnect()
    };

    this.ws.onmessage = function(evt){
      _self.handle(evt.data);
    };

    this.ws.onclose = function(){
      _self.ondisconnect()
    };
  } catch(exception){
    console.log("AMQP: (error) " + exception);
  }
};