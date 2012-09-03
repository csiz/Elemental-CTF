package code.menu {
	
	import flash.display.MovieClip;
	import code.Main;
	import flash.events.*;
	
	
	public class AccountScreen extends MovieClip {
		public var main:Main;
		
		public function AccountScreen(main:Main) {
			this.main = main;
			logout_button.addEventListener(MouseEvent.CLICK, Logout);
			
		}
		public function Logout(event){
			main.Clear();
			main.LoginScreen("You've been logged out.");
		}
	}
	
}
