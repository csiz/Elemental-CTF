package code{
	import flash.utils.ByteArray;
	import com.hurlant.crypto.hash.SHA256;
	import flash.utils.Endian;

	public class Utils{
		public static function Standardize(s:String,size:int = 32):ByteArray{
			s = s.slice(0,size);
			while(s.length < size){
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
		
		public static function Strip(source:ByteArray):String{
			var string = source.toString();
			var response = new String();
			for(var i = 0; i < string.length; i++){
				if(string.charCodeAt(i) != 0){
					response += string.charAt(i);
				}
			}
			return response;
		}
	}
	
}