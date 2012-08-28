/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.netmocker
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	
	import flexunit.framework.TestCase;
	
	import org.osmf.net.NetClient;
	import org.osmf.net.NetStreamCodes;
	
	public class TestMockNetStream extends TestCase
	{
		override public function setUp():void
		{
			super.setUp();
			
			netConnection = new MockNetConnection();
			netConnection.connect(null);
			netStream = new MockNetStream(netConnection);
			netStream.client = new NetClient();
			netStream.addEventListener(NetStatusEvent.NET_STATUS, netStatusEventHandler);
			netStatusEvents = new Array();
			eventDispatcher = new EventDispatcher();
		}
		
		override public function tearDown():void
		{
			super.tearDown();
			
			netStream.removeEventListener(NetStatusEvent.NET_STATUS, netStatusEventHandler);
			netStream = null;
			netConnection = null;
			netStatusEvents = null;
			netStatusEventCallback = null;
			eventDispatcher = null;
		}
		
		public function testExpectedDuration():void
		{
			assertTrue(netStream.expectedDuration == 0);
			
			netStream.expectedDuration = 30;
			assertTrue(netStream.expectedDuration == 30); 
		}

		public function testExpectedWidth():void
		{
			assertTrue(netStream.expectedWidth == 0);
			
			netStream.expectedWidth = 30;
			assertTrue(netStream.expectedWidth == 30); 
		}

		public function testExpectedHeight():void
		{
			assertTrue(netStream.expectedHeight == 0);
			
			netStream.expectedHeight = 30;
			assertTrue(netStream.expectedHeight == 30); 
		}

		public function testTime():void
		{
			assertTrue(netStream.time == 0);
		}

		public function testGetMetaData():void
		{
			startAsyncTest(2000);
			
			var client:NetClient = new NetClient();
			client.addHandler("onMetaData", onMetaData);
			netStream.client = client;
			
			netStream.expectedDuration = 33;
			netStream.expectedWidth = 1920;
			netStream.expectedHeight = 1080;
			
			netStream.play();
			
			function onMetaData(info:Object):void
			{
				assertTrue(info.duration == 33);
				assertTrue(info.width == 1920);
				assertTrue(info.height == 1080);
				
				endAsyncTest();
			}
		}

		public function testGetMetaDataWithNegativeDuration():void
		{
			startAsyncTest(2000);
			
			var client:NetClient = new NetClient();
			client.addHandler("onMetaData", onMetaData);
			netStream.client = client;
			
			netStream.expectedDuration = -1;
			netStream.expectedWidth = 1920;
			netStream.expectedHeight = 1080;
			
			netStream.play();
			
			function onMetaData(info:Object):void
			{
				assertTrue(info.duration == -1);
				assertTrue(info.width == 1920);
				assertTrue(info.height == 1080);
				
				endAsyncTest();
			}
		}

		public function testPlay():void
		{
			startAsyncTest(2000);
			
			netStream.expectedDuration = 1;
			
			netStatusEventCallback = function():void
			{
				if (netStatusEvents.length == 1)
				{
					assertTrue(netStatusEvents[0].code == NetStreamCodes.NETSTREAM_PLAY_RESET);
					assertTrue(netStatusEvents[0].level == LEVEL_STATUS);
				}
				else if (netStatusEvents.length == 2)
				{
					assertTrue(netStatusEvents[1].code == NetStreamCodes.NETSTREAM_PLAY_START);
					assertTrue(netStatusEvents[1].level == LEVEL_STATUS);
				}
				else if (netStatusEvents.length == 3)
				{
					assertTrue(netStatusEvents[2].code == NetStreamCodes.NETSTREAM_BUFFER_FULL);
					assertTrue(netStatusEvents[2].level == LEVEL_STATUS);
					
					endAsyncTest();
				}
				else fail();
			}
			
			netStream.play();
		}

		public function testPlayComplete():void
		{
			startAsyncTest(2000);
			
			netStream.expectedDuration = 1;
			
			netStatusEventCallback = function():void
			{
				if (netStatusEvents.length == 1)
				{
					assertTrue(netStatusEvents[0].code == NetStreamCodes.NETSTREAM_PLAY_RESET);
					assertTrue(netStatusEvents[0].level == LEVEL_STATUS);
				}
				else if (netStatusEvents.length == 2)
				{
					assertTrue(netStatusEvents[1].code == NetStreamCodes.NETSTREAM_PLAY_START);
					assertTrue(netStatusEvents[1].level == LEVEL_STATUS);
				}
				else if (netStatusEvents.length == 3)
				{
					assertTrue(netStatusEvents[2].code == NetStreamCodes.NETSTREAM_BUFFER_FULL);
					assertTrue(netStatusEvents[2].level == LEVEL_STATUS);
					
					assertTrue(netStream.time > 0);
				}
				else if (netStatusEvents.length == 4)
				{
					assertTrue(netStatusEvents[3].code == NetStreamCodes.NETSTREAM_PLAY_STOP);
					assertTrue(netStatusEvents[3].level == LEVEL_STATUS);
				}
				else if (netStatusEvents.length == 5)
				{
					assertTrue(netStatusEvents[4].code == NetStreamCodes.NETSTREAM_BUFFER_FLUSH);
					assertTrue(netStatusEvents[4].level == LEVEL_STATUS);
				}
				else if (netStatusEvents.length == 6)
				{
					assertTrue(netStatusEvents[5].code == NetStreamCodes.NETSTREAM_BUFFER_EMPTY);
					assertTrue(netStatusEvents[5].level == LEVEL_STATUS);
					
					assertTrue(netStream.time == 1);
					
					endAsyncTest();
				}
				else fail();
			}
			
			netStream.play();
		}
		
		public function testPause():void
		{
			startAsyncTest(2000);
			
			netStream.expectedDuration = 1;
			
			netStatusEventCallback = function():void
			{
				if (netStatusEvents.length == 1)
				{
					assertTrue(netStatusEvents[0].code == NetStreamCodes.NETSTREAM_PLAY_RESET);
					assertTrue(netStatusEvents[0].level == LEVEL_STATUS);
				}
				else if (netStatusEvents.length == 2)
				{
					assertTrue(netStatusEvents[1].code == NetStreamCodes.NETSTREAM_PLAY_START);
					assertTrue(netStatusEvents[1].level == LEVEL_STATUS);
				}
				else if (netStatusEvents.length == 3)
				{
					assertTrue(netStatusEvents[2].code == NetStreamCodes.NETSTREAM_BUFFER_FULL);
					assertTrue(netStatusEvents[2].level == LEVEL_STATUS);
					
					netStream.pause();
				}
				else if (netStatusEvents.length == 4)
				{
					assertTrue(netStatusEvents[3].code == NetStreamCodes.NETSTREAM_PAUSE_NOTIFY);
					assertTrue(netStatusEvents[3].level == LEVEL_STATUS);
				}
				else if (netStatusEvents.length == 5)
				{
					assertTrue(netStatusEvents[4].code == NetStreamCodes.NETSTREAM_BUFFER_FLUSH);
					assertTrue(netStatusEvents[4].level == LEVEL_STATUS);
					
					endAsyncTest();
				}
				else fail();
			}
			
			netStream.play();
		}
		
		public function testResume():void
		{
			startAsyncTest(2000);
			
			netStream.expectedDuration = 1;
			
			netStatusEventCallback = function():void
			{
				if (netStatusEvents.length == 1)
				{
					assertTrue(netStatusEvents[0].code == NetStreamCodes.NETSTREAM_PLAY_RESET);
					assertTrue(netStatusEvents[0].level == LEVEL_STATUS);
				}
				else if (netStatusEvents.length == 2)
				{
					assertTrue(netStatusEvents[1].code == NetStreamCodes.NETSTREAM_PLAY_START);
					assertTrue(netStatusEvents[1].level == LEVEL_STATUS);
				}
				else if (netStatusEvents.length == 3)
				{
					assertTrue(netStatusEvents[2].code == NetStreamCodes.NETSTREAM_BUFFER_FULL);
					assertTrue(netStatusEvents[2].level == LEVEL_STATUS);
					
					netStream.pause();
				}
				else if (netStatusEvents.length == 4)
				{
					assertTrue(netStatusEvents[3].code == NetStreamCodes.NETSTREAM_PAUSE_NOTIFY);
					assertTrue(netStatusEvents[3].level == LEVEL_STATUS);
				}
				else if (netStatusEvents.length == 5)
				{
					assertTrue(netStatusEvents[4].code == NetStreamCodes.NETSTREAM_BUFFER_FLUSH);
					assertTrue(netStatusEvents[4].level == LEVEL_STATUS);
					
					netStream.resume();
				}
				else if (netStatusEvents.length == 6)
				{
					assertTrue(netStatusEvents[5].code == NetStreamCodes.NETSTREAM_UNPAUSE_NOTIFY);
					assertTrue(netStatusEvents[5].level == LEVEL_STATUS);
				}
				else if (netStatusEvents.length == 7)
				{
					assertTrue(netStatusEvents[6].code == NetStreamCodes.NETSTREAM_PLAY_START);
					assertTrue(netStatusEvents[6].level == LEVEL_STATUS);
				}
				else if (netStatusEvents.length == 8)
				{
					assertTrue(netStatusEvents[7].code == NetStreamCodes.NETSTREAM_BUFFER_FULL);
					assertTrue(netStatusEvents[7].level == LEVEL_STATUS);
					
					endAsyncTest();
				}
				else fail();
			}
			
			netStream.play();
		}
		
		public function testSeek():void
		{
			startAsyncTest(2000);
			
			netStream.expectedDuration = 10;
			
			netStatusEventCallback = function():void
			{
				if (netStatusEvents.length == 1)
				{
					assertTrue(netStatusEvents[0].code == NetStreamCodes.NETSTREAM_SEEK_NOTIFY);
					assertTrue(netStatusEvents[0].level == LEVEL_STATUS);

					// Due to bug FP-1705, the time doesn't get updated until some point
					// after the NetStream.Seek.Notify event.
					assertTrue(netStream.time == 0);
				}
				else if (netStatusEvents.length == 2)
				{
					assertTrue(netStatusEvents[1].code == NetStreamCodes.NETSTREAM_PLAY_START);
					assertTrue(netStatusEvents[1].level == LEVEL_STATUS);
				}
				else if (netStatusEvents.length == 3)
				{
					assertTrue(netStatusEvents[2].code == NetStreamCodes.NETSTREAM_BUFFER_FULL);
					assertTrue(netStatusEvents[2].level == LEVEL_STATUS);
					
					endAsyncTest();
				}
				else fail();
			}
			
			netStream.seek(2);
		}
		
		public function testSeekWhilePlaying():void
		{
			startAsyncTest(2000);
			
			netStream.expectedDuration = 5;
			
			netStatusEventCallback = function():void
			{
				if (netStatusEvents.length == 1)
				{
					assertTrue(netStatusEvents[0].code == NetStreamCodes.NETSTREAM_PLAY_RESET);
					assertTrue(netStatusEvents[0].level == LEVEL_STATUS);
				}
				else if (netStatusEvents.length == 2)
				{
					assertTrue(netStatusEvents[1].code == NetStreamCodes.NETSTREAM_PLAY_START);
					assertTrue(netStatusEvents[1].level == LEVEL_STATUS);
				}
				else if (netStatusEvents.length == 3)
				{
					assertTrue(netStatusEvents[2].code == NetStreamCodes.NETSTREAM_BUFFER_FULL);
					assertTrue(netStatusEvents[2].level == LEVEL_STATUS);
					
					assertTrue(netStream.time > 0);
					
					netStream.seek(0);
				}
				else if (netStatusEvents.length == 4)
				{
					assertTrue(netStatusEvents[3].code == NetStreamCodes.NETSTREAM_SEEK_NOTIFY);
					assertTrue(netStatusEvents[3].level == LEVEL_STATUS);
				}
				else if (netStatusEvents.length == 5)
				{
					assertTrue(netStatusEvents[4].code == NetStreamCodes.NETSTREAM_PLAY_START);
					assertTrue(netStatusEvents[4].level == LEVEL_STATUS);
				}
				else if (netStatusEvents.length == 6)
				{
					assertTrue(netStatusEvents[5].code == NetStreamCodes.NETSTREAM_BUFFER_FULL);
					assertTrue(netStatusEvents[5].level == LEVEL_STATUS);
					
					assertTrue(netStream.time > 0);
					
					endAsyncTest();
				}
				else fail();
			}
			
			netStream.play();
		}
		
		public function testClose():void
		{
			startAsyncTest(2000);
			
			netStream.expectedDuration = 1;
			
			netStatusEventCallback = function():void
			{
				if (netStatusEvents.length == 1)
				{
					assertTrue(netStatusEvents[0].code == NetStreamCodes.NETSTREAM_PLAY_RESET);
					assertTrue(netStatusEvents[0].level == LEVEL_STATUS);
				}
				else if (netStatusEvents.length == 2)
				{
					assertTrue(netStatusEvents[1].code == NetStreamCodes.NETSTREAM_PLAY_START);
					assertTrue(netStatusEvents[1].level == LEVEL_STATUS);
				}
				else if (netStatusEvents.length == 3)
				{
					assertTrue(netStatusEvents[2].code == NetStreamCodes.NETSTREAM_BUFFER_FULL);
					assertTrue(netStatusEvents[2].level == LEVEL_STATUS);
					
					assertTrue(netStream.time > 0);
					
					netStream.close();
					
					assertTrue(netStream.time == 0);
					
					endAsyncTest();
				}
				else fail();
			}
			
			netStream.play();
		}
		
		// Internals
		//
		
		private function netStatusEventHandler(event:NetStatusEvent):void
		{
			netStatusEvents.push(event.info);
			
			if (netStatusEventCallback != null)
			{
				netStatusEventCallback.call();
			}
		}
		
		private function startAsyncTest(timeout:Number=1000):void
		{
			eventDispatcher.addEventListener("testComplete", addAsync(mustReceiveEvent, timeout));
		}

		private function endAsyncTest():void
		{
			eventDispatcher.dispatchEvent(new Event("testComplete"));
		}
		
		private function mustReceiveEvent(event:Event):void
		{
			// Placeholder
		}

		private static const LEVEL_STATUS:String = "status";
		private static const LEVEL_ERROR:String = "error";

		private var useRealNetStream:Boolean;
		private var netConnection:MockNetConnection;
		private var netStream:MockNetStream;
		private var netStatusEvents:Array;
		private var netStatusEventCallback:Function;
		private var eventDispatcher:EventDispatcher;
	}
}