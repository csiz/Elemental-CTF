package code.menu {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import code.Main;
	
	public class TutorialSlides extends MovieClip {
		public var main:Main;
		
		public function TutorialSlides(main:Main){
			stop();
			this.main = main;
			exit_button.addEventListener(MouseEvent.CLICK, function(event){main.Menu();});
			next_button.addEventListener(MouseEvent.CLICK, function(event){nextFrame();});
		}
	}
	
}
