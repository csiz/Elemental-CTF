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
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.events.MouseEvent;
	
	

	public class Main extends MovieClip{
		public static const SERVER = "86.122.32.2";
		public static var REGION = "local";
		public static const PORT = 25971;
		public static const WIDTH = 650;
		public static const HEIGHT = 400;
		
		public var KeyDown = function(event){}
		public var KeyUp = function(event){}
		public var MouseDown = function(event){}
		public var MouseUp = function(event){}
		
		public var store_data:Boolean = true;
		public var id = new ByteArray();
		public var password = new ByteArray();
		
		public var user:User = new User();
		
		public var connection:Connection = null;
		
		public var save = SharedObject.getLocal("ElementalCTF");
		
		public var screen:MovieClip = null;
		public var loading_screen = new Loading();

		
		public function Main(){
			stage.addEventListener(KeyboardEvent.KEY_DOWN,function(event:KeyboardEvent){
								   if (event.keyCode == Keyboard.TAB)
								   {
									 event.currentTarget.tabChildren = false;
								   }
								});//capture tab events
								
			stage.addEventListener(KeyboardEvent.KEY_DOWN,function(event){KeyDown(event);});
			stage.addEventListener(KeyboardEvent.KEY_UP,function(event){KeyUp(event);});
			stage.addEventListener(MouseEvent.MOUSE_DOWN,function(event){MouseDown(event);});
			stage.addEventListener(MouseEvent.MOUSE_UP,function(event){MouseUp(event);});
			
			Add(loading_screen);
			connection = new Connection(Main.SERVER,Main.PORT);
			connection.addEventListener(Disconnect.SERVER_ERROR,ServerError);
			if(Load()){//if we could load the stored id and password, check them:
				if( (id) && (password) && (store_data) ){
					if( (id.length == 32) && (password.length == 32) ){
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
					}else{
						LoginScreen("Error loading your login information, please enter them again or create a New account.");
					}
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
		
		public function Menu(room:ByteArray = null){
			Add(loading_screen);
			var menu = new MainScreen(this);
			menu.PreviousRoom(room);
			menu.OnReady(function(){Add(menu);});
		}
		public function LoadGame(address:String,port:int,room:ByteArray){
			Add(loading_screen);
			var network:Network = new Network(this,room);
			network.Connect(address,port,id);
			var game = new Game(this,network);
			network.OnReady(function(){
								Add(game);
								game.Start();
								stage.focus = game;
							});
		}
		
		public function OfflineGame(){
			var network:Network = new Network(this);
			var game = new Game(this,network);
			Add(game);
			game.Start();
			game.Reload(0,0);//load state number 0 and lvl 0 as a tutorial
			stage.focus = game
		}
		
		public function LoadTutorial(){
			Add(loading_screen);
			Add(new TutorialSlides(this));
		}
		public function LoginScreen(message:String = ""){
			Add(new code.menu.LoginScreen(this,message));
		}
		public function ServerError(event){
			Add(new code.menu.DisconnectScreen(this));
		}
		public function LoadingScreen(){
			Add(loading_screen);
		}
		public function AccountScreen(message:String = ""){
			Add(new code.menu.AccountScreen(this,message));
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
			save.data.store_data = store_data;
			if(store_data){
				save.data.id = id;
				save.data.password = password;
			}else{
				save.data.id = null;
				save.data.password = null;
			}
			save.flush();
		}
		public function Load():Boolean{
			if(save.data){
				if(save.data.store_data != null){
					if(save.data.store_data){
						id = save.data.id;
						password = save.data.password;
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

			Save();
		}
	}
}

