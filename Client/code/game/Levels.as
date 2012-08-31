package code.game
{	
	import flash.geom.Point;
	import flash.display.MovieClip;

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
			map["I"] = "ice";
			map["L"] = "lava";
			map["X"] = "space";//its used for marking purposes
			
			map["."] = "space";
			map[" "] = "space";
			
			map["1"] = "fire";
			map["a"] = "fire flag";
			
			map["2"] = "water";
			map["b"] = "water flag";


			
			
			
			level[0] = new Object();
			
			level[0].map = new Array("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOIIIIIIIIIIII",
								 	 "O                                                                                   III      I",
									 "O                                                                                    I       I",
									 "O                                                                                        ... I",
									 "O      OOOOOOOOOOOOOOOOOOOOOOOOO   OOOOOOOOOOOOOOO   OOOOOOOOOOOOOO                      .2. I",
									 "O     OOOOOOOOOOOOOOOOOOOOOOOOO   OOOOOOOOOOOOOOOOO   OOOOOOOOOOOOOO                II   ... I",
									 "O                                                                                  IIIIIIIIIII",
									 "O                                                                                            O",
									 "O                                                                                            O",
									 "O                          O                              O                                  O",
									 "O                          OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO                                  O",
									 "O                                            O                                               O",
									 "O                                            O                                               O",
									 "O                                            O                                               O",
									 "O                                            O                                           b   O",
									 "OOBBBOOOOOOOOOOOOOOOOO                       O                   OOOOBBBOOOOOOOOOOOOOOOOOOOOOOO",
									 "O                                            O                  OO                           O",
									 "O                                            O                                               O",
									 "O               OOOOOOOOOOOOOOO              OO                                              O",
									 "O                                            OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO    O",
									 "O                                                                               O       OO   O",
									 "O                                                                               O            O",
									 "OOOOOOOOOOOOOOOO                                                                O            O",
									 "O                                                                               O     OOOOOOOO",
									 "O                                                                               O    OO      O",
									 "O                                                                               O            O",
									 "O               OOOOOOOOOOOOOOO                                                 O            O",
									 "O                             OOOOOOOO                                          OOOOOOOO     O",
									 "O                                    OOOOOO                                            OO    O",
									 "O                                         OO                                                 O",
									 "O   a                                      OO                                                O",
									 "OOOOOOOOOOOOOOOOOOOOOOO                                                                      O",
									 "O          LLOOO    OOOO                                                                     O",
									 "L           LLL             OOOOOO             OOOOO    OOOO IIII LLLL IIII LLLL OOOO    OOOOO",
									 "L  ...       L                                OOOO                                           O",
									 "L  .1.           LL                          OOOOO  .                                     .  O",
									 "L  ...          LLLL                        OOOOOO                                           O",
									 "LLLLLLLLLLLLLLLLLLLLLLLLLLLLOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO");
			level[0].width = level[0].map[0].length;
			level[0].height = level[0].map.length;
			level[0].background = new TutorialBackground();
									 
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