package code.game{
	import flash.utils.Dictionary;
	import code.Connection;
	import flash.utils.ByteArray;
	import flash.net.Socket;
	import flash.utils.getTimer;
	import code.Utils;
	import flash.geom.Point;

	//Object has body,id,role,unique


	public class Network{
		public var id:int;
		public var game:Game;
		public var objects:Dictionary;
		public var water_flag:Flag;
		public var fire_flag:Flag;
		public var me:Player;
		public var connection:Connection;
		public var functions:Array;
		public var ready:Boolean;
		public var running:Boolean;
		
		public var team_map:Dictionary;
		public var role_map:Dictionary;
		public var flavor_map:Dictionary;
		
		public var reference_time:Number;
		
		public function Time():Number{
			return (getTimer()*0.001) + reference_time;
		}
		
		public function Network(){
			team_map = new Dictionary();
			team_map["neutral"] = 0;
			team_map["fire"] = 1;
			team_map["water"] = 2;
			team_map[0] = "neutral";
			team_map[1] = "fire";
			team_map[2] = "water";
			
			role_map = new Dictionary();
			role_map["player"] = 1;
			role_map["projectile"] = 2;
			role_map["flag"] = 3;
			role_map[1] = "player";
			role_map[2] = "projectile";
			role_map[3] = "flag";
			
			flavor_map = new Dictionary();
			flavor_map["flag fire"] = 1;
			flavor_map["flag water"] = 2;
			flavor_map["ranged fire"] = 3;
			flavor_map["ranged water"] = 4;
			flavor_map["projectile fire"] = 5;
			flavor_map["projectile water"] = 6;
			flavor_map["melee fire"] = 7;
			flavor_map["melee water"] = 8;
			flavor_map[1] = "flag fire";
			flavor_map[2] = "flag water";
			flavor_map[3] = "ranged fire";
			flavor_map[4] = "ranged water";
			flavor_map[5] = "projectile fire";
			flavor_map[6] = "projectile water";
			flavor_map[7] = "melee fire";
			flavor_map[8] = "melee water";
			
			
			
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
					connection.Add(function(socket:Socket)
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
		
		public function Random():int{
			return Math.floor( Math.random() * (int.MAX_VALUE));
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

		public function AddUser(me:Player){
			this.me = me;
			me.id = game.id;
			game.team = me.team;
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
//The functions that add and remove things......................................................
		public function Remove(unique:int){
			if(objects[unique]){
				delete objects[unique];
			}
		}
		public function Add(object:*){
			if(!object.unique){
				do{
					object.unique = Random();
				}while(objects[object.unique]);
			}
			objects[object.unique] = object;
		}
		public function Action(id:int){
			if(id == game.id){
				var time_of_action = Time();
				connection.Add (function(socket:Socket)
								{
									socket.writeInt(5);
									socket.writeFloat(time_of_action);
								},0,Connection.Nothing);
			}
		}
//End functions that add and remove things......................................................
//Actions ......................................................................................	
		public function Send(id:int,team:String, socket:Socket){
			var obj:*;
			var counter = 0;
			for(obj in objects){
				if(objects[obj]){
					if(objects[obj].id == id){
						counter ++;
					}
				}
			}
			socket.writeInt(game.state_number);
			socket.writeInt(id);
			socket.writeInt(team_map[team]);
			socket.writeFloat(Time());
			socket.writeInt(counter);
			
			for(obj in objects){
				if(objects[obj]){
					if(objects[obj].id == id){
						socket.writeInt(objects[obj].unique);
						socket.writeInt(role_map[objects[obj].role]);
						socket.writeInt(flavor_map[objects[obj].flavor]);
						socket.writeFloat(objects[obj].body.GetPosition().x);
						socket.writeFloat(objects[obj].body.GetPosition().y);
						socket.writeFloat(objects[obj].body.GetLinearVelocity().x);
						socket.writeFloat(objects[obj].body.GetLinearVelocity().y);
						socket.writeFloat(objects[obj].health);
					}
				}
			}
		}
		public function Get(socket:Socket){
			var state_number = socket.readInt();
			var number_of_actions = socket.readInt();
			var number_of_players = socket.readInt();
			
			if(game.state_number != state_number){
				Load();
			}
			
			//read and process the actions
			for(;number_of_actions > 0; number_of_actions--){
				var id = socket.readInt();
				var time = socket.readFloat();
				game.AnimateAction(id,Time()-time);
			}
			//read and process the players
			var obj:*;
			for(obj in objects){
				if(objects[obj]){
					if(objects[obj].id != me.id){
						objects[obj].health = int.MIN_VALUE;//mark everything with minumum health
					}
				}
			}

			for(;number_of_players > 0;number_of_players--){
				var player_id = socket.readInt();
				var player_team = team_map[socket.readInt()];
				var time_of_update = socket.readFloat();
				var counter = socket.readInt();
				for(;counter > 0;counter --){
					var unique = socket.readInt();
					var role = role_map[socket.readInt()];
					var flavor = flavor_map[socket.readInt()];
					var x = socket.readFloat();
					var y = socket.readFloat();
					var vx = socket.readFloat();
					var vy = socket.readFloat();
					var health = socket.readFloat();
					
					var delay = Time() - time_of_update;
					
					x += vx * delay;
					y += vy * delay;
					
					if(objects[unique]){//if it exists in the list
						obj = objects[unique];//easy access
						//check for consistency
						if( (obj.role == role) && (obj.flavor == flavor) && (obj.id == player_id) && (obj.team == player_team))
						{
							//everything is alright, continue
						}else{//collision happened, stuff is weird here
							trace("Network: you basically won the lottery.");
						}
					}else{//create it otherwise
						obj = game.Add(role,flavor,x,y,vx,vy,player_id, unique, player_team);
					}
					game.Change(obj,health,x,y,vx,vy);
				}
			}
			for(obj in objects){
				if(objects[obj]){
					if(objects[obj].id != me.id){
						if(objects[obj].health == int.MIN_VALUE){
							//if its still marked (hasn't been updated by previous code) remove
							objects[obj].Remove();
						}
					}
				}
			}
		}

		public function Start(game:Game){
			this.game = game;
			game.id = id;
		}
		
		public function Load(){
			running = false;
			game.running = false;
			
			connection.Add (function(socket:Socket)
							{
							 	socket.writeInt(7);
					  		},8,function(socket:Socket)
							{
							 	game.state_number = socket.readInt();
								game.level = socket.readInt();
								objects = new Dictionary(true);
								me = null;
								running = true;
								game.Reload();
								StateLoop(game.state_number);
					  		});
		}
		public function Step(){
			connection.Add (function(socket:Socket)
							{
							 	socket.writeInt(3);
								Send(game.id,game.team,socket);
					  		},0,Connection.Nothing);
		}
		public function StateLoop(state_number:int){
			connection.Add (function(socket:Socket)
							{
							 	socket.writeInt(4);
					  		},4,function(socket:Socket){
								connection.Continue(Connection.Nothing,socket.readInt(),function(socket:Socket){
														Get(socket);
														if(running && (game.state_number == state_number)){
															StateLoop(state_number);
														}
													});
							});
		}
		public function Stop(){
			running = false;
			connection.Add (function(socket:Socket){socket.writeInt(0);},0,Connection.Nothing);
		}
//End actions ..................................................................................
	}
}