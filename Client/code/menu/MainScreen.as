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
			name_button.addEventListener(MouseEvent.CLICK, ChangeName);
			play_button.addEventListener(MouseEvent.CLICK, PlayTheGame);
			tutorial_button.addEventListener(MouseEvent.CLICK, PlayTutorial);
			account_button.addEventListener(MouseEvent.CLICK, Account);
			//EndConnection();
			
			
		}
		public function PlayTheGame(event){
			//todo retry if it fails
			main.connection.Add (function(socket:Socket)
							{
								main.LoadingScreen();
					  		 	socket.writeInt(6);
							 	socket.writeBytes(main.id,0,32);
							 	socket.writeBytes(main.password,0,32);
								socket.writeBytes(Utils.Standardize("local"),0,32);
								//socket.writeBytes(Utils.Standardize("csiz room"),0,32);//also modify from 6 to 7
								
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
		
		public function ChangeName(event){
			main.display_name = Utils.Standardize(name_text.text);
			main.connection.Add (function(socket:Socket)
								{
								 	socket.writeInt(4);
									socket.writeBytes(main.id,0,32);
							 		socket.writeBytes(main.password,0,32);
									socket.writeBytes(main.display_name,0,32);
						 		},4,function(socket:Socket)
								{
									if(socket.readInt() == 1){
										trace("Changed name.");
									}else{
										trace("Change name failed.");
									}
							  	});
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
															socket.readBytes(main.display_name,0,32);
															socket.readBytes(main.mail,0,256);
															main.points = socket.readInt();
															trace("Login success, name: ",main.display_name,", mail: ", main.mail,", points: ",main.points);
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