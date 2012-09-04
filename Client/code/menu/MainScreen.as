package code.menu{
	import flash.display.MovieClip;
	import code.Connection;
	import code.Main;
	import code.Utils;
	import flash.net.Socket;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.ByteArray;
	

	public class MainScreen extends MovieClip{
		private var functions:Array = new Array();
		private var ready:Boolean = false;
		public var main:Main;
		
		public function MainScreen(main:Main,connection:Connection = null){
			this.main = main;
			
			if(!connection){
				main.connection = new Connection(Main.SERVER,Main.PORT);
			}
			
			GetPlayer();
			OnReady(function (){
						if(main.user.display_name.length > 0){
							message.text = "Name: " + main.user.display_name + "\nPoints: " + main.user.points;
						}else{
							message.text = "We sense you're new here, so please play the Tutorial first, its pretty short.";
						}
					});
			
			play_button.addEventListener(MouseEvent.CLICK, function(event){PlayTheGame();});
			room_button.addEventListener(MouseEvent.CLICK, function(event){PlayTheGame(room_text.text);});
			tutorial_button.addEventListener(MouseEvent.CLICK, PlayTutorial);
			account_button.addEventListener(MouseEvent.CLICK, Account);
			//EndConnection();
		}
		public function PlayTheGame(room_id:String = null){
			//todo retry if it fails
			main.connection.Add (function(socket:Socket)
							{
								main.LoadingScreen();
								if(room_id){
									socket.writeInt(7);
									socket.writeBytes(main.id,0,32);
									socket.writeBytes(main.password,0,32);
									socket.writeBytes(Utils.Standardize(Main.REGION),0,32);
									socket.writeBytes(Utils.Standardize(room_id),0,32);
								}else{
									socket.writeInt(6);
									socket.writeBytes(main.id,0,32);
									socket.writeBytes(main.password,0,32);
									socket.writeBytes(Utils.Standardize(Main.REGION),0,32);
								}
								
					  		},4,function(socket:Socket)
							{
								if(socket.readInt() == 1){
									main.connection.Continue(Connection.Nothing,68,function(socket:Socket)
														{
															var address = new String()
															var port = new int;
															var room = new ByteArray()
															
															address = socket.readUTFBytes(32);
															port = socket.readInt()
															socket.readBytes(room,0,32);
															trace("Found a game on server ",address,":",port," inside room: ",room);
															EndConnection();
															main.LoadGame(address,port,room);
													  	});
								}else{
									trace("Game not found.");
								}
						  	});
		}
		
		public function PlayTutorial(event){
			main.LoadTutorial();
		}
		public function Account(event){
			main.AccountScreen();
		}
		
		public function OnReady(f:Function){
			functions.push(f);
			if(ready){
				Ready();
			}
			
		}
		private function Ready(){
			ready = true;
			while(functions.length){
				functions.shift()();
			}
		}
		
		public function GetPlayer(){
			main.connection.Add (function(socket:Socket)
							{
					  		 	socket.writeInt(3);
							 	socket.writeBytes(main.id,0,32);
							 	socket.writeBytes(main.password,0,32);
					  		},4,function(socket:Socket)
							{
								if(socket.readInt() == 1){
									main.connection.Continue(Connection.Nothing,292,function(socket:Socket)
														{
															var display_name = new ByteArray();
															var mail = new ByteArray();
															var points = 0;
															
															socket.readBytes(display_name,0,32);
															socket.readBytes(mail,0,256);
															points = socket.readInt();
															
															main.user.display_name = Utils.Strip(display_name);
															main.user.mail = Utils.Strip(mail);
															main.user.points = points;
															
															trace("Login success, name: ",main.user.display_name,", mail: ", main.user.mail,", points: ",main.user.points);
															Ready();
													  	});
								}else{
									trace("Invalid login.");
									main.LoginScreen();
								}
						  	});
		}
		public function EndConnection(){
			main.connection.Add  (function(socket:Socket)
							 {
								 socket.writeInt(0);
							 },0,function(socket:Socket){
								 Ready();
							 });
			main.connection = null;
		}
	}
	
}