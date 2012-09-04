package code.menu {
	
	import flash.display.MovieClip;
	import code.Main;
	import flash.events.*;
	import flash.net.Socket;
	import code.Utils;
	
	public class AccountScreen extends MovieClip {
		public var main:Main;
		
		public function AccountScreen(main:Main,message:String) {
			this.main = main;
			this.message.text = message;
			email_text.text = main.user.mail;
			name_text.text = main.user.display_name;
			id_field.text = Utils.Strip(main.id);
			
			logout_button.addEventListener(MouseEvent.CLICK, Logout);
			name_button.addEventListener(MouseEvent.CLICK, ChangeName);
			email_button.addEventListener(MouseEvent.CLICK, ChangeEmail);
			id_password_button.addEventListener(MouseEvent.CLICK, ChangeID);
			
			id_field.addEventListener(Event.CHANGE,CheckID);
			
			back_button.addEventListener(MouseEvent.CLICK, function(event){main.Menu();});
			
		}
		public function Logout(event){
			main.Clear();
			main.LoginScreen("You've been logged out.");
		}
		public function CheckID(event){
			main.connection.Add (function(socket:Socket)
								{
								 	socket.writeInt(1);
									socket.writeBytes(Utils.Standardize(id_field.text),0,32);
						 		},4,function(socket:Socket)
								{
									if(socket.readInt() == 1){
										new_id_status.text = "Available.";
									}else{
										if(id_field.text == Utils.Strip(main.id)){
											new_id_status.text = "";
										}else{
											new_id_status.text = "Not available.";
										}
									}
							  	});
		}
		
		public function ChangeName(event){
			var display_name = Utils.Standardize(name_text.text);
			main.LoadingScreen();
			main.connection.Add (function(socket:Socket)
								{
								 	socket.writeInt(4);
									socket.writeBytes(main.id,0,32);
							 		socket.writeBytes(main.password,0,32);
									socket.writeBytes(display_name,0,32);
						 		},4,function(socket:Socket)
								{
									if(socket.readInt() == 1){
										main.user.display_name = Utils.Strip(display_name);
										main.AccountScreen("Changed name.");
									}else{
										main.AccountScreen("Change name failed.");
									}
							  	});
		}
		public function ChangeEmail(event){
			var email = Utils.Standardize(email_text.text);
			main.LoadingScreen();
			main.connection.Add (function(socket:Socket)
								{
								 	socket.writeInt(9);
									socket.writeBytes(main.id,0,32);
							 		socket.writeBytes(main.password,0,32);
									socket.writeBytes(email,0,32);
						 		},4,function(socket:Socket)
								{
									if(socket.readInt() == 1){
										main.user.mail = Utils.Strip(email);
										main.AccountScreen("Changed email.");
									}else{
										main.AccountScreen("Change email failed.");
									}
							  	});
		}
		
		public function ChangeID(event){
			if(id_field.text.length){
				main.LoadingScreen();
				var new_id = Utils.Standardize(id_field.text);
				var new_password = Utils.Hash(new_id,password_field.text);
					
				main.connection.Add (function(socket:Socket)
								{
									socket.writeInt(5);
									socket.writeBytes(main.id,0,32);
									socket.writeBytes(main.password,0,32);
									socket.writeBytes(new_id,0,32);
									socket.writeBytes(new_password,0,32);
								},4,function(socket:Socket)
								{
									if(socket.readInt() == 1){
										main.id = new_id;
										main.password = new_password;
										main.Save();
										main.AccountScreen("Changed id and password.");
									}else{
										main.AccountScreen("Change id and password failed.");
									}
								});
			}else{
				message.text = "Please enter your id.";
			}
		}
		
	}
	
}
