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
package org.osmf.traits
{
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import flexunit.framework.TestCase;
	
	import org.osmf.events.LoaderEvent;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.utils.SimpleResource;
	
	public class TestLoaderBase extends TestCase
	{
		override public function setUp():void
		{
			super.setUp();
			
			_loader = createLoader();
			
			eventDispatcher = new EventDispatcher();
			eventCount = 0;
			mediaErrors = [];
			doTwice = false;
		}
		
		override public function tearDown():void
		{
			super.tearDown();
			
			_loader = null;
			eventDispatcher = null;
		}
		
		protected function createInterfaceObject(... args):Object
		{
			return new LoaderBase();
		}

		//---------------------------------------------------------------------
		
		public function testCanHandleResource():void
		{
			assertTrue(loader.canHandleResource(successfulResource) == true);
			assertTrue(loader.canHandleResource(failedResource) == true);
			assertTrue(loader.canHandleResource(unhandledResource) == false);
		}

		public function testLoad():void
		{
			doTestLoad();
		}

		public function testLoadTwice():void
		{
			doTwice = true;
			doTestLoad();
		}
		
		private function doTestLoad():void
		{
			eventDispatcher.addEventListener("testComplete",addAsync(mustReceiveEvent,TEST_TIME));
						
			loader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onTestLoad);
			loader.load(createLoadTrait(loader, successfulResource));
		}
		
		private function onTestLoad(event:LoaderEvent):void
		{
			assertTrue(event.loader == loader);
			assertTrue(event.loadTrait != null);
			assertTrue(event.type == LoaderEvent.LOAD_STATE_CHANGE);
			
			var reload:Boolean = false;
			
			switch (eventCount)
			{
				case 0:
					assertTrue(event.oldState == LoadState.UNINITIALIZED);
					assertTrue(event.newState == LoadState.LOADING);
					break;
				case 1:
					assertTrue(event.oldState == LoadState.LOADING);
					assertTrue(event.newState == LoadState.READY);
					
					if (doTwice)
					{
						reload = true;
					}
					else
					{
						eventDispatcher.dispatchEvent(new Event("testComplete"));
					}
					break;
				default:
					fail();
			}
			
			eventCount++;
			
			if (reload)
			{
				// Calling load a second time should throw an exception.
				try
				{
					event.loader.load(event.loadTrait);
					
					fail();
				}
				catch (error:IllegalOperationError)
				{
					eventDispatcher.dispatchEvent(new Event("testComplete"));
				}
			}
		}

		public function testLoadWithFailure():void
		{
			doTestLoadWithFailure();
		}
		
		public function testLoadWithFailureThenReload():void
		{
			doTwice = true;
			doTestLoadWithFailure();
		}
		
		private function doTestLoadWithFailure():void
		{
			eventDispatcher.addEventListener("testComplete", addAsync(mustReceiveEvent, TEST_TIME));
			
			loader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onTestLoadWithFailure);
			var loadTrait:LoadTrait = createLoadTrait(loader, failedResource);
			loadTrait.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError); 
			loader.load(loadTrait);
		}
		
		private function onTestLoadWithFailure(event:LoaderEvent):void
		{
			assertTrue(event.loader == loader);
			assertTrue(event.loadTrait != null);
			assertTrue(event.type == LoaderEvent.LOAD_STATE_CHANGE);
			
			var reload:Boolean = false;
			
			switch (eventCount)
			{
				case 0:
					assertTrue(event.oldState == LoadState.UNINITIALIZED);
					assertTrue(event.newState == LoadState.LOADING);
					break;
				case 1:
					assertTrue(event.oldState == LoadState.LOADING);
					assertTrue(event.newState == LoadState.LOAD_ERROR);
					
					if (eventCount == 1 && doTwice)
					{
						reload = true;
					}
					else
					{
						markCompleteOnMediaError(1);
					}
					break;
				case 2:
					assertTrue(doTwice);
										
					assertTrue(event.oldState == LoadState.LOAD_ERROR);
					assertTrue(event.newState == LoadState.LOADING);
					break;
				case 3:
					assertTrue(doTwice);
					
					assertTrue(event.oldState == LoadState.LOADING);
					assertTrue(event.newState == LoadState.LOAD_ERROR);
					
					markCompleteOnMediaError(2);
					break;
				default:
					fail();
			}
			
			eventCount++;
			
			if (reload)
			{
				// Reloading should repeat the failure.
				event.loader.load(event.loadTrait);
			}
		}
		
		private function markCompleteOnMediaError(numExpected:int):void
		{
			if (numExpected == mediaErrors.length)
			{
				// Just verify one of them.
				verifyMediaErrorOnLoadFailure(mediaErrors[0] as MediaError);

				eventDispatcher.dispatchEvent(new Event("testComplete"));
			}
			else
			{
				// Wait a bit, then check again.
				var timer:Timer = new Timer(400);
				timer.addEventListener(TimerEvent.TIMER, onTimer);
				timer.start();
				
				function onTimer(event:TimerEvent):void
				{
					timer.stop();
					timer.removeEventListener(TimerEvent.TIMER, onTimer);
					
					markCompleteOnMediaError(numExpected);
				}
			}
		}

		public function testLoadWithInvalidResource():void
		{
			try
			{
				loader.load(createLoadTrait(loader, unhandledResource));
				
				fail();
			}
			catch (error:IllegalOperationError)
			{
			}
		}

		public function testUnload():void
		{
			doTestUnload();
		}

		public function testUnloadTwice():void
		{
			doTwice = true;
			doTestUnload();
		}
		
		private function doTestUnload():void
		{
			eventDispatcher.addEventListener("testComplete", addAsync(mustReceiveEvent, TEST_TIME));
			
			loader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE,onTestUnload);
			loader.load(createLoadTrait(loader, successfulResource));
		}
		
		private function onTestUnload(event:LoaderEvent):void
		{
			assertTrue(event.loader == loader);
			assertTrue(event.loadTrait != null);
			assertTrue(event.type == LoaderEvent.LOAD_STATE_CHANGE);
			
			var doUnload:Boolean = false;
			
			switch (eventCount)
			{
				case 0:
					assertTrue(event.oldState == LoadState.UNINITIALIZED);
					assertTrue(event.newState == LoadState.LOADING);
					break;
				case 1:
					assertTrue(event.oldState == LoadState.LOADING);
					assertTrue(event.newState == LoadState.READY);
					
					// Now unload.
					doUnload = true;
					
					break;
				case 2:
					assertTrue(event.oldState == LoadState.READY);
					assertTrue(event.newState == LoadState.UNLOADING);
					break;
				case 3:
					assertTrue(event.oldState == LoadState.UNLOADING);
					assertTrue(event.newState == LoadState.UNINITIALIZED);
					
					eventDispatcher.dispatchEvent(new Event("testComplete"));
					break;
					
				default:
					fail();
			}
			
			eventCount++;
			
			if (doUnload)
			{
				event.loader.unload(event.loadTrait);
				
				if (doTwice)
				{
					// Unloading a second time should throw an exception
					// (but the first unload will complete).
					try
					{
						event.loader.unload(event.loadTrait);
						
						fail();
					}
					catch (error:IllegalOperationError)
					{
					}
				}
			}
		}
		
		public function testUnloadWithInvalidResource():void
		{
			try
			{
				loader.unload(createLoadTrait(loader, unhandledResource));
				
				fail();
			}
			catch (error:IllegalOperationError)
			{
			}
		}
		
		//---------------------------------------------------------------------
		
		protected final function createLoader():LoaderBase
		{
			return createInterfaceObject() as LoaderBase; 
		}
		
		protected function setOverriddenLoader(value:LoaderBase):void
		{
			_loader = value;
		}
		
		protected final function get loader():LoaderBase
		{
			return _loader;
		}
		
		protected function createLoadTrait(loader:LoaderBase, resource:MediaResourceBase):LoadTrait
		{
			return new LoadTrait(loader, resource);
		}
		

		protected function get successfulResource():MediaResourceBase
		{
			throw new Error("Subclass must override get successfulResource!");
		}

		protected function get failedResource():MediaResourceBase
		{
			throw new Error("Subclass must override get failedResource!");
		}

		protected function get unhandledResource():MediaResourceBase
		{
			throw new Error("Subclass must override get unhandledResource!");
		}
		
		protected function verifyMediaErrorOnLoadFailure(error:MediaError):void
		{
			// Subclasses can override to check the error's properties.
		}

		private function mustReceiveEvent(event:Event):void
		{
			// Placeholder to ensure an event is received.
		}

		private function mustNotReceiveEvent(event:Event):void
		{
			// Placeholder to ensure an event is NOT received.
			fail();
		}
		
		private function onMediaError(event:MediaErrorEvent):void
		{
			mediaErrors.push(event.error);
		}
		
		private static const TEST_TIME:int = 8000;
		
		private var eventDispatcher:EventDispatcher;
		private var eventCount:int = 0;
		private var mediaErrors:Array;
		private var _loader:LoaderBase;
		private var doTwice:Boolean;
	}
}