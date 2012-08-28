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
	
	import org.osmf.net.NetConnectionCodes;

	public class TestMockNetConnection extends TestCase
	{
		override public function setUp():void
		{
			super.setUp();
			
			netConnection = new MockNetConnection();
			netConnection.addEventListener(NetStatusEvent.NET_STATUS, netStatusEventHandler);
			netStatusEvents = new Array();
			eventDispatcher = new EventDispatcher();
		}
		
		override public function tearDown():void
		{
			super.tearDown();
			
			netConnection.removeEventListener(NetStatusEvent.NET_STATUS, netStatusEventHandler);
			netConnection = null;
			netStatusEvents = null;
			netStatusEventCallback = null;
			eventDispatcher = null;
		}
		
		public function testConstructor():void
		{
			assertTrue(netConnection.expectation == NetConnectionExpectation.VALID_CONNECTION);
		}
		
		public function testClose():void
		{
			startAsyncTest();
			
			netStatusEventCallback = function():void
			{
				assertTrue(netStatusEvents.length == 1)
				assertTrue(netStatusEvents[0].code == NetConnectionCodes.CONNECT_CLOSED);
				assertTrue(netStatusEvents[0].level == LEVEL_STATUS);
				
				endAsyncTest();
			}
			
			netConnection.close();
		}
		
		public function testConnectProgressive():void
		{
			startAsyncTest();

			netStatusEventCallback = function():void
			{
				assertTrue(netStatusEvents.length == 1)
				assertTrue(netStatusEvents[0].code == NetConnectionCodes.CONNECT_SUCCESS);
				assertTrue(netStatusEvents[0].level == LEVEL_STATUS);
				
				endAsyncTest();
			}
					
			netConnection.connect(null);
		}

		public function testConnectStreaming():void
		{
			startAsyncTest();

			netStatusEventCallback = function():void
			{
				assertTrue(netStatusEvents.length == 1)
				assertTrue(netStatusEvents[0].code == NetConnectionCodes.CONNECT_SUCCESS);
				assertTrue(netStatusEvents[0].level == LEVEL_STATUS);
				
				endAsyncTest();
			}
			
			netConnection.connect("rtmp://example.com/appName/streamName");
		}
		
		public function testConnectStreamingInvalidServer():void
		{
			startAsyncTest();
			
			netConnection.expectation = NetConnectionExpectation.INVALID_FMS_SERVER;

			netStatusEventCallback = function():void
			{
				if (netStatusEvents.length == 1)
				{
					assertTrue(netStatusEvents[0].code == NetConnectionCodes.CONNECT_FAILED);
					assertTrue(netStatusEvents[0].level == LEVEL_ERROR);
				
					endAsyncTest();
				}
				else fail();
			}
			
			netConnection.connect("rtmp://example.com/appName/streamName");
		}

		public function testConnectStreamingInvalidApplication():void
		{
			startAsyncTest();
			
			netConnection.expectation = NetConnectionExpectation.INVALID_FMS_APPLICATION;

			netStatusEventCallback = function():void
			{
				if (netStatusEvents.length == 1)
				{
					assertTrue(netStatusEvents[0].code == NetConnectionCodes.CONNECT_INVALIDAPP);
					assertTrue(netStatusEvents[0].level == LEVEL_ERROR);
				}
				else if (netStatusEvents.length == 2)
				{
					assertTrue(netStatusEvents[1].code == NetConnectionCodes.CONNECT_CLOSED);
					assertTrue(netStatusEvents[1].level == LEVEL_STATUS);

					endAsyncTest();
				}
				else fail();
			}
			
			netConnection.connect("rtmp://example.com/appName/streamName");
		}

		public function testConnectStreamingRejectedConnection():void
		{
			startAsyncTest();
			
			netConnection.expectation = NetConnectionExpectation.REJECTED_CONNECTION;

			netStatusEventCallback = function():void
			{
				if (netStatusEvents.length == 1)
				{
					assertTrue(netStatusEvents[0].code == NetConnectionCodes.CONNECT_REJECTED);
					assertTrue(netStatusEvents[0].level == LEVEL_ERROR);
				}
				else if (netStatusEvents.length == 2)
				{
					assertTrue(netStatusEvents[1].code == NetConnectionCodes.CONNECT_CLOSED);
					assertTrue(netStatusEvents[1].level == LEVEL_STATUS);

					endAsyncTest();
				}
				else fail();
			}
			
			netConnection.connect("rtmp://example.com/appName/streamName");
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

		private var netConnection:MockNetConnection;
		private var netStatusEvents:Array;
		private var netStatusEventCallback:Function;
		private var eventDispatcher:EventDispatcher;
	}
}