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
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.SharedObject;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;
	import org.osmf.netmocker.MockNetConnection;
	import org.osmf.netmocker.MockNetStream;
	import org.osmf.player.configuration.PlayerConfiguration;
	
	public class TestPlaybackOptimizationManager
	{	
		[Before]
		public function setup():void
		{
			netConnection = new MockNetConnection();
			netConnection.connect(null);
			netStream = new MockNetStream(netConnection);
			netStream.client = new NetClient();
			
			try {
				var sharedObject:SharedObject = SharedObject.getLocal(STROBE_LSO_NAMESPACE);
				delete sharedObject.data.downloadKbitsPerSecond;
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
			netStream = null;
			netConnection = null;
			try {
				var sharedObject:SharedObject = SharedObject.getLocal(STROBE_LSO_NAMESPACE);
				delete sharedObject.data.downloadKbitsPerSecond;
				sharedObject.flush(10000);
			} 
			catch (ingore:Error) 
			{
				// Ignore this error
			}
		}
		
		[Test(async, timeout="2000")]
		public function testInitialBuffer():void
		{	
			assertEquals(netStream.bufferTime, 0);
			Async.handleEvent(this, netStream, NetStatusEvent.NET_STATUS, onNetStatus, 1000, this);
			netStream.play("http://test/myvideo.flv");
			
			function onNetStatus(event:NetStatusEvent, test:*):void
			{
				trace(event.info.code+":"+event.target);
				trace("netStream.bufferTime="+netStream.bufferTime);
				if (event.info.code == NetStreamCodes.NETSTREAM_PLAY_START)
				{
					assertEquals(netStream.bufferTime, .1);
				}
				else
				{				
					Async.handleEvent(test, netStream, NetStatusEvent.NET_STATUS, onNetStatus, 3000, test);
				}
			}
		}
		
		[Test(async, timeout="2000")]
		public function testBufferFull():void
		{	
			assertEquals(netStream.bufferTime, 0);
			Async.handleEvent(this, netStream, NetStatusEvent.NET_STATUS, onNetStatus, 1000, this);
			
			var configuration:PlayerConfiguration = new PlayerConfiguration();
			var playbackOptimizationManager:PlaybackOptimizationManager = new PlaybackOptimizationManager(configuration);
			playbackOptimizationManager.optimizePlayback(null, netStream, null);
			// Force a NETSTREAM_BUFFER_FULL event
			netStream.play("http://test/myvideo.flv");
			netStream.pause();
			netStream.resume();
			
			function onNetStatus(event:NetStatusEvent, test:*):void
			{
				trace(event.info.code+":"+event.target);
				trace("netStream.bufferTime="+netStream.bufferTime);
				switch (event.info.code)
				{
					case NetStreamCodes.NETSTREAM_BUFFER_FULL:				
						assertEquals(configuration.expandedBufferTime, netStream.bufferTime);
						break;
					default:
						Async.handleEvent(test, netStream, NetStatusEvent.NET_STATUS, onNetStatus, 3000, test);
						break;
				}
			}
		} 	
		
		
		[Test(async, timeout="2000")]
		public function testSeekNotify():void
		{	
			assertEquals(netStream.bufferTime, 0);
			Async.handleEvent(this, netStream, NetStatusEvent.NET_STATUS, onNetStatus, 1000, this);
			
			netStream.expectedDuration=1000;
			
			var configuration:PlayerConfiguration = new PlayerConfiguration();
			var playbackOptimizationManager:PlaybackOptimizationManager = new PlaybackOptimizationManager(configuration);
			playbackOptimizationManager.optimizePlayback(null, netStream, null);
			// Force a NETSTREAM_SEEK_NOTIFY event
			netStream.play("http://test/myvideo.flv");
			netStream.seek(10);
			
			function onNetStatus(event:NetStatusEvent, test:*):void
			{
				trace(event.info.code+":"+event.target);
				trace("netStream.bufferTime="+netStream.bufferTime);
				switch (event.info.code)
				{
					case NetStreamCodes.NETSTREAM_SEEK_NOTIFY:				
						assertEquals(configuration.initialBufferTime, netStream.bufferTime);
						break;
					default:
						Async.handleEvent(test, netStream, NetStatusEvent.NET_STATUS, onNetStatus, 3000, test);
						break;
				}
			}
		} 	
		
		[Test(async, timeout="2000")]
		public function testExpandedBuffer():void
		{	
			assertEquals(netStream.bufferTime, 0);
			Async.handleEvent(this, netStream, NetStatusEvent.NET_STATUS, onNetStatus, 1000, this);
			
			var configuration:PlayerConfiguration = new PlayerConfiguration();
			
			function metricCreationFunction(netStream:NetStream):PlaybackOptimizationMetrics
			{
				var metrics:PlaybackOptimizationMetrics = new PlaybackOptimizationMetrics(netStream);				
				metrics.averageDownloadBytesPerSecond = 2000*128;
				metrics.averagePlaybackBytesPerSecond = 4000*128;
				return metrics;
			};
				
			var playbackOptimizationManager:PlaybackOptimizationManager = new MockPlaybackOptimizationManager(configuration, metricCreationFunction);
			netStream.expectedDuration = 100;
			playbackOptimizationManager.optimizePlayback(null, netStream, null);
			// Force a NETSTREAM_BUFFER_FULL event
			netStream.play("rtmp://test/myvideo");
			netStream.pause();
			netStream.resume();
			function onNetStatus(event:NetStatusEvent, test:*):void
			{
				trace(event.info.code+":"+event.target);
				trace("netStream.bufferTime="+netStream.bufferTime);
				switch (event.info.code)
				{
					case NetStreamCodes.NETSTREAM_BUFFER_FULL:				
						assertEquals(configuration.minContinuousPlaybackTime / 2, netStream.bufferTime);
						break;
					default:
						Async.handleEvent(test, netStream, NetStatusEvent.NET_STATUS, onNetStatus, 3000, test);
						break;
				}
			}
		} 	
		
		[Test(async, timeout="2000")]
		public function testExpandedBufferShortDuration():void
		{	
			assertEquals(netStream.bufferTime, 0);
			Async.handleEvent(this, netStream, NetStatusEvent.NET_STATUS, onNetStatus, 1000, this);
			
			var configuration:PlayerConfiguration = new PlayerConfiguration();
			
			function metricCreationFunction(netStream:NetStream):PlaybackOptimizationMetrics
			{
				var metrics:PlaybackOptimizationMetrics = new PlaybackOptimizationMetrics(netStream);				
				metrics.averageDownloadBytesPerSecond = 2000*128;
				metrics.averagePlaybackBytesPerSecond = 4000*128;
				return metrics;
			};
			
			var playbackOptimizationManager:PlaybackOptimizationManager = new MockPlaybackOptimizationManager(configuration, metricCreationFunction);
			netStream.expectedDuration = 25.1;
			playbackOptimizationManager.optimizePlayback(null, netStream, null);
			// Force a NETSTREAM_BUFFER_FULL event
			netStream.play("rtmp://test/myvideo");
			netStream.pause();
			netStream.resume();
			function onNetStatus(event:NetStatusEvent, test:*):void
			{
				trace(event.info.code+":"+event.target);
				trace("netStream.bufferTime="+netStream.bufferTime);
				switch (event.info.code)
				{
					case NetStreamCodes.NETSTREAM_BUFFER_FULL:				
						// The values are almost equal
						assertTrue(Math.abs(netStream.expectedDuration / 2 - netStream.bufferTime) < 0.5); 
						break;
					default:
						Async.handleEvent(test, netStream, NetStatusEvent.NET_STATUS, onNetStatus, 3000, test);
						break;
				}
			}
		} 	
		
		[Test(async, timeout="20000")]
		public function testExpandedBufferFastNetwork():void
		{	
			assertEquals(netStream.bufferTime, 0);
			Async.handleEvent(this, netStream, NetStatusEvent.NET_STATUS, onNetStatus, 1000, this);
			
			var configuration:PlayerConfiguration = new PlayerConfiguration();
			
			function metricCreationFunction(netStream:NetStream):PlaybackOptimizationMetrics
			{
				var metrics:PlaybackOptimizationMetrics = new PlaybackOptimizationMetrics(netStream);				
				metrics.averageDownloadBytesPerSecond = 4000*128;
				metrics.averagePlaybackBytesPerSecond = 1000*128;
				return metrics;
			};
			
			var playbackOptimizationManager:PlaybackOptimizationManager = new MockPlaybackOptimizationManager(configuration, metricCreationFunction);
			netStream.expectedDuration = 100;
			playbackOptimizationManager.optimizePlayback(null, netStream, null);
			// Force a NETSTREAM_BUFFER_FULL event
			netStream.play("rtmp://test/myvideo");
			netStream.pause();
			netStream.resume();
			function onNetStatus(event:NetStatusEvent, test:*):void
			{
				trace(event.info.code+":"+event.target);
				trace("netStream.bufferTime="+netStream.bufferTime);
				switch (event.info.code)
				{
					case NetStreamCodes.NETSTREAM_BUFFER_FULL:				
						assertEquals(configuration.expandedBufferTime, netStream.bufferTime);
						break;
					default:
						Async.handleEvent(test, netStream, NetStatusEvent.NET_STATUS, onNetStatus, 3000, test);
						break;
				}
			}
		} 	
		
		[Test(async, timeout="2000")]
		public function testExpandedBufferNoDuration():void
		{	
			assertEquals(netStream.bufferTime, 0);
			Async.handleEvent(this, netStream, NetStatusEvent.NET_STATUS, onNetStatus, 1000, this);
			
			var configuration:PlayerConfiguration = new PlayerConfiguration();
			
			function metricCreationFunction(netStream:NetStream):PlaybackOptimizationMetrics
			{
				var metrics:PlaybackOptimizationMetrics = new PlaybackOptimizationMetrics(netStream);				
				metrics.averageDownloadBytesPerSecond = 2000*128;
				metrics.averagePlaybackBytesPerSecond = 4000*128;
				return metrics;
			};
			
			var playbackOptimizationManager:PlaybackOptimizationManager = new MockPlaybackOptimizationManager(configuration, metricCreationFunction);
			playbackOptimizationManager.optimizePlayback(null, netStream, null);
			// Force a NETSTREAM_BUFFER_FULL event
			netStream.play("rtmp://test/myvideo");
			netStream.pause();
			netStream.resume();
			function onNetStatus(event:NetStatusEvent, test:*):void
			{
				trace(event.info.code+":"+event.target);
				trace("netStream.bufferTime="+netStream.bufferTime);
				switch (event.info.code)
				{
					case NetStreamCodes.NETSTREAM_BUFFER_FULL:				
						assertEquals(configuration.initialBufferTime, netStream.bufferTime);
						break;
					default:
						Async.handleEvent(test, netStream, NetStatusEvent.NET_STATUS, onNetStatus, 3000, test);
						break;
				}
			}
		} 	
		[Test]
		public function testInitialConditions():void
		{
			var configuration:PlayerConfiguration = new PlayerConfiguration();
			var playbackOptimizationManager:PlaybackOptimizationManager = new PlaybackOptimizationManager(configuration);
			playbackOptimizationManager.optimizePlayback(null, netStream, null);
			assertEquals(0, netStream.bufferTime);
		}
	
		[Test]
		public function testInitialConditions4DS():void
		{
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("osmf.org");
			var dsItem:DynamicStreamingItem = new DynamicStreamingItem("name", 4000);
			dsResource.streamItems[0] = new DynamicStreamingItem("name1", 1000);
			dsResource.streamItems[1] = new DynamicStreamingItem("name2", 2000);
			dsResource.streamItems[2] = new DynamicStreamingItem("name3", 4000);
			
			var configuration:PlayerConfiguration = new PlayerConfiguration();
			var playbackOptimizationManager:PlaybackOptimizationManager = new PlaybackOptimizationManager(configuration);
			playbackOptimizationManager.downloadBytesPerSecond = 100;
			playbackOptimizationManager.optimizePlayback(null, netStream, dsResource);
			
			assertEquals(0, dsResource.initialIndex);
			//assertEquals(0.1, netStream.bufferTime);
		}
		
		[Test]
		public function testInitialConditions4DSMultiple():void
		{
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("osmf.org");
			dsResource.streamItems[0] = new DynamicStreamingItem("name1", 1000);
			dsResource.streamItems[1] = new DynamicStreamingItem("name2", 2000);
			dsResource.streamItems[2] = new DynamicStreamingItem("name3", 4000);
			
			var configuration:PlayerConfiguration = new PlayerConfiguration();
			var playbackOptimizationManager:PlaybackOptimizationManager = new PlaybackOptimizationManager(configuration);
			playbackOptimizationManager.downloadBytesPerSecond = 3500*128;
			playbackOptimizationManager.optimizePlayback(null, netStream, dsResource);

			assertEquals(1, dsResource.initialIndex);
		}
		
		[Test]
		public function testInitialConditions4DSMultipleLargerThanMax():void
		{
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("osmf.org");
			dsResource.streamItems[0] = new DynamicStreamingItem("name1", 1000);
			dsResource.streamItems[1] = new DynamicStreamingItem("name2", 2000);
			dsResource.streamItems[2] = new DynamicStreamingItem("name3", 4000);
			
			var configuration:PlayerConfiguration = new PlayerConfiguration();
			var playbackOptimizationManager:PlaybackOptimizationManager = new PlaybackOptimizationManager(configuration);
			playbackOptimizationManager.downloadBytesPerSecond = 10500*128;
			playbackOptimizationManager.optimizePlayback(null, netStream, dsResource);
			
			assertEquals(2, dsResource.initialIndex);
		}
		
		[Test]
		public function testInitialConditions4DSMultipleLessThanMin():void
		{
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("osmf.org");
			dsResource.streamItems[0] = new DynamicStreamingItem("name1", 1000);
			dsResource.streamItems[1] = new DynamicStreamingItem("name2", 2000);
			dsResource.streamItems[2] = new DynamicStreamingItem("name3", 4000);
			
			var configuration:PlayerConfiguration = new PlayerConfiguration();
			var playbackOptimizationManager:PlaybackOptimizationManager = new PlaybackOptimizationManager(configuration);
			playbackOptimizationManager.downloadBytesPerSecond = 500*128;
			playbackOptimizationManager.optimizePlayback(null, netStream, dsResource);
			
			assertEquals(0, dsResource.initialIndex);
		}
		
		[Test]
		public function testInitialConditions4DSMultipleEqualToBitrate():void
		{
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("osmf.org");
			dsResource.streamItems[0] = new DynamicStreamingItem("name1", 1000);
			dsResource.streamItems[1] = new DynamicStreamingItem("name2", 2000);
			dsResource.streamItems[2] = new DynamicStreamingItem("name3", 4000);
			
			var configuration:PlayerConfiguration = new PlayerConfiguration();
			var playbackOptimizationManager:PlaybackOptimizationManager = new PlaybackOptimizationManager(configuration);
			playbackOptimizationManager.downloadBytesPerSecond = 2000*1.15 *128; // Including the multiplication constant 
			playbackOptimizationManager.optimizePlayback(null, netStream, dsResource);
			
			assertEquals(1, dsResource.initialIndex);
		}
		
		[Test]
		public function testInitialConditions4DSMultipleNegativeNumber():void
		{
			var dsResource:DynamicStreamingResource = new DynamicStreamingResource("osmf.org");
			dsResource.streamItems[0] = new DynamicStreamingItem("name1", 1000);
			dsResource.streamItems[1] = new DynamicStreamingItem("name2", 2000);
			dsResource.streamItems[2] = new DynamicStreamingItem("name3", 4000);
			
			var configuration:PlayerConfiguration = new PlayerConfiguration();
			var playbackOptimizationManager:PlaybackOptimizationManager = new PlaybackOptimizationManager(configuration);
			playbackOptimizationManager.downloadBytesPerSecond = - 4000 *128;  
			playbackOptimizationManager.optimizePlayback(null, netStream, dsResource);
			
			assertEquals(0, dsResource.initialIndex);
		}
		
		private var netConnection:MockNetConnection;
		private var netStream:MockNetStream;
		private const STROBE_LSO_NAMESPACE:String = "org.osmf.strobemediaplayback.lso";
	}	
}