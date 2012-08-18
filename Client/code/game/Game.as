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

	
	public class Game extends MovieClip{
		//Game class starts here...............................................................*
		//timer
		var time:Number;
		var timeStep:Number;
		//box2d
		public var box2d:Box2d;
		//level data
		public var levels:Levels;
		//scene data
		public var movie:MovieClip;
		public var ui:MovieClip;
		//player data
		public var me:Player;
		public var id:int;
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
		
		
		
		public function Game(network:Network = null)
        {
			if(network){
				this.network = network;
			}else{
				//todo, tutorial/non server game
			}
			//init data:
			id = 0;
			
			movie = new MovieClip();
			addChild(movie);
			
			ui = new UI();
			addChild(ui);
			
			player_list = new Dictionary(true);
			projectile_list = new Dictionary(true);
			flag_list = new Dictionary(true);
			
			levels = new Levels();
			box2d = new Box2d(levels,movie,this);
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
			network.Start(this);
			
			//controls...
            addEventListener(Event.ENTER_FRAME,GameLoop);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,KeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP,KeyUp);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,MouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP,MouseUp);
			
			
			box2d.LoadLevel(0);
			me = box2d.AddPlayer(levels.GetSpawn(0,"team fire"), "ranged fire");
			network.AddUser(me);
			speed = 0.03;//ranged
			//speed = 0.07;//melee
			
			box2d.AddPlayer(new Point(3,3), "melee fire");
			box2d.AddPlayer(levels.GetSpawn(0,"team water"), "melee water");
			box2d.AddFlag(levels.GetSpawn(0,"water flag"),"water");
			box2d.AddFlag(levels.GetSpawn(0,"fire flag"),"fire");
			
			time = getTimer();
		}
		
		protected function GameLoop(event:Event):void
        {	
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
			//Game loop starts here............................................................*
			//attacks
			var contactEdge:b2ContactEdge;
			var contact:b2Contact;
			var hit:b2Body;
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
						contactEdge = contactEdge.next;
					}
				}
				//end flags
			}
            //Game loop ends here..............................................................*
        	//loop updates
			//fps update
			timeStep = - time + (time = getTimer() );
			
			//players update
			var body:*;
			for(body in player_list){
				if(player_list[body]){
					player_list[body].actionSince += timeStep;
					player_list[body].attackTimer +=timeStep;
					if(player_list[body].alive){
						player_list[body].health += player_list[body].regen * timeStep/1000;
						if(player_list[body].health > player_list[body].maxHealth){
							player_list[body].health = player_list[body].maxHealth;
						}
					}
				}
			}
			//Box2d
			box2d.Update(timeStep);
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
			
			//Message //testing
			ui.message.text = (1000/timeStep).toFixed(2);
			//message.text = me.health.toFixed(5);
		}
		public function Win(team:String){
			trace("Team: " + team + " won!");
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