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
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.utils.Timer;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;
	import org.osmf.net.httpstreaming.dvr.*;
	import org.osmf.netmocker.MockNetConnection;
	import org.osmf.netmocker.MockNetStream;

	public class TestPlaybackOptimizationMetrics
	{
		[Before]
		public function setup():void
		{
			var sharedObject:SharedObject = SharedObject.getLocal(STROBE_LSO_NAMESPACE);
			delete sharedObject.data.downloadKbitsPerSecond;
			try {
				sharedObject.flush(10000);
			} 
			catch (ingore:Error) 
			{
				// Ignore this error
			}
		}
		
		[After]
		public function tearDown():void
		{
			var sharedObject:SharedObject = SharedObject.getLocal(STROBE_LSO_NAMESPACE);
			delete sharedObject.data.downloadKbitsPerSecond;
			try {
				sharedObject.flush(10000);
			} 
			catch (ingore:Error) 
			{
				// Ignore this error
			}
		}

		[Test(async, timeout="20000")] [Ignore]
		public function testProgressive():void
		{
			var netStream:MockProgressiveNetStream;
			var netConnection:MockNetConnection;
			netConnection = new MockNetConnection();
			netConnection.connect(null);			
			netStream = new MockProgressiveNetStream(netConnection);
			netStream.client = new NetClient();
			
			var playbackOptimizationMetrics:PlaybackOptimizationMetrics = new PlaybackOptimizationMetrics(netStream);
			netStream.expectedDuration = 5000;
			netStream.simulatedDownloadBytesPerSecond = 2000;
			netStream.simulatedPlaybackBytesPerSecond = 1000;
			var timer:Timer = new Timer(9000, 1);
			Async.handleEvent(this, timer, TimerEvent.TIMER, onTimer, 15000, this);
			netStream.play("http://example.com/my.flv");
			function onTimer(event:Event, test:*):void
			{
				assertTrue(Math.abs(2 - playbackOptimizationMetrics.downloadRatio) < 0.5 );							
			}
			timer.start();
		}
		
		[Test(async, timeout="20000")] [Ignore]
		public function testRTMP():void
		{
			var netStream:MockProgressiveNetStream;
			var netConnection:MockNetConnection;
			netConnection = new MockNetConnection();
			netConnection.connect(null);			
			netStream = new MockProgressiveNetStream(netConnection);
			netStream.client = new NetClient();
			
			var playbackOptimizationMetrics:PlaybackOptimizationMetrics = new PlaybackOptimizationMetrics(netStream);
			netStream.expectedDuration = 5000;
			netStream.simulatedDownloadBytesPerSecond = 2000;
			netStream.simulatedPlaybackBytesPerSecond = 1000;
			netStream.isProgressive = false;
			var timer:Timer = new Timer(9000, 1);
			Async.handleEvent(this, timer, TimerEvent.TIMER, onTimer, 15000, this);
			netStream.play("rtmp://example.com/my");
			function onTimer(event:Event, test:*):void
			{
				assertTrue(Math.abs(2 - playbackOptimizationMetrics.downloadRatio) < 0.5 );							
			}
			timer.start();
		}
		
		CONFIG::FLASH_10_1
		{			
			[Test(async, timeout="10000")] [Ignore]
			public function testHTTPStream():void
			{
				var netStream:MockHTTPNetStream;
				var netConnection:MockNetConnection;
				netConnection = new MockNetConnection();
				netConnection.connect(null);			
				netStream = new MockHTTPNetStream(netConnection, 0);
				netStream.client = new NetClient();
				
				var playbackOptimizationMetrics:PlaybackOptimizationMetrics = new PlaybackOptimizationMetrics(netStream);
				playbackOptimizationMetrics.averagePlaybackBytesPerSecond = 500;
				netStream.qosInfo = new MockHTTPStreamQoSInfo(2);
				netStream.infoFactory.videoBufferByteLength = 2000;
				netStream.infoFactory.videoBufferLength = 1;
				
				var timer:Timer = new Timer(3000, 1);
				Async.handleEvent(this, timer, TimerEvent.TIMER, onTimer, 5000, this);
				netStream.play("http://example.com/my.flv");
				function onTimer(event:Event, test:*):void
				{
					assertEquals(4000, playbackOptimizationMetrics.averageDownloadBytesPerSecond);							
					assertEquals(2000, playbackOptimizationMetrics.averagePlaybackBytesPerSecond);
				}
				timer.start();
			}
		}
		
		private const STROBE_LSO_NAMESPACE:String = "org.osmf.strobemediaplayback.lso";
	}
}