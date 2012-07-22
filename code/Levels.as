package code
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
			map[" "] = "space";
			map["1"] = "team 1";
			map["."] = "space"
			
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
									 "O                                                                                            O",
									 "O                                         O                                                  O",
									 "O                                                 OOO                                        O",
									 "O                                                  O                                         O",
									 "O                                                                                            O",
									 "O                                                       OOOOOOO                              O",
									 "O                                                                    O                       O",
									 "O                                                                                            O",
									 "O                                                                                            O",
									 "O                                                                                            O",
									 "O                                                              OOOOOOOOOOOO OOOOOOOO         O",
									 "O                                                             OOOO                           O",
									 "O                                                            OOOO                            O",
									 "O                                                  OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO         O",
									 "O                                                 OOOOOO                                   OOO",
									 "O                                                OOOOOO                                      O",
									 "O                                               OOOOOO                                       O",
									 "OBBBBOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO");
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
			if(map[level[lvl].map[y-1].charAt(x-1)] == "space" ){
				test[0] = 0;
			}else{
				test[0] = 1;
			}
			
			if(map[level[lvl].map[y-1].charAt(x)] == "space" ){
				test[1] = 0;
			}else{
				test[1] = 1;
			}
			
			if(map[level[lvl].map[y-1].charAt(x+1)] == "space" ){
				test[2] = 0;
			}else{
				test[2] = 1;
			}
			
			if(map[level[lvl].map[y].charAt(x-1)] == "space" ){
				test[3] = 0;
			}else{
				test[3] = 1;
			}
			
			test[4] = 1;
			
			if(map[level[lvl].map[y].charAt(x+1)] == "space" ){
				test[5] = 0;
			}else{
				test[5] = 1;
			}
			
			if(map[level[lvl].map[y+1].charAt(x-1)] == "space" ){
				test[6] = 0;
			}else{
				test[6] = 1;
			}
			
			if(map[level[lvl].map[y+1].charAt(x)] == "space" ){
				test[7] = 0;
			}else{
				test[7] = 1;
			}
			
			if(map[level[lvl].map[y+1].charAt(x+1)] == "space" ){
				test[8] = 0;
			}else{
				test[8] = 1;
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
		
		public function GetSpawn(lvl:int, team:String):Point
		{
			for(var y = 0;y < level[lvl].height;y++)
			{
				for(var x = 0;x < level[lvl].width;x++)
				{
					if(GetType(lvl, x, y) == team)
					{
						return new Point(x,y);
					}
				}
			}
			return new Point(-1,-1);
		}
	}
	
	
}