package code.game
{	
	import flash.geom.Point;

	public class Levels
	{
		public var level:Array;
		public var map:Object;
		
		public function Levels()
		{
			//intialize the Levels variables
			level = new Array();
			
			//create the transcription map
			map = new Object();
			map["O"] = "brick";
			map["B"] = "bouncy";
			map["I"] = "ice";//todo
			map["L"] = "lava";//todo
			
			map["."] = "space";
			map[" "] = "space";
			
			map["1"] = "fire";
			map["a"] = "fire flag";
			
			map["2"] = "water";
			map["b"] = "water flag";
			
			
			
			level[0] = new Object();
			
			level[0].map = new Array("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO",
								 	 "O                                                                                            O",
									 "O                                                                                            O",
									 "O                                                                                            O",
									 "O                                                                     OO                     O",
									 "O...     OOOOO    OO                                                                         O",
									 "O.1.                    OO                                      OO                           O",
									 "O...                         OO                                                              O",
									 "O                                                        OO                                  O",
									 "O                                  O                                                         O",
									 "O                                                                   ...                      O",
									 "O                                         O                         .2.                      O",
									 "O                                                 OOO               ...                      O",
									 "O                                                  O                                         O",
									 "O                                         O                                                  O",
									 "O                                        OOO            OOOOOOO                              O",
									 "O                                                                    III                     O",
									 "O                                                                     I                      O",
									 "O                                                                                            O",
									 "O                                                                    b                       O",
									 "O                                                              OOOOOOOOOOOO OOOOOOOO         O",
									 "O                                                             OOOO                           O",
									 "O                                                       a    OOOO                            O",
									 "O                                                  OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO         O",
									 "O                                                 OOOOOO                                   OOO",
									 "O                                                OOOOOO                                      O",
									 "O                                               OOOOOO                                       O",
									 "OBBBBOOOOLLLOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO");
			level[0].width = level[0].map[0].length;
			level[0].height = level[0].map.length;
									 
		}
		
		public function GetType(lvl:int, x:int, y:int):String
		{
			return map[level[lvl].map[y].charAt(x)];
		}
		public function GetOrientation(lvl:int, x:int, y:int):String
		{
			if( (x==0) || (y==0) || (x+1==level[lvl].width) || (y+1==level[lvl].height)){
				return "normal";
			}
			//warning:
			var test = new Array();
			if(level[lvl].map[y-1].charAt(x-1).match(/[A-Z]/g).length){
				test[0] = 1;
			}else{
				test[0] = 0;
			}
			
			if(level[lvl].map[y-1].charAt(x).match(/[A-Z]/g).length){
				test[1] = 1;
			}else{
				test[1] = 0;
			}
			
			if(level[lvl].map[y-1].charAt(x+1).match(/[A-Z]/g).length){
				test[2] = 1;
			}else{
				test[2] = 0;
			}
			
			if(level[lvl].map[y].charAt(x-1).match(/[A-Z]/g).length){
				test[3] = 1;
			}else{
				test[3] = 0;
			}
			
			test[4] = 1;
			
			if(level[lvl].map[y].charAt(x+1).match(/[A-Z]/g).length){
				test[5] = 1;
			}else{
				test[5] = 0;
			}
			
			if(level[lvl].map[y+1].charAt(x-1).match(/[A-Z]/g).length){
				test[6] = 1;
			}else{
				test[6] = 0;
			}
			
			if(level[lvl].map[y+1].charAt(x).match(/[A-Z]/g).length){
				test[7] = 1;
			}else{
				test[7] = 0;
			}
			
			if(level[lvl].map[y+1].charAt(x+1).match(/[A-Z]/g).length){
				test[8] = 1;
			}else{
				test[8] = 0;
			}
			//i did warn myself:
			switch( test.toString() ){
				case [1,0,0,
					  1,1,0,
					  0,1,1].toString():
				case [1,0,0,
					  1,1,0,
					  1,1,1].toString():
				case [0,0,0,
					  1,1,0,
					  0,1,1].toString():
				case [0,0,0,
					  1,1,0,
					  1,1,1].toString():
				case [0,0,0,
					  1,1,0,
					  1,1,0].toString():
				case [0,0,0,
					  1,1,0,
					  0,1,0].toString():
				case [1,0,0,
					  1,1,0,
					  0,0,0].toString():
				return "NE";
				case [0,0,1,
					  0,1,1,
					  1,1,0].toString():
				case [0,0,1,
					  0,1,1,
					  1,1,1].toString():
				case [0,0,0,
					  0,1,1,
					  1,1,0].toString():
				case [0,0,0,
					  0,1,1,
					  1,1,1].toString():
				case [0,0,0,
					  0,1,1,
					  0,1,1].toString():
				case [0,0,0,
					  0,1,1,
					  0,1,0].toString():
				case [0,0,1,
					  0,1,1,
					  0,0,0].toString():
				return "NW";
				case [1,1,0,
					  0,1,1,
					  0,0,1].toString():
				case [1,1,1,
					  0,1,1,
					  0,0,1].toString():
				case [1,1,0,
					  0,1,1,
					  0,0,0].toString():
				case [1,1,1,
					  0,1,1,
					  0,0,0].toString():
				case [0,1,1,
					  0,1,1,
					  0,0,0].toString():
				case [0,1,0,
					  0,1,1,
					  0,0,0].toString():
				case [0,0,0,
					  0,1,1,
					  0,0,1].toString():
				case [0,0,0,
					  0,1,1,
					  0,0,0].toString():
				return "SW";
				case [0,1,1,
					  1,1,0,
					  1,0,0].toString():
				case [1,1,1,
					  1,1,0,
					  1,0,0].toString():
				case [0,1,1,
					  1,1,0,
					  0,0,0].toString():
				case [1,1,1,
					  1,1,0,
					  0,0,0].toString():
				case [1,1,0,
					  1,1,0,
					  0,0,0].toString():
				case [0,1,0,
					  1,1,0,
					  0,0,0].toString():
				case [0,0,0,
					  1,1,0,
					  1,0,0].toString():
				case [0,0,0,
					  1,1,0,
					  0,0,0].toString():
				return "SE";
				default:
				return "normal";
			}
			
		}
		
		public function GetSpawn(lvl:int, what:String):Point
		{
			for(var y = 0;y < level[lvl].height;y++)
			{
				for(var x = 0;x < level[lvl].width;x++)
				{
					if(GetType(lvl, x, y) == what)
					{
						return new Point(x,y);
					}
				}
			}
			return new Point(-1,-1);
		}
	}
	
	
}