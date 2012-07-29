package code{
	import flash.utils.Dictionary;

	public class Network{
		public var game:Game;
		public var objects:Dictionary;
		public var water_flag:Flag;
		public var fire_flag:Flag;
		public var me:Player;
		
		public function Network(game:Game){
			this.game = game;
			objects = new Dictionary(true);
			game.id = GetID();
		}
		public function Random():uint{
			return Math.floor( Math.random() * (uint.MAX_VALUE - uint.MIN_VALUE) + uint.MIN_VALUE );
		}
		public function GetID():uint{
			return Random();
		}
//The functions that add and remove things......................................................
		public function Remove(unique:uint){
			if(objects[unique]){
				delete objects[unique];
			}
		}
		public function Add(object:*){
			do{
				object.unique = Random();
			}while(objects[object.unique]);
			objects[object.unique] = object;
		}
		public function AddUser(me:Player){
			this.me = me;
			me.id = game.id;
		}
		public function AddFlag(flag:Flag){
			if(flag.team == "fire"){
				fire_flag = flag;
			}else if(flag.team == "water"){
				water_flag = flag;
			}else{
				throw ("Network: wtf, there is no " + flag.team + " team.");
			}
			
		}
//End functions that add and remove things......................................................
//Actions ......................................................................................	
		public function Send(id:uint){
			var obj:*;
			for(obj in objects){
				if(objects[obj]){
					if(objects[obj].id == id){
						//todo
					}
				}
			}
		}

//End actions ..................................................................................
	}
}