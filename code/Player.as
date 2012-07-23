package code
{
	import flash.display.MovieClip;
	import Box2D.Dynamics.b2Body;
	import flash.geom.Point;
	import Box2D.Common.Math.b2Vec2;

	public class Player{
		public var game:Game;
		public var sprite:MovieClip;
		public var flavor:String;
		public var body:b2Body;
		public var speed:Number;
		public var airSpeed:Number;
		public var jump:Number;
		public var ground:Boolean;
		public var airSince:Number;
		public var actionSince:Number;
		public var upwards:Number;
		public var downwards:Number;
		public var uphill:Number;
		public var downhill:Number;
		public var NE:Boolean;
		public var NW:Boolean;
		public var cooldown:Number;
		public var power:Number;
		public var role:String;
		public var team:String;
		
		public function Player(body:b2Body, flavor:String, game:Game)
		{
			this.game = game;
			
			role = "player";
			
			this.flavor = flavor;
			this.body = body;
			ground = false;
			NE = false;
			NW = false;
			airSince = 5000;
			actionSince = 5000;
			switch (flavor)
			{
				case "melee fire":
				team = "fire";
				sprite = new PlayerMeleeFire();
				speed = 1;
				airSpeed = 0.3;
				jump = 1.6;//6 units with boost, 5 without
				upwards = 0.1;
				uphill = 1;
				downhill = 0.3;
				downwards = 1;
				
				cooldown = 4000;
				power = 35;
				break;
				//melee fire
				
				case "melee water":
				team = "water";
				sprite = new PlayerMeleeWater();
				speed = 0.8;
				airSpeed = 0.2;
				jump = 1.6;//6 units with boost, 5 without
				upwards = 0.1;
				uphill = 0.8;
				downhill = 0.3;
				downwards = 2;
				
				cooldown = 1000;
				power = 20;
				break;
				//melee water
				
				case "ranged fire":
				team = "fire";
				sprite = new PlayerRangedFire();
				speed = 0.6;
				airSpeed = 0.1;
				jump = 1.33;//5 units with boost, 4 without
				upwards = 0.1;
				uphill = 0.6;
				downhill = 0.3;
				downwards = 1;
				
				cooldown = 100;
				power = 30;
				break;
				//ranged fire
				
				default:
				trace("You wanted: "+flavor+". But that's not an option anymore");
			}
		}
		public function Right(timeStep:Number)
		{
			if(ground)
			{
				if(NW){
					body.ApplyImpulse(new b2Vec2(speed * body.GetMass() * timeStep * 0.06, -uphill * body.GetMass() * timeStep * 0.06),new b2Vec2(0, 0));
				}else if(NE){
					body.ApplyImpulse(new b2Vec2(speed * body.GetMass() * timeStep * 0.06, +downhill * body.GetMass() * timeStep * 0.06),new b2Vec2(0, 0));
				}else{
					body.ApplyImpulse(new b2Vec2(speed * body.GetMass() * timeStep * 0.06, -upwards * body.GetMass() * timeStep * 0.06),new b2Vec2(0, 0));
				}
			}else{
				body.ApplyImpulse(new b2Vec2(airSpeed * body.GetMass() * timeStep * 0.06, 0),new b2Vec2(0, 0))
			}
		}
		public function Left(timeStep:Number)
		{
			if(ground)
			{
				if(NE){
					body.ApplyImpulse(new b2Vec2(-speed * body.GetMass() * timeStep * 0.06, -uphill * body.GetMass() * timeStep * 0.06),new b2Vec2(0, 0));
				}else if(NW){
					body.ApplyImpulse(new b2Vec2(-speed * body.GetMass() * timeStep * 0.06, +downhill * body.GetMass() * timeStep * 0.06),new b2Vec2(0, 0));
				}else{
					body.ApplyImpulse(new b2Vec2(-speed * body.GetMass() * timeStep * 0.06, -upwards * body.GetMass() * timeStep * 0.06),new b2Vec2(0, 0));
				}
			}else{
				body.ApplyImpulse(new b2Vec2(-airSpeed * body.GetMass() * timeStep * 0.06, 0),new b2Vec2(0, 0));
			}
		}
		public function Jump(timeStep:Number)
		{
			if(airSince < 160)
			{
				body.ApplyImpulse(new b2Vec2(0, -jump * body.GetMass() * timeStep * 0.06),new b2Vec2(0, 0));
			}
		}
		public function Down(timeStep:Number){
			if(ground){
				body.ApplyImpulse(new b2Vec2(0, downwards * body.GetMass() * timeStep * 0.06),new b2Vec2(0, 0));
			}
		}
		public function Action(x:Number, y:Number){
			var l = Math.sqrt(x*x + y*y);
			if(l==0){
				l=1;//no divide by 0 errors
			}
			if(actionSince > cooldown){
				actionSince = 0;
				switch (flavor)
				{
					case "melee fire":
					body.ApplyImpulse(new b2Vec2(power * x/l * body.GetMass(), power * y/l * body.GetMass() ),new b2Vec2(0, 0));
					break;
					//melee fire
					case "melee water":
					body.ApplyImpulse(new b2Vec2(power * x/l * body.GetMass(), power * y/l * body.GetMass() ),new b2Vec2(0, 0));
					break;
					//melee water
					case "ranged fire":
					game.box2d.AddProjectile(new Point(body.GetPosition().x,body.GetPosition().y),new Point(power * x/l, power * y/l), "projectile fire");
					break;
					default:
					trace("No ability for "+flavor+" yet.");
				}
			}
		}
	}
}