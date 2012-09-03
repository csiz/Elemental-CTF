package code{
	import flash.events.Event;
    public class Disconnect extends Event
	{
		public static const SERVER_ERROR = "server_error";
		
		public function Disconnect(type:String, bubbles:Boolean=false, cancelable:Boolean=false):void
		{
			super(type, bubbles, cancelable);
		}
	}
}
