package code{
	import flash.display.MovieClip;
	import code.game.Game;
	import code.menu.MainScreen;
	import flash.utils.ByteArray;
	import flash.net.SharedObject;
	
	

	public class Main extends MovieClip{
		public static const SERVER = "127.0.0.1";
		public static const PORT = 25971;
		
		public static var id = new ByteArray();
		public static var password = new ByteArray();
		public static var name = new ByteArray();
		public static var mail = new ByteArray();
		public static var points:int = 5;
		
		public static var save = SharedObject.getLocal("ElementalCTF");
		
		public function Main(){
			Menu();
			
			
			//var game = new Game();
			//addChild(game);
			//game.Start();
		}
		
		public function Menu(){
			var screen = new MainScreen();
			screen.OnReady(function(){addChild(screen);});
		}
	}
}