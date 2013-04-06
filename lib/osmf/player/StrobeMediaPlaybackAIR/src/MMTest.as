package
{
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetDataEvent;
	import flash.events.NetMonitorEvent;
	import flash.events.NetStatusEvent;
	import flash.net.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.system.Security 
		
		public class MMTest extends Sprite{
			private var _nmonitor:NetMonitor;
			private var _txtDebug:TextField;
			
			public function MMTest(){
				super();
				
				_nmonitor = new NetMonitor();
				var streams:Vector.<NetStream> = _nmonitor.listStreams(); 
				this._nmonitor.addEventListener(NetMonitorEvent.NET_STREAM_CREATE, netStreamCreate);
				
				_txtDebug = new TextField();
				_txtDebug.background  = true;
				_txtDebug.backgroundColor = 0x333333
				_txtDebug.border = true
				_txtDebug.borderColor = 0xcccccc
				_txtDebug.defaultTextFormat = new TextFormat("Verdana",10,0xffffff,false,null,null,null,null,null,4,4)
				_txtDebug.autoSize= "left"
				_txtDebug.wordWrap = true;
				_txtDebug.width = 350;
				_txtDebug.height = 192;
				
				this._txtDebug.text = "MM Tests:\n\n";
				this.addChild(_txtDebug);
				//this.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
				//this.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			}
			
			public function clean():void{
				this._txtDebug.text = "MM Tests:\n\n";
			}
			
			private function onMouseDown(e:Event):void{
				this.startDrag()
			}
			
			private function onMouseUp(e:Event):void{
				this.stopDrag();
			}
			
			private function netStreamCreate( e:NetMonitorEvent):void{
				this._txtDebug.text += "---netStreamCreate--- \n\n";
				var ns:NetStream = e.netStream;
				ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				ns.addEventListener(NetDataEvent.MEDIA_TYPE_DATA, onStreamData);
				
			}
			
			private function netStatusHandler(e:NetStatusEvent):void{
				this._txtDebug.text += "--netStatusEvent.info.code:"+e.info.code+"\n"
				var ns:NetStream = e.target as NetStream
				
				if (e.info.code=="NetStream.Play.Start"){
					this._txtDebug.text +=  "--Security.pageDomain:" + Security.pageDomain+"\n"
					this._txtDebug.text +=  "--netStream.info.resourceName: " +  ns.info.resourceName+"\n";
					this._txtDebug.text +=  "--netStream.info.isLive(): " +  ns.info.isLive+"\n";
					this._txtDebug.text +=  "--netStream.info.uri: " +  ns.info.uri+"\n\n";
				}
				
			}
			
			private function onStreamData(e:NetDataEvent):void {  
				this._txtDebug.text += "[+]"+"Data event at " + e.timestamp +"\n" ;
				var netStream:NetStream = e.target as NetStream;
				switch( e.info.handler )
				{
					case "onMetaData":
						this._txtDebug.text +=  "--MetaData: " +  stringify( netStream.info.metaData );
						break;
					case "onXMPData":
						this._txtDebug.text +=   "--XMPData: " + stringify( netStream.info.xmpData );
						break;
					default:
						this._txtDebug.text +=   "--" + e.info.handler + ": " + stringify(e.info.args[0]) ;
						
				}
				this._txtDebug.text += "[-]\n\n"
				
			}
			
			private function stringify( object:Object ):String{
				var string:String = "";
				
				var prop:String;
				var comma:Boolean = false;
				for ( prop in object )
				{
					if( comma ) string += ", ";
					else comma = true;
					
					if( typeof(object[prop]) == "object" ) 
					{
						stringify( object[prop] )
					} else    string +=  prop + " = " + object[prop];
				}
				return string;
			}
		}
}