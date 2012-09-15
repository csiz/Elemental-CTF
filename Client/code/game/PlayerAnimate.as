package code.game
{
	import flash.display.MovieClip;
	import flash.events.Event;

	public class PlayerAnimate extends MovieClip{
		public var player:Player;
		public var animation:String = "idle";
		public var action:Boolean = false;
		public var vx:Number = 0;
		public var vy:Number = 0;
		
		public function PlayerAnimate(player:Player = null){
			this.player = player;
			addEventListener(Event.ENTER_FRAME, Update);
		}
		
		public function Action(delay:Number){//miliseconds
			action = true;
			Animate("action");
		}
		public function Kill(delay:Number){//miliseconds
			action = true;
			Animate("death");
		}
		public function Animate(anim:String){
			if(animation != anim){
				animation = anim;
				gotoAndPlay(anim);
			}
		}
		
		private function Update(event){
			if(player){
				if(!action){
					vx = player.body.GetLinearVelocity().x;
					vy = player.body.GetLinearVelocity().y;
					
					if(vy < -2){
						if(player.aiSince < 100){
							Animate("jump");
						}
					}else if(vy > 2){
						if(player.airSince > 100){
							Animate("fall");
						}
					}else if(vx > 1){
						if(player.airSince < 100){
							Animate("right");
						}
					}else if(vx < -1){
						if(player.airSince < 100){
							Animate("left");
						}
					}else{
						Animate("idle");
					}
				}
			}
			
			if(currentLabel != animation){
				if(action){
					action = false;
					Animate("idle");
				}
				try{
					gotoAndPlay(animation);
				}catch(e){
					//ignore
				}
			}
		}
	}//end of class
}