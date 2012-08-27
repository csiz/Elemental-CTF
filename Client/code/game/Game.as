package code.game
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
    import flash.display.MovieClip;
	import flash.utils.getTimer;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Dynamics.b2Fixture;

	
	public class Game extends MovieClip{
		//Game class starts here...............................................................*
		//timer
		var time:Number;
		var timeStep:Number;
		//box2d
		public var box2d:Box2d;
		//level data
		public var levels:Levels;
		public var win:Boolean;
		//scene data
		public var movie:MovieClip;
		public var ui:MovieClip;
		//player data
		public var me:Player;
		public var id:int;
		public var team:String;
		public var player_list:Dictionary;
		public var projectile_list:Dictionary;
		public var flag_list:Dictionary;
		//newtork data
		public var network:Network;
		//user interface
		public var w:Boolean;
		public var a:Boolean;
		public var s:Boolean;
		public var d:Boolean;
		public var space:Boolean;
		public var mouse:Boolean;
		public var control:String;
		public var speed:Number;
		//other
		public var running:Boolean;
		public var state_number:int;
		public var level:int;
		public var ready_timer:Number;
		public var Ready:Function;
		
		public var lag_array:Array;
		public var fps_array:Array;
		
		public var lag:Number;
		public var fps:Number;
		
		
		public function Game(network:Network = null)
        {
			if(network){
				this.network = network;
			}else{
				//todo, tutorial/non server game
			}
			//init data:
			id = 0;
			team = "neutral";
			running = false;
			
			levels = new Levels();
			
			//user interface vars
			w = false;
			a = false;
			s = false;
			d = false;
			space = false;
			mouse = false;
			control = "keyboard";
			speed = 0.3;
			
			
			
		}
		
		public function Start(){
			stage.addEventListener(KeyboardEvent.KEY_DOWN,KeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP,KeyUp);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,MouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP,MouseUp);
			addEventListener(Event.ENTER_FRAME,GameLoop);
			
			network.Start(this);
			network.Load();
		}
		
		public function Reload(state_number:int,level:int){
			//first we clear everything
			removeChildren();
			//then we put everything back
			lag_array = new Array();
			lag_array.push(0);
			fps_array = new Array();
			lag = 0;
			fps = 0;
			win = false;
			ready_timer = 0;
			Ready = null;
			this.state_number = state_number;
			this.level = level;
			
			movie = new MovieClip();
			addChild(movie);
			
			ui = new UI(this);
			addChild(ui);
			
			me = null;
			
			player_list = new Dictionary(true);
			projectile_list = new Dictionary(true);
			flag_list = new Dictionary(true);
			box2d = new Box2d(levels,movie,this);

			box2d.LoadLevel(level);
			box2d.AddFlag("water");
			box2d.AddFlag("fire");
			
			time = getTimer();
			running = true;
			
			ui.ChosePlayer();
		}
		
		public function Spawn(flavor:String,type:String){
			me = box2d.AddPlayer(flavor,id);
			if(type == "ranged"){
				speed = 0.03;//ranged
			}else if(type == "melee"){
				speed = 0.07;//melee
			}
		}
		public function Kill(time:Number = 0 /*todo*/){
			ready_timer = 3000;//be dead for 10 seconds before respawn
			me = null;
			ui.ChosePlayer();
			//todo
		}
		
		public function Add(role:String, flavor:String, x:Number, y:Number, vx:Number, vy:Number, id:int, unique:int, team:String){
			//when adding new types, you have to modify 3 things:
			//in constructor at Player/Projectile make a case:whatever fire...
			//in Network at flavor_map
			
			switch (role){
				case "player":
				return box2d.AddPlayer(flavor, id, unique);
				break;
				case "projectile":
				return box2d.AddProjectile(new Point(x,y), new Point(vx,vy),flavor,id,unique);
				break;
			}
		}
		public function Change(obj:*, health:Number, x:Number, y:Number, vx:Number, vy:Number){
			obj.health = health;
			if(obj.role == "player"){
				if(obj.health <= 0){
					obj.Kill();
				}
			}
			box2d.ChangePositionAndSpeed(obj.body,x,y,vx,vy);
		}
		public function AnimateAction(id:int,elapsed_time:Number){
			//todo animations
		}
		
		protected function GameLoop(event:Event):void
        {	
			if(!running){
				return;
			}
			
			//Game loop starts here............................................................*
			//attacks
			var contactEdge:b2ContactEdge;
			var contact:b2Contact;
			var hit:b2Body;
			var fixture_hit:b2Fixture;
			var attacks:Dictionary = new Dictionary();
			//players
			for(body in player_list){
				if(player_list[body]){
					if((body.GetUserData().attackTimer > 300) && body.GetUserData().alive ){
						contactEdge = body.GetContactList();
						while(contactEdge){
							contact = contactEdge.contact;
							if(contact.IsTouching()){
								if(contact.GetFixtureA().GetBody() != body){
									hit = contact.GetFixtureA().GetBody();
								}
								if(contact.GetFixtureB().GetBody() != body){
									hit = contact.GetFixtureB().GetBody();
								}
								//hit is the thing that "body" hit
								if(hit.GetUserData().role == "player"){
									if(body.GetUserData().team != hit.GetUserData().team){
										attacks[hit.GetUserData()] = {damage:body.GetUserData().attack, id:body.GetUserData().id};
										body.GetUserData().attackTimer = 0;
										break;
									}
								}
							}
							contactEdge = contactEdge.next;
						}
					}
				}
			}
			//projectiles
			for(body in projectile_list){
				if(projectile_list[body]){
					contactEdge = body.GetContactList();
					while(contactEdge){
						contact = contactEdge.contact;
						if(contact.IsTouching()){
							if(contact.GetFixtureA().GetBody() != body){
								hit = contact.GetFixtureA().GetBody();
							}
							if(contact.GetFixtureB().GetBody() != body){
								hit = contact.GetFixtureB().GetBody();
							}
							//hit is the thing that "body" hit
							if(hit.GetUserData().role == "player"){
								if(body.GetUserData().team != hit.GetUserData().team){
									attacks[hit.GetUserData()] = {damage:body.GetUserData().attack, id:body.GetUserData().id};
									body.GetUserData().Remove();
									break;
								}
							}
						}
						contactEdge = contactEdge.next;
					}
				}
			}
			//apply damage
			var player:*;
			for(player in attacks){
				player.Attack(attacks[player].damage,attacks[player].id);
			}
			//end attacks
			//flags
			for(body in flag_list){
				if(flag_list[body]){
					contactEdge = body.GetContactList();
					while(contactEdge){
						contact = contactEdge.contact;
						if(contact.IsTouching()){
							if(contact.GetFixtureA().GetBody() != body){
								hit = contact.GetFixtureA().GetBody();
							}
							if(contact.GetFixtureB().GetBody() != body){
								hit = contact.GetFixtureB().GetBody();
							}
							//hit is the thing that "body" hit
							if(hit.GetUserData().role == "player"){
								if(hit.GetUserData().alive){
									if(body.GetUserData().team != hit.GetUserData().team){
										if(!body.GetUserData().carry){
											body.GetUserData().Pick(hit.GetUserData());
										}
									}else{
										if(!body.GetUserData().carry){
											if(hit.GetUserData().flag){
												Win(hit.GetUserData().team);
											}
											//if the enemy drops the flag and you reach it you still win
											body.GetUserData().Reset();
										}
										if(hit.GetUserData().flag){
											Win(hit.GetUserData().team);
										}
									}
								}
							}
						}
						contactEdge = contactEdge.next;
					}
				}
			}
			//end flags
			//lava and fire deaths
			for(body in player_list){
				if(player_list[body]){
					if(body.GetUserData().alive){
						contactEdge = body.GetContactList();
						while(contactEdge){
							contact = contactEdge.contact;
							if(contact.IsTouching()){
								if(contact.GetFixtureA().GetBody() != body){
									fixture_hit = contact.GetFixtureA();
								}
								if(contact.GetFixtureB().GetBody() != body){
									fixture_hit = contact.GetFixtureB()
								}
								//hit is the thing that "body" hit
								if(fixture_hit.GetUserData()){
									if(fixture_hit.GetUserData().role == "brick"){
										if(fixture_hit.GetUserData().flavor == "ice"){
											if(body.GetUserData().team == "fire"){
												body.GetUserData().Kill();
											}
										}
										if(fixture_hit.GetUserData().flavor == "lava"){
											if(body.GetUserData().team == "water"){
												body.GetUserData().Kill();
											}
										}
									}
								}
							}
							contactEdge = contactEdge.next;
						}
					}
				}
			}
			//end lava and fire
			
            //Game loop ends here..............................................................*
        	//Loop updates.....................................................................
			//fps update
			timeStep = - time + (time = getTimer() );
			
			//players update
			var body:*;
			for(body in player_list){
				if(player_list[body]){
					player_list[body].Update(timeStep);
				}
			}
			//Box2d
			box2d.Update(timeStep);
			//Game updates
			//execute ready functions if ready
			ready_timer -= timeStep;
			if(ready_timer <= 0){
				if(Ready != null){
					Ready();
					Ready = null;
				}
			}
			//check me state
			if(me){
				if(!me.alive){
					Kill();
				}
			}
			
			//Loop updates end.................................................................
			if(me){
				//camera
				//Centering screen, slowly
				//movie.x += ( ( 325  -me.sprite.x - ( me.body.GetLinearVelocity().x * 40 ) ) - movie.x ) * 0.007;
				//movie.y += ( ( 200  -me.sprite.y - ( me.body.GetLinearVelocity().y * 20 ) ) - movie.y ) * 0.006;
				if(control == "keyboard"){
					movie.x += ( ( 325  -me.sprite.x ) - movie.x ) * speed;
					movie.y += ( ( 200  -me.sprite.y ) - movie.y ) * speed;
				}
				if(control == "mouse"){
					movie.x += ( ( ( 325  -me.sprite.x ) - (mouseX - 325)*0.5 ) - movie.x ) * speed;
					movie.y += ( ( ( 200  -me.sprite.y ) - (mouseY - 200)*0.5 ) - movie.y ) * speed;
				}
				//controls
				var temp_x:Number;
				var temp_y:Number;
				if(a){
					me.Left(timeStep);
				}
				if(d){
					me.Right(timeStep);
				}
				if(w){
					me.Jump(timeStep);
				}
				if(s){
					me.Down(timeStep);
				}
				if(mouse){
					
					temp_x = mouseX - me.sprite.x - movie.x;
					temp_y = mouseY - me.sprite.y - movie.y;
					
					temp_x/=7;
					temp_y/=7;
					me.Action(temp_x,temp_y);
				}
				if(space){
					temp_x = me.body.GetLinearVelocity().x;
					temp_y = me.body.GetLinearVelocity().y;
					
					me.Action(temp_x,temp_y);
				}
			}else{
				//camera work, individual
				if(control == "keyboard"){
					speed = 10;
					if(a){
						movie.x += speed;
					}
					if(d){
						movie.x -= speed;
					}
					if(w){
						movie.y += speed;
					}
					if(s){
						movie.y -= speed;
					}
				}
				if(control == "mouse"){
					speed = 0.07;
					movie.x += ( - (mouseX - 325)*0.5 ) * speed;
					movie.y += ( - (mouseY - 200)*0.5 ) * speed;
				}
			}
			
			//Message //testing
			//ui.message.text = (1000/timeStep).toFixed(2);
			if(me){
				ui.message.text = me.health.toFixed(0);
			}
			//Lag and fps
			var i;
			fps_array.push(timeStep);
			fps = 1;
			while(fps_array.length > 60){
				fps_array.shift();
			}
			for(i in fps_array){
				fps += fps_array[i];
			}
			fps = (1000/fps) * fps_array.length;
			ui.fps.text = fps.toFixed(0);
			
			lag = 0;
			while(lag_array.length > 60){
				lag_array.shift();
			}
			for(i in lag_array){
				lag += lag_array[i];
			}
			lag = lag / lag_array.length;
			ui.lag.text = lag.toFixed(0);
			
			
			
		}
		public function Win(team:String){
			if(!win){
				trace("Team: " + team + " won!");
				network.Win(state_number,team);
				win = true;
			}
		}
		
		//Game controls:
		protected function MouseDown(event:MouseEvent):void{
			mouse = true;
			control = "mouse";
		}
		protected function MouseUp(event:MouseEvent):void{
			mouse = false;
		}
		protected function KeyDown(event:KeyboardEvent):void
		{
			switch (event.keyCode)
			{
				case Keyboard.W:
				case Keyboard.UP:
				w=true;
				break;
				case Keyboard.A:
				case Keyboard.LEFT:
				a=true;
				break;
				case Keyboard.S:
				case Keyboard.DOWN:
				s=true;
				break;
				case Keyboard.D:
				case Keyboard.RIGHT:
				d=true;
				break;
				case Keyboard.SPACE:
				space=true;
				control = "keyboard";
				break;
			}
		}
		
		protected function KeyUp(event:KeyboardEvent):void
		{
			switch (event.keyCode)
			{
				case Keyboard.W:
				case Keyboard.UP:
				w=false;
				break;
				case Keyboard.A:
				case Keyboard.LEFT:
				a=false;
				break;
				case Keyboard.S:
				case Keyboard.DOWN:
				s=false;
				break;
				case Keyboard.D:
				case Keyboard.RIGHT:
				d=false;
				break;
				case Keyboard.SPACE:
				space=false;
				break;
			}
		}
		//Game class ends here.................................................................*
	}
}