package code{
	
	import flash.net.Socket;
	import flash.events.*;
	import flash.utils.Timer;
	
	
	
	public class Connection extends EventDispatcher{
		private var socket:Socket;
		private var closed:Function;
		private var opened:Function;
		
		public var timer:Timer = null;
		
		private var writeQueue:Array;
		private var readQueue:Array;
		private var expectQueue:Array;
		
		private var process:Function;
		
		public var status:String;
		
		static public function EmptyFunction(){}
		static public function Nothing(socket:Socket){}
		
		public function Connection(serverURL:String, port:uint, opened:Function = null, closed:Function = null) {
			this.closed = closed;
			this.opened = opened;
			if(this.closed == null){
				this.closed = EmptyFunction;
			}
			if(this.opened == null){
				this.opened = EmptyFunction;
			}
			socket = new Socket();
			writeQueue = new Array();
			readQueue = new Array();
			expectQueue = new Array();
			
			process = EmptyFunction;
			status = "connecting";
			
			socket.addEventListener(Event.CONNECT, connectHandler); 
			socket.addEventListener(Event.CLOSE, closeHandler);
			socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
			try{
				socket.connect(serverURL,port);
			}catch(e:Error){
				closed()
			}
		}
		
		private function connectHandler(event:Event){
			status = "connected";
			opened();
			process = real_process;
			process();
			timer = new Timer(50,1);
			timer.addEventListener(TimerEvent.TIMER,function(event){flush_loop(timer);});
			timer.start();
		}
		private function flush_loop(timer){
			if(socket.connected){
				socket.flush();
				timer.reset();
				timer.start();
			}
		}
		private function closeHandler(event:Event){
			status = "done";
			if((writeQueue.length !=0) || (readQueue.length != 0)){
				status = "disconnected";
			}
			closed();
		}
		private function dataHandler(event:Event){
			real_process();
		}
		private function ioErrorHandler(event:IOErrorEvent){
			socket.close();
			dispatchEvent(new Disconnect(Disconnect.SERVER_ERROR));
		}
		
		private function real_process(){
			status = "busy";
			while(writeQueue.length){
				writeQueue[0](socket);
				writeQueue[0] = Nothing;
				if(socket.bytesAvailable >= expectQueue[0]){
					writeQueue.shift();
					expectQueue.shift();
					readQueue.shift()(socket);
				}else{
					status = "expecting data";
					break;
				}
			}
			if(status == "busy"){
				status = "free";
			}else if(status == "expecting data"){
				status = "busy";
			}
		}
		
		public function Add(write:Function, size:Number, read:Function){
			writeQueue.push(write);
			readQueue.push(read);
			expectQueue.push(size);
			process();
		}
		public function Continue(write:Function, size:Number, read:Function){
			if((write != Nothing) && readQueue.length){
				throw ("A Connection.Continue function has been called out of order.");
			}
			writeQueue.unshift(write);
			readQueue.unshift(read);
			expectQueue.unshift(size);
			process();
		}
		
	}
}