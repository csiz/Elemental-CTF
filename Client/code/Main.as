package code{
	import flash.display.MovieClip;
	import code.game.Game;
	import code.menu.MainScreen;
	import code.game.Network;
	import flash.utils.ByteArray;
	import flash.net.SharedObject;
	
	

	public class Main extends MovieClip{
		public const SERVER = "188.24.44.234";
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
			Clear();
			var menu = new MainScreen(this);
			menu.OnReady(function(){Add(menu);});
		}
		public function LoadGame(address:String,port:int,room:ByteArray){
			Clear();
			var network:Network = new Network();
			network.Connect(address,port,id);
			var game = new Game(network);
			network.OnReady(function(){Add(game);game.Start();stage.focus = game});
		}
		public function Clear(){
			if(screen){
				removeChild(screen);
				screen = null;
			}
		}
		public function Add(what:MovieClip){
			if(!screen){
				screen = what;
				addChild(screen);
			}else{
				throw ("Main: It's not supposed to add 2 screens at once.");
			}
		}
	}
}