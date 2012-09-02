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
		public var connection:Connection;
		public var functions:Array;
		public var ready:Boolean;
		public var running:Boolean;
		
		public var team_map:Dictionary;
		public var role_map:Dictionary;
		public var flavor_map:Dictionary;
		
		public var reference_time:Number;
		public var reference_time_count:int;
		
		public var action_buffer:Number;
		public var damage_buffer:Array;
		public var flag_update:FlagAction;
		
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
			reference_time_count = 0;
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
											reference_time_count = 1;
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
			return Math.floor( Math.random() * (int.MAX_VALUE-1) + 1);
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
		public function Action(state_number:int,id:int){
			if(id == game.id){
				action_buffer = Time();
			}
		}
//End functions that add and remove things......................................................
//Actions ......................................................................................	
		public function Send(state_number:int, id:int,team:String, socket:Socket){
			var obj:*;
			var counter = 0;
			for(obj in objects){
				if(objects[obj]){
					if(objects[obj].id == id){
						counter ++;
					}
				}
			}
			socket.writeInt(state_number);
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
			var number_of_damages = socket.readInt();
			var number_of_players = socket.readInt();
			
			
			//read and process the actions
			for(;number_of_actions > 0; number_of_actions--){
				var temp_unique = socket.readInt();
				var action_time = socket.readFloat();
				game.AnimateAction(temp_unique,Time()-action_time);
			}
			//read and process the actions
			for(;number_of_damages > 0; number_of_damages--){
				var damage_time = socket.readFloat();
				var damage = socket.readFloat();
				var target = socket.readInt();
				var source = socket.readInt();
				game.Damage(damage_time,damage,target,source);
			}
			//read and process the players
			var obj:*;
			for(obj in objects){
				if(objects[obj]){
					if(objects[obj].id != game.id){
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
					
					
					
					if(objects[unique]){//if it exists in the list
						obj = objects[unique];//easy access
						//check for consistency
						if( (obj.role == role) && (obj.flavor == flavor) && (obj.id == player_id))
						{
							game.Change(obj,health,x,y,vx,vy,delay);
							//everything is alright, continue
						}else{//collision happened, stuff is weird here
							trace("Network: you basically won the lottery.");
						}
					}else{//create it otherwise
						obj = game.Add(role,flavor,x,y,vx,vy,player_id, unique, player_team, health);
						if(obj){
							game.Set(obj,health,x,y,vx,vy,delay);
						}
					}
					
				}
			}
			for(obj in objects){
				if(objects[obj]){
					if(objects[obj].id != game.id){
						if(objects[obj].health == int.MIN_VALUE){
							//if its still marked (hasn't been updated by previous code) remove
							objects[obj].Remove();
						}
					}
				}
			}
			//read and process the flags
			var flag_x,flag_y,flag_carry;
			//fire flag first
			flag_x = socket.readFloat();
			flag_y = socket.readFloat();
			flag_carry = socket.readInt();
			if((!(objects[flag_carry])) && flag_carry){
				flag_carry = -1;
			}
			if(flag_carry == 0){
				fire_flag.NetworkUpdate(null,fire_flag.origin.x,fire_flag.origin.y);
			}else if(flag_carry == -1){
				fire_flag.NetworkUpdate(null,flag_x,flag_y);
			}else{
				fire_flag.NetworkUpdate(objects[flag_carry],flag_x,flag_y);
			}
			//water flag second
			flag_x = socket.readFloat();
			flag_y = socket.readFloat();
			flag_carry = socket.readInt();
			if((!(objects[flag_carry])) && flag_carry){
				flag_carry = -1;
			}
			if(flag_carry == 0){
				water_flag.NetworkUpdate(null,water_flag.origin.x,water_flag.origin.y);
			}else if(flag_carry == -1){
				water_flag.NetworkUpdate(null,flag_x,flag_y);
			}else{
				water_flag.NetworkUpdate(objects[flag_carry],flag_x,flag_y);
			}
			
			
			if(game.state_number != state_number){
				Load();
			}
		}
		public function Damage(state_number:int,damage:Number,target_unique:int,source_unique:int){
			var temp = new DamageData();
			temp.time = Time();
			temp.target = target_unique;
			
			temp.source = source_unique;
			temp.damage = damage;
			if(objects[target_unique]){
				temp.target_id = objects[target_unique].id;
				damage_buffer.push(temp);
			}
		}
		
		public function DropFlag(state_number:int,flag:Flag){
			flag_update = new FlagAction();
			flag_update.team = flag.team;
			flag_update.x = flag.body.GetPosition().x;
			flag_update.y = flag.body.GetPosition().y;
			flag_update.unique = -1;
		}
		public function PickFlag(state_number:int,flag:Flag){
			if(game.me){
				if(flag.carry.unique == game.me.unique){
					flag_update = new FlagAction();
					flag_update.team = flag.team;
					flag_update.x = flag.body.GetPosition().x;
					flag_update.y = flag.body.GetPosition().y;
					flag_update.unique = flag.carry.unique;
				}
			}
			
		}
		public function ResetFlag(state_number:int,flag:Flag){
			flag_update = new FlagAction();
			flag_update.team = flag.team;
			flag_update.x = flag.body.GetPosition().x;
			flag_update.y = flag.body.GetPosition().y;
			flag_update.unique = 0;
		}
		public function Win(state_number:int,team:String){
			if(connection){
				connection.Add (function(socket:Socket)
								{
									socket.writeInt(9);
									socket.writeInt(state_number);
									socket.writeInt(team_map[team]);
								},0,Connection.Nothing);
			}
		}
		public function Start(game:Game){
			this.game = game;
			game.id = id;
		}
		
		public function Load(){
			if(connection){
				running = false;
				game.running = false;
				
				connection.Add (function(socket:Socket)
								{
									socket.writeInt(7);
								},8,function(socket:Socket)
								{
									var state_number = socket.readInt();
									var level = socket.readInt();
									objects = new Dictionary(true);
									running = true;
									action_buffer = 0;
									damage_buffer = new Array();
									flag_update = null;
									
									game.Reload(state_number,level);
									StateLoop(state_number);
								});
			}else{//no connection means its in tutorial mode, so do nothing
				objects = new Dictionary(true);
				running = true;
				action_buffer = 0;
				flag_update = null;
			}
		}

		public function StateLoop(state_number:int){
			var time_of_sent = getTimer();
			connection.Add (function(socket:Socket)
							{
								//Network "me" update
								var team;
								if(game.me){
									team = game.me.team;
								}else{
									team = "neutral";
								}
								socket.writeInt(3);
								Send(state_number,id,team,socket);
								//Action updates
								if(game.me){
									if(action_buffer){
										socket.writeInt(5);
										socket.writeInt(state_number);
										socket.writeInt(game.me.unique);
										socket.writeFloat(action_buffer);
									}
								}
								action_buffer = 0;
								//Damage updates
								while(damage_buffer.length){
									var damage = damage_buffer.shift();
									socket.writeInt(10);
									socket.writeInt(state_number);
									socket.writeFloat(damage.time);
									socket.writeFloat(damage.damage);
									socket.writeInt(damage.target_id);
									socket.writeInt(damage.target);
									socket.writeInt(damage.source);
								}
								//Flag updates
								if(flag_update){
									socket.writeInt(8);
									socket.writeInt(state_number);
									socket.writeInt(team_map[flag_update.team]);
									socket.writeFloat(flag_update.x);
									socket.writeFloat(flag_update.y);
									socket.writeInt(flag_update.unique);
									flag_update = null;
								}
								//Synchronyze:
								socket.writeInt(1);
								//Expect state:
							 	socket.writeInt(4);
					  		},8,function(socket:Socket){
								var sync_time = socket.readFloat();
								connection.Continue(Connection.Nothing,socket.readInt(),function(socket:Socket){
														Get(socket);
														game.lag_array.push(getTimer() - time_of_sent);
														if(running && (game.state_number == state_number)){
															StateLoop(state_number);
														}
														var round_trip_time = (getTimer()*0.001) - time_of_sent * 0.001;
														var temp_time = sync_time + round_trip_time/2 - (getTimer()*0.001);
														reference_time = (reference_time * reference_time_count + temp_time) / (reference_time_count + 1);
														reference_time_count++;
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

class FlagAction{
	public var team:String;
	public var x:Number;
	public var y:Number;
	public var unique:int;
}

class DamageData{
	public var damage:Number;
	public var source:int;
	public var target:int;
	public var target_id:int;
	public var time:Number;
}