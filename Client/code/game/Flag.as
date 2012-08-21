package code.game{
	import Box2D.Dynamics.*;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import Box2D.Common.Math.b2Vec2;

	public class Flag{
		public var body:b2Body;
		public var game:Game;
		public var role:String;
		public var flavor:String;
		public var health:Number;
		public var alive:Boolean;
		public var unique:int;
		public var id:int;
		public var team:String;
		public var sprite:MovieClip;
		public var carry:Player;
		public var origin:b2Vec2;
		
		public function Flag(body:b2Body,team:String, pos:Point, game:Game){
			
			health = 0;
			alive = true;
			id = 0;
			
			this.body = body;
			this.game = game;
			this.team = team;
			origin = new b2Vec2();
			origin.x = pos.x;
			origin.y = pos.y;
			role = "flag";
			carry = null;
			
			switch(team){
				case "fire":
				sprite = new FlagFire();
				unique = 1;
				flavor = "flag fire";
				break;
				case "water":
				sprite = new FlagWater();
				unique = 2;
				flavor = "flag water";
				break;
				default:
				trace("wtf");
			}
			
			game.network.AddFlag(this);
		}
		
		public function Pick(carry:Player){
			this.carry = carry;
			carry.flag = this;
		}
		public function Drop(){
			carry.flag = null;
			carry = null;
		}
		public function Reset(){
			body.SetPosition(origin);
		}
	}
}