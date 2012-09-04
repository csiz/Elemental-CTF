package code.menu {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import code.Main;
	import code.Utils;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	public class LoginScreen extends MovieClip {
		public var main:Main;
		
		public function LoginScreen(main:Main,message:String = "Please Login, or create a New account.") {
			this.main = main;
			main.Clear();
			this.message.text = message;
			
			login_button.addEventListener(MouseEvent.CLICK, Login);
			new_button.addEventListener(MouseEvent.CLICK, NewID);
		}
		
		private function Login(event){
			if(id_field.text.length){
				main.LoadingScreen();
				main.id = Utils.Standardize(id_field.text);
				main.password = Utils.Hash(main.id,password_field.text);
				main.store_data = remember.selected;
				main.Save();
					
				main.connection.Add (function(socket:Socket)
								{
									socket.writeInt(8);
									socket.writeBytes(main.id,0,32);
									socket.writeBytes(main.password,0,32);
								},4,function(socket:Socket)
								{
									var response = socket.readInt();
									if(response){
										main.Menu();
									}else{
										main.LoginScreen("The id and password combination was wrong.");
									}
								});
			}else{
				message.text = "Please enter your id.";
			}
		}
		private function NewID(event){
			main.LoadingScreen();
			main.connection.Add (function(socket:Socket)
								{
								 	socket.writeInt(2);
						 		},32,function(socket:Socket)
								{
									main.id = new ByteArray();
									socket.readBytes(main.id,0,32);
									main.password = Utils.Hash(main.id,"");
									main.store_data = true;
									main.Save();
									trace("New id and default password: ",main.id);
									main.Menu();
							  	});
		}
	}
	
}
