package code{
	import flash.utils.ByteArray;
	import com.hurlant.crypto.hash.SHA256;
	import flash.utils.Endian;

	public class Utils{
		public static function Standardize(s:String):ByteArray{
			s = s.slice(0,32);
			while(s.length < 32){
				s += String.fromCharCode(0);
			}
			var bytes = new ByteArray();
			bytes.writeUTFBytes(s);
			return bytes;
		}
		
		public static function Hash(id:ByteArray,pass:String):ByteArray{
			var bytes = new ByteArray();
			bytes.writeBytes(id);
			bytes.writeUTFBytes(pass);
			bytes = new SHA256().hash(bytes);
			//bytes.endian = Endian.LITTLE_ENDIAN;

			return bytes;
		}
		
		public static function ReplaceChar(str:String, x:int, what:String):String{
			return (str.slice(0,x) + what + str.slice(x+1));
		}
	}
	
}