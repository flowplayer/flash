/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 *  The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 *  (the "License"); you may not use this file except in
 *  compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 **********************************************************/

package org.osmf.net
{
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStreamInfo;
	
	import org.osmf.events.*;
	import org.osmf.net.*;
	import org.osmf.net.httpstreaming.HTTPNetStream;
	import org.osmf.net.httpstreaming.HTTPStreamingFactory;
	import org.osmf.net.httpstreaming.HTTPStreamQoSInfo;
	import org.osmf.net.httpstreaming.dvr.*;
	import org.osmf.net.httpstreaming.f4f.*;
	
	public class MockHTTPNetStream extends HTTPNetStream
	{
		public function MockHTTPNetStream(nc:NetConnection, time:Number)
		{
			var resource:StreamingURLResource = new StreamingURLResource("www.example.com");
			var factory:HTTPStreamingFactory = new HTTPStreamingF4FFactory();
			super(nc, factory, resource)
			
			_time = time;
			_dvrInfo = null;
		}

		override public function get time():Number
		{
			return _time;
		} 
		
		public function set dvrInfo(info:DVRInfo):void
		{
			_dvrInfo = info;
		}
		
		public function set qosInfo(value:HTTPStreamQoSInfo):void
		{
			_qosInfo = value;
		}
		
		override public function get qosInfo():HTTPStreamQoSInfo
		{
			return _qosInfo;
		} 
		
		override public function DVRGetStreamInfo(streamName:Object):void
		{
			this.dispatchEvent(new DVRStreamInfoEvent(DVRStreamInfoEvent.DVRSTREAMINFO, false, false, _dvrInfo));
		}
		
		public function unpublish():void
		{
			dispatchEvent
				( new NetStatusEvent
					( NetStatusEvent.NET_STATUS
					, false
					, false
					, {code:NetStreamCodes.NETSTREAM_PLAY_UNPUBLISH_NOTIFY, level:"status"}
					)
				);
		}
		
		public function get infoFactory():MockNetStreamInfoFactory
		{
			return _infoFactory;
		}
		
		override public function get info():NetStreamInfo
		{
			return _infoFactory.info || super.info;
		}
		
		private var _infoFactory:MockNetStreamInfoFactory = new MockNetStreamInfoFactory();
		private var _time:Number;
		private var _dvrInfo:DVRInfo;
		private var _qosInfo:HTTPStreamQoSInfo;
	}
}