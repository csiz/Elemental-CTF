package code{
	import Box2D.Dynamics.*;
	import flash.display.MovieClip;

	public class Projectile{
		public var body:b2Body;
		public var flavor:String;
		public var game:Game;
		public var role:String;
		public var team:String;
		public var sprite:MovieClip;
		public var hits:int;
		
		public function Projectile(body:b2Body, flavor:String, game:Game){
			this.flavor = flavor;
			this.body = body;
			this.game = game;
			role = "projectile";
			hits = 0;
			
			switch(flavor){
				case "projectile fire":
				team = "fire";
				sprite = new ProjectileFire();
			}
		}
	}
}