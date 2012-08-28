package org.flowplayer.pseudostreaming.net
{
    import com.adobe.net.URI;

    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.NetStatusEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.NetConnection;
    import flash.net.NetStream;
    import flash.net.URLStream;
    import flash.net.NetStreamAppendBytesAction;
    //import flash.system.Security;
    import flash.utils.ByteArray;
    import flash.utils.setTimeout;

    import org.flowplayer.pseudostreaming.DefaultSeekDataStore;
    import org.flowplayer.util.Log;
    import org.httpclient.HttpClient;
    import org.httpclient.HttpHeader;
    import org.httpclient.HttpRequest;
    import org.httpclient.events.HttpDataEvent;
    import org.httpclient.events.HttpErrorEvent;
    import org.httpclient.events.HttpListener;
    import org.httpclient.events.HttpRequestEvent;
    import org.httpclient.events.HttpStatusEvent;
    import org.httpclient.http.Get;


    public class ByteRangeNetStream extends NetStream
	{
		private var _dataStream:URLStream;
		private var _client:HttpClient;
		private var _httpHeader:HttpHeader;
		private var _eTag:String;
		private var _bytesTotal:uint = 0;
		private var _bytesLoaded:uint = 0;
		private var _seekTime:uint = 0;
		private var _currentURL:String;
		private var _seekDataStore:DefaultSeekDataStore;
		protected var log:Log = new Log(this);
		private var _ended:Boolean;
		private var _serverAcceptsBytes:Boolean;

		
		public function ByteRangeNetStream(connection:NetConnection, peerID:String="connectToFMS")
		{
			super(connection, peerID);	  
			
			
		}
		
		private function onIOError(event:IOErrorEvent):void {
			log.debug("IO error has occured " + event.text);
			dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false, {code:"NetStream.Play.Failed", level:"error", message: event.text})); 
		}
		
		private function onSecurityError(event:SecurityErrorEvent):void {
			log.debug("Security error has occured " + event.text);
			dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false, {code:"NetStream.Play.Failed", level:"error", message: event.text})); 
		}
		
		private function onError(event:HttpErrorEvent):void {
			log.debug("An error has occured " + event.text);
			dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false, {code:"NetStream.Play.Failed", level:"error", message: event.text})); 
		}
		
		private function onTimeoutError(event:HttpErrorEvent):void {
			log.debug("Timeout error has occured " + event.text);
			dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false, {code:"NetStream.Play.Failed", level:"error", message: event.text})); 
		}
		
		private function onComplete(event:HttpRequestEvent):void {
	
			
		}
		
		private function streamComplete():void {
			_seekTime = _seekTime + 1;
			_ended = true;
			this.appendBytesAction(NetStreamAppendBytesAction.END_SEQUENCE);
            dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false, {code:"NetStream.Play.Stop", level:"status"}));
		}
		
		private function onClose(event:Event):void {
	
			//send complete status once the buffer length is finished
			if (_bytesLoaded >= _bytesTotal) {
				setTimeout(streamComplete, this.bufferLength * 1000);
			}
			
		}
		
		private function onStatus(event:HttpStatusEvent):void {
			
			switch (event.response.code) {
				case 404: 
					dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false, {code:"NetStream.Play.StreamNotFound", level:"error"})); 
				break;
				case 200:
				default:
					_eTag = event.response.header.getValue("ETag");
					if (!_bytesTotal) _bytesTotal = event.response.contentLength;
					
					_httpHeader = event.response.header;
					
					if (!_serverAcceptsBytes && _httpHeader.find("Accept-Ranges")) {
						log.debug("Server accepts byte ranges");
						_serverAcceptsBytes = true; 
					}
					
				break;
			}
			
		}
		
		public function getRequestHeader():HttpHeader {
			return _httpHeader;
		}
		
		override public function get bytesTotal():uint {
			return _bytesTotal;
		}
		
		override public function get bytesLoaded():uint {
			return _bytesLoaded;
		}
		
		override public function play(...parameters):void {
			
			super.play(null);

            //#409 cleanup reuse http client
            if (!_client) {
			_client = new HttpClient();
			var httplistener:HttpListener = new HttpListener();
			_client.listener = httplistener;
			
			_client.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_client.addEventListener(HttpDataEvent.DATA, onData);
			_client.addEventListener(HttpStatusEvent.STATUS, onStatus);
			//_client.addEventListener(HttpRequestEvent.COMPLETE, onComplete);
			_client.addEventListener(Event.CLOSE, onClose);
			_client.addEventListener(HttpErrorEvent.ERROR, onError);
			_client.addEventListener(HttpErrorEvent.TIMEOUT_ERROR, onTimeoutError);
			_client.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
            } else {
                _client.cancel();
            }

		
			var uri:URI = new URI(parameters[0]);
			_currentURL = parameters[0];
			var request:HttpRequest = new Get();
			
			_ended = false;
			if (Number(parameters[1]) && DefaultSeekDataStore(parameters[2]) && _serverAcceptsBytes) {
				_seekTime = Number(parameters[1]);
				_seekDataStore = DefaultSeekDataStore(parameters[2]);

				_bytesLoaded = getByteRange(_seekTime);
				
				request.addHeader("If-Range", _eTag);

				request.addHeader("Range", "bytes="+_bytesLoaded+"-");
				super.seek(0);
				this.appendBytesAction(NetStreamAppendBytesAction.RESET_SEEK);
				
				var bytes:ByteArray = new ByteArray();
				appendBytes(bytes);

				dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false, {code:"NetStream.Play.Seek", level:"status"}));
				
			} else {

				//reset seek, bytes loaded and send bytes reset actions
				_seekTime = 0;
				_bytesLoaded = 0;
				//this.appendBytesAction(NetStreamAppendBytesAction.END_SEQUENCE);
				this.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
				dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false, {code:"NetStream.Play.Start", level:"status"}));
				
			}
			
	
			_client.request(uri, request);
		}
		
		private function getByteRange(start:Number):Number {
			return  _seekDataStore.getQueryStringStartValue(start);
		}
		
		override public function seek(seconds:Number):void {
			play(_currentURL, seconds, _seekDataStore);	
		}

		private function onData(event:HttpDataEvent):void {   
            appendBytes(event.bytes);
            _bytesLoaded += event.bytes.length;
        }
		
		override public function get time():Number {
			return _seekTime + super.time;	
		}
		
	}
}