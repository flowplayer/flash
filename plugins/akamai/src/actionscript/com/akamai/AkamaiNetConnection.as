package com.akamai
{
	import com.akamai.events.*;
	
	import flash.net.NetConnection;
	
 	/**
 	 * @private 
 	 * The AkamaiNetConnection class is used privately by AkamaiConnection.
 	 * 
 	 */
	public class AkamaiNetConnection extends NetConnection
	{
			// Define private variables
            private var _index:uint;
            private var _expectBWDone:Boolean;
            private var _port:String;
            private var _protocol:String;
            private var _bandwidth:Number;
            private var _latency:Number;
            private var _connection:AkamaiConnection;
            private var _nc:NetConnection;

			public function AkamaiNetConnection() {	
				super();
			}
			public function get index():uint {
				return _index;
			}
			public function set index(i:uint):void {
				_index = i;
			}
			public function get expectBWDone():Boolean {
				return _expectBWDone;
			}
			public function set expectBWDone(b:Boolean):void {
				_expectBWDone = b;
			}
			public function get port():String {
				return _port
			}
			public function set port(p:String):void {
				_port= p;
			}
			public function get protocol2():String {
				return _protocol;
			}
			public function set protocol2(p:String):void {
				_protocol = p;
			}
			public function get connection():AkamaiConnection {
				return _connection;
			}
			public function set connection(c:AkamaiConnection):void {
				_connection = c;
			}
			public function get bandwidth():Number {
				return _bandwidth;
			}
			public function get latency():Number {
				return _latency;
			}
			// bandwidth detection methods for FCS 1.7
			public function onBWDone(...args):void {
				if (_expectBWDone && !isNaN(args[0])) {
					_expectBWDone = false;
					_bandwidth = args[0];
					dispatchEvent(new AkamaiNotificationEvent(AkamaiNotificationEvent.BANDWIDTH));  
				}
			};
			public function onBWCheck(p_payload:Number):void {
				return;
			};
			// bandwidth detection methods for FMS 2.5
			public function _onbwcheck(data:Object, ctx:Number):Number {
				return ctx;
			};
			public function _onbwdone(latencyInMs:Number, bandwidthInKbps:Number):void {
				_bandwidth = bandwidthInKbps;
				_latency = latencyInMs;
				dispatchEvent(new AkamaiNotificationEvent(AkamaiNotificationEvent.BANDWIDTH)); 
			};
			
			// live subscription methods
			public function onFCSubscribe(info:Object):void {
				dispatchEvent(new AkamaiStatusEvent(AkamaiStatusEvent.FCSUBSCRIBE,info)); 		
			};
			public function onFCUnsubscribe(info:Object):void {
				if (info.code == "NetStream.Play.Stop") {
					dispatchEvent(new AkamaiStatusEvent(AkamaiStatusEvent.FCUNSUBSCRIBE,info)); 
				}
			};
			// Replay Media Catcher protection
			public function AkamaiVerifyClient(pKey:Object):Object {
				return pKey;
			};
			
	}
}