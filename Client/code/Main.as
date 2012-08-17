package code{
	import flash.display.MovieClip;
	import code.game.Game;
	import code.menu.MainScreen;
	import flash.utils.ByteArray;
	import flash.net.SharedObject;
	
	

	public class Main extends MovieClip{
		public const SERVER = "127.0.0.1";
		public const PORT = 25971;
		
		public var id = new ByteArray();
		public var password = new ByteArray();
		public var display_name = new ByteArray();
		public var mail = new ByteArray();
		public var points:int = 5;
		
		public var save = SharedObject.getLocal("ElementalCTF");
		
		public var screen:MovieClip;
		
		public function Main(){
			Menu();
			
			
			//var game = new Game();
			//addChild(game);
			//game.Start();
		}
		
		public function Menu(){
			screen = new MainScreen(this);
			screen.OnReady(function(){addChild(screen);});
		}
		public function LoadGame(address:String,port:int,room:ByteArray){
			trace("todo");
		}
	}
}