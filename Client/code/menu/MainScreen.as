package code.menu{
	import flash.display.MovieClip;
	import code.Connection;
	import code.Main;
	import code.Utils;
	import flash.net.Socket;
	import flash.events.Event;
	import flash.events.MouseEvent;
	

	public class MainScreen extends MovieClip{
		private var functions:Array;
		private var ready:Boolean;
		public var connection:Connection;
		
		public function MainScreen(){
			ready = false;
			functions = new Array;
			
			connection = new Connection(Main.SERVER,Main.PORT);
			
			if(Main.save.data.id == null){
				NewID();
			}else{
				LoadID();
			}
			
			GetPlayer();
			name_button.addEventListener(MouseEvent.CLICK, ChangeName);
			play_button.addEventListener(MouseEvent.CLICK, PlayTheGame);
			//EndConnection();
			
			
		}
		public function PlayTheGame(event){
			//todo
			//sup
		}
		
		public function ChangeName(event){
			Main.name = Utils.Standardize(name_text.text);
			connection.Add (function(socket:Socket)
								{
								 	socket.writeInt(4);
									socket.writeBytes(Main.id,0,32);
							 		socket.writeBytes(Main.password,0,32);
									socket.writeBytes(Main.name,0,32);
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
		public function NewID(){
			connection.Add (function(socket:Socket)
								{
								 	socket.writeInt(2);
						 		},32,function(socket:Socket)
								{
									socket.readBytes(Main.id,0,32);
									Main.save.data.id = Main.id;
									Main.password = Utils.Hash(Main.id,"");
									Main.save.data.password = Main.password;
									Main.save.flush();
									trace("New id and default password: ",Main.id);
							  	});
		}
		public function LoadID(){
			Main.id = Main.save.data.id;
			Main.password = Main.save.data.password;
			trace("Loaded id: ",Main.id);
		}
		public function GetPlayer(){
			connection.Add (function(socket:Socket)
							{
					  		 	socket.writeInt(3);
							 	socket.writeBytes(Main.id,0,32);
							 	socket.writeBytes(Main.password,0,32);
					  		},4,function(socket:Socket)
							{
								if(socket.readInt() == 1){
									connection.Continue(Connection.Nothing,292,function(socket:Socket)
														{
															socket.readBytes(Main.name,0,32);
															socket.readBytes(Main.mail,0,256);
															Main.points = socket.readInt();
															trace("Login success, name: ",Main.name,", mail: ", Main.mail,", points: ",Main.points);
															Ready();
													  	});
								}else{
									trace("Invalid login.");
									NewID();
									GetPlayer();
								}
						  	});
		}
		public function EndConnection(){
			connection.Add  (function(socket:Socket)
							 {
								 socket.writeInt(0);
							 },0,function(socket:Socket){
								 Ready();
							 });
		}
	}
	
}