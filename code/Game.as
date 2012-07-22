package code
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
    import flash.display.MovieClip;
	import flash.utils.getTimer;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	
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
		//player data:
		public var me:Player;
		public var player_list:Dictionary;
		//Game controls.........................................................................
		public var w:Boolean;
		public var a:Boolean;
		public var s:Boolean;
		public var d:Boolean;
		public var space:Boolean;
		public var mouse:Boolean;
		
		
		
		public function Game()
        {
			//init data:
			movie = new MovieClip();
			player_list = new Dictionary();
			addChild(movie);
			levels = new Levels();
			box2d = new Box2d(levels,movie,this);
			w = false;
			a = false;
			s = false;
			d = false;
			space = false;
			mouse = false;
			
			
			//controls...
            addEventListener(Event.ENTER_FRAME,GameLoop);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,KeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP,KeyUp);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,MouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP,MouseUp);
			
			
			box2d.LoadLevel(0);
			me = box2d.AddPlayer(levels.GetSpawn(0,"team 1"));
			
			
			time = getTimer();
        }
		
		protected function GameLoop(event:Event):void
        {	
			//controls
			if(a){
				me.Left(timeStep);
			}
			if(d){
				me.Right(timeStep);
			}
			if(w){
				me.Jump(timeStep);
			}
			//todo: check for ground collision and make a variable timeSinceLastTouchedGround
			//Game loop starts here............................................................*
			
			

			
            //Game loop ends here..............................................................*
        	
			//Fps update:
			timeStep = - time + (time = getTimer() );
			
			//Players update
			var body:*;
			for(body in player_list){
				player_list[body].actionSince += timeStep;
			}
			//Box2d
			box2d.Update(timeStep);
			//Centering screen, slowly
			//movie.x += ( ( 325  -me.sprite.x - ( me.body.GetLinearVelocity().x * 40 ) ) - movie.x ) * 0.007;
			//movie.y += ( ( 200  -me.sprite.y - ( me.body.GetLinearVelocity().y * 20 ) ) - movie.y ) * 0.006;
			movie.x += ( ( 325  -me.sprite.x ) - movie.x ) * 0.1;
			movie.y += ( ( 200  -me.sprite.y ) - movie.y ) * 0.1;
			
			//Message
			//message.text = (1000/timeStep).toFixed(2);
			message.text = me.actionSince.toFixed(5);
		}
		
		public function Action(origin:String, x:Number = 0, y:Number = 0){
			if(origin == "click"){
				x = x - me.sprite.x - movie.x;
				y = y - me.sprite.y - movie.y;
				
				x/=7;
				y/=7;
			}
			if(origin == "space"){
				x = me.body.GetLinearVelocity().x;
				y = me.body.GetLinearVelocity().y;
			}
			me.Action(x,y);
		}
		
		protected function MouseDown(event:MouseEvent):void{
			if(mouse == false){
				Action("click", event.localX, event.localY);
			}
			mouse = true;
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
				if(space == false){
					Action("space");
				}
				space=true;
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