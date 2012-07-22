package code
{
	import flash.display.MovieClip;
	import Box2D.Dynamics.b2Body;
	import flash.geom.Point;
	import Box2D.Common.Math.b2Vec2;

	public class Player{
		//todo: extend the class to the different kinds of players
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
		public var uphill:Number;
		public var downhill:Number;
		public var NE:Boolean;
		public var NW:Boolean;
		public var cooldown:Number;
		public var melee_power:Number;
		
		public function Player(body:b2Body, flavor:String = "melee")
		{
			this.flavor = flavor;
			this.body = body;
			ground = false;
			NE = false;
			NW = false;
			airSince = 5000;
			actionSince = 5000;
			switch (flavor)
			{
				case "melee":
				sprite = new PlayerMelee();
				speed = 1;
				airSpeed = 0.3;
				jump = 1.6;//6 units with boost, 5 without
				upwards = 0.1;
				uphill = 1;
				downhill = 0.3;
				
				cooldown = 4000;
				melee_power = 20;
				break;
				
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
		public function Action(x:Number, y:Number){
			var l = Math.sqrt(x*x + y*y);
			switch (flavor)
			{
				case "melee":
				if(actionSince > cooldown){
					actionSince = 0;
					body.ApplyImpulse(new b2Vec2(melee_power * x/l * body.GetMass(), melee_power * y/l * body.GetMass() ),new b2Vec2(0, 0));
				}
				break;
				
			}
		}
	}
}