﻿package code{
	import flash.display.MovieClip;
	import code.game.Game;
	import code.menu.MainScreen;
	import code.game.Network;
	import flash.utils.ByteArray;
	import flash.net.SharedObject;
	import code.menu.TutorialSlides;
	import flash.net.Socket;
	import code.menu.LoginScreen;
	
	

	public class Main extends MovieClip{
		public static const SERVER = "localhost";
		public static const PORT = 25971;
		public static const WIDTH = 650;
		public static const HEIGHT = 400;
		
		public var store_data:Boolean = true;
		public var id = new ByteArray();
		public var password = new ByteArray();
		public var display_name = new ByteArray();
		public var mail = new ByteArray();
		public var points:int = 0;
		
		public var connection:Connection = null;
		
		public var save = SharedObject.getLocal("ElementalCTF");
		
		public var screen:MovieClip = null;
		public var loading_screen = new Loading();

		
		public function Main(){
			Add(loading_screen);
			connection = new Connection(Main.SERVER,Main.PORT);
			connection.addEventListener(Disconnect.SERVER_ERROR,ServerError);
			if(Load()){//if we could load the stored id and password, check them:
				if( (id) && (password) && (store_data) ){
					connection.Add (function(socket:Socket)
									{
										socket.writeInt(8);
										socket.writeBytes(id,0,32);
										socket.writeBytes(password,0,32);
									},4,function(socket:Socket)
									{
										var response = socket.readInt();
										if(response){
											Menu();
										}else{
											LoginScreen("The stored id and password combination was wrong.");
										}
									});
				}else{//means data isn't stored
					LoginScreen("Welcome back, please Login or create a New account.");
				}
			}else{//silently create a new id, so player can play without typing their data
				connection.Add (function(socket:Socket)
								{
								 	socket.writeInt(2);
						 		},32,function(socket:Socket)
								{
									id = new ByteArray();
									socket.readBytes(id,0,32);
									password = Utils.Hash(id,"");
									Save();
									trace("New id and default password: ",id);
									Menu();
							  	});
			}
		}
		
		public function Menu(){
			Add(loading_screen);
			var menu = new MainScreen(this);
			menu.OnReady(function(){Add(menu);});
		}
		public function LoadGame(address:String,port:int,room:ByteArray){
			Add(loading_screen);
			var network:Network = new Network();
			network.Connect(address,port,id);
			var game = new Game(this,network);
			network.OnReady(function(){Add(game);game.Start();stage.focus = game});
		}
		
		public function LoadTutorial(){
			Add(loading_screen);
			Add(new TutorialSlides(this));
		}
		public function LoginScreen(message:String = ""){
			Add(new code.menu.LoginScreen(this,message));
		}
		public function ServerError(event){
			Add(new DisconnectScreen());
		}
		public function LoadingScreen(){
			Add(loading_screen);
		}
		public function AccountScreen(){
			Add(new code.menu.AccountScreen(this));
		}
		
		private function Add(what:MovieClip){
			if(screen){
				removeChild(screen);
				screen = null;
			}
			
			screen = what;
			addChild(screen);
		}
		public function Save(){
			store_data = true;
			save.data.store_data = true;
			save.data.id = id;
			save.data.password = password;
			save.data.display_name = display_name;
			save.data.mail = mail;
			save.data.points = points;
			save.flush();
		}
		public function Load():Boolean{
			if(save.data){
				if(save.data.store_data != null){
					if(save.data.store_data){
						id = save.data.id;
						password = save.data.password;
						display_name = save.data.display_name;
						mail = save.data.mail;
						points = save.data.points;
					}
					store_data = save.data.store_data;
					return true;
				}else{
					return false;
				}
			}else{
				return false;
			}
		}
		public function Clear(){
			store_data = false;
			id = new ByteArray();
			password = new ByteArray();
			display_name = new ByteArray();
			mail = new ByteArray();
			points = 0;

			save.data.store_data = false;
			save.data.id = null;
			save.data.password = null;
			save.data.display_name = null;
			save.data.mail = null;
			save.data.points = null;
			save.flush();
		}
	}
}