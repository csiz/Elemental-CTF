package code.game{
	import Box2D.Dynamics.*;
	import flash.display.MovieClip;
	import Box2D.Common.Math.b2Vec2;

	public class Projectile{
		public var body:b2Body;
		public var flavor:String;
		public var game:Game;
		public var role:String;
		public var team:String;
		public var sprite:MovieClip;
		public var hits:int;
		public var attack:Number;
		public var time:Number;
		public var id:uint;
		public var unique:uint;
		
		public function Projectile(body:b2Body, flavor:String, game:Game, id:uint){
			this.flavor = flavor;
			this.body = body;
			this.game = game;
			role = "projectile";
			hits = 0;
			time = 0;
			this.id = id;
			unique = 0;
			
			switch(flavor){
				case "projectile fire":
				team = "fire";
				attack = 120;
				sprite = new ProjectileFire();
				break;
				
				case "projectile water":
				team = "water";
				attack = 40;
				sprite = new ProjectileWater();
				break;
			}
			
			game.movie.addChild(sprite);
			game.network.Add(this);
		}
		public function Remove(){
			game.box2d.m_world.DestroyBody(body);
			game.movie.removeChild(sprite);
			delete game.box2d.update_list[body];
			delete game.projectile_list[body];
			game.network.Remove(unique);
		}
		public function Update(timeStep:Number){
			switch(flavor){
				case "projectile fire":
				if(hits > 3){
					Remove();
				}
				//make it float:
				body.ApplyForce(new b2Vec2(0,-30 * body.GetMass()), new b2Vec2(0,0));
				break;
				case "projectile water":
				if(time > 2000){
					Remove();
				}
				break;
			}
		}
	}
}