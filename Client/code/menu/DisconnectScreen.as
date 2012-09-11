package code.menu {
	
	import flash.display.MovieClip;
	import code.Main;
	import flash.events.MouseEvent;
	
	public class DisconnectScreen extends MovieClip {
		public var main:Main;
		
		public function DisconnectScreen(main:Main) {
			this.main = main;
			offline_play.addEventListener(MouseEvent.CLICK,function(event){
										  		main.OfflineGame();
										  });
		}
	}
	
}
