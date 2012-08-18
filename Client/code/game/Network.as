package code.game{
	import flash.utils.Dictionary;
	import code.Connection;
	import flash.utils.ByteArray;
	import flash.net.Socket;
	import flash.utils.getTimer;

	public class Network{
		public var id:uint;
		public var game:Game;
		public var objects:Dictionary;
		public var water_flag:Flag;
		public var fire_flag:Flag;
		public var me:Player;
		public var connection:Connection;
		public var functions:Array;
		public var ready:Boolean;
		
		public var reference_time:Number;
		
		public function Time():Number{
			return (getTimer()*0.001) + reference_time;
		}
		
		public function Network(){
			functions = new Array();
			ready = false;
			reference_time = 0;
			id = 0;
			connection = null;
		}
		
		public function Connect(address:String,port:int,main_id:ByteArray){
			var round_trip_time:Number;
			connection = new Connection(address,port);
			var wait_for_1_or_retry = function(socket:Socket){
				var result = socket.readInt();
				if(result == 1){//1 success, 2 keep listening, 0 fail
					connection.Continue(function(socket:Socket)
										{
											socket.writeInt(1);
											round_trip_time = (getTimer()*0.001);
										},4,function(socket:Socket)
										{
											round_trip_time = (getTimer()*0.001) - round_trip_time;
											reference_time = socket.readFloat() + round_trip_time/2 - (getTimer()*0.001);
											trace("Lag received as:",round_trip_time/2);
											connection.Continue(function(socket:Socket)
																{
																	socket.writeInt(2);
																},4,function(socket:Socket)
																{
																	id = socket.readInt();
																	Ready()
																});
										});
					
				}else if(result ==2){
					trace("Waiting for a responce from gameserver.");
					connection.Continue(Connection.Nothing,4,function(socket:Socket)
										{
											wait_for_1_or_retry(socket);
										});
					
				}else{
					trace("Game not found.");
				}
			};
			
			connection.Add (function(socket:Socket)
							{
							 	socket.writeBytes(main_id,0,32);
					  		},4,function(socket:Socket)
							{
								wait_for_1_or_retry(socket);
						  	});
		}
		public function Start(game:Game){
			this.game = game;
			objects = new Dictionary(true);
			game.id = id;
			trace("Network: todo");
		}
		public function Random():uint{
			return Math.floor( Math.random() * (uint.MAX_VALUE - uint.MIN_VALUE) + uint.MIN_VALUE );
		}
		public function OnReady(f:Function){
			functions.push(f);
			if(ready){
				Ready();
			}
		}
		private function Ready(){
			ready = true;
			while(functions.length){
				functions.shift()();
			}
		}
//The functions that add and remove things......................................................
		public function Remove(unique:uint){
			if(objects[unique]){
				delete objects[unique];
			}
		}
		public function Add(object:*){
			do{
				object.unique = Random();
			}while(objects[object.unique]);
			objects[object.unique] = object;
		}
		public function AddUser(me:Player){
			this.me = me;
			me.id = game.id;
		}
		public function AddFlag(flag:Flag){
			if(flag.team == "fire"){
				fire_flag = flag;
			}else if(flag.team == "water"){
				water_flag = flag;
			}else{
				throw ("Network: wtf, there is no " + flag.team + " team.");
			}
			
		}
//End functions that add and remove things......................................................
//Actions ......................................................................................	
		public function Send(id:uint){
			var obj:*;
			for(obj in objects){
				if(objects[obj]){
					if(objects[obj].id == id){
						//todo
					}
				}
			}
		}

//End actions ..................................................................................
	}
}