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
package org.osmf.media
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.events.ContainerChangeEvent;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.flexunit.TestCaseEx;
	import org.osmf.metadata.Metadata;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.OSMFStrings;

	public class TestMediaElement extends TestCaseEx
	{
		override public function setUp():void
		{
			super.setUp();
			
			_eventDispatcher = new EventDispatcher();
		}
		
		override public function tearDown():void
		{
			super.tearDown();
			
			_eventDispatcher = null;
		}
		
		public function testGetTraitTypes():void
		{
			var mediaElement:MediaElement = createMediaElement();
			
			verifyGetTraitTypes(mediaElement, existentTraitTypesOnInitialization);
		}

		public function testGetTraitTypesAfterLoad():void
		{
			if (hasLoadTrait)
			{
				callAfterLoad(verifyGetTraitTypes);
			}
		}

		public function testGetTraitTypesAfterUnload():void
		{
			if (hasLoadTrait)
			{
				// Load the media without calling a verify function.
				var mediaElement:MediaElement = callAfterLoad(null, false);
				
				// Verify it once the load completes.
				callAfterUnload(verifyGetTraitTypes, mediaElement);
			}
		}
				
		public function testHasTrait():void
		{
			var mediaElement:MediaElement = createMediaElement();
			
			verifyHasTrait(mediaElement, existentTraitTypesOnInitialization);
		}

		public function testHasTraitWhenParamIsNull():void
		{
			var mediaElement:MediaElement = createMediaElement();
			
			try
			{
				mediaElement.hasTrait(null);
				
				fail();
			}
			catch (error:ArgumentError)
			{
			}
		}
		
		public function testHasTraitAfterLoad():void
		{
			if (hasLoadTrait)
			{
				callAfterLoad(verifyHasTrait);
			}
		}

		public function testHasTraitAfterUnload():void
		{
			if (hasLoadTrait)
			{
				// Load the media without calling a verify function.
				var mediaElement:MediaElement = callAfterLoad(null, false);
				
				// Verify it once the load completes.
				callAfterUnload(verifyHasTrait, mediaElement);
			}
		}

		public function testGetTrait():void
		{
			var mediaElement:MediaElement = createMediaElement();
			
			verifyGetTrait(mediaElement, existentTraitTypesOnInitialization);
		}

		public function testGetTraitWhenParamIsNull():void
		{
			var mediaElement:MediaElement = createMediaElement();
			
			try
			{
				mediaElement.getTrait(null);
				
				fail();
			}
			catch (error:ArgumentError)
			{
			}
		}
		
		public function testGetTraitAfterLoad():void
		{
			if (hasLoadTrait)
			{
				callAfterLoad(verifyGetTrait);
			}
		}

		public function testGetTraitAfterUnload():void
		{
			if (hasLoadTrait)
			{
				// Load the media without calling a verify function.
				var mediaElement:MediaElement = callAfterLoad(null, false);
				
				// Verify it once the load completes.
				callAfterUnload(verifyGetTrait, mediaElement);
			}
		}

		public function testGetResource():void
		{
			var mediaElement:MediaElement = createMediaElement();
			
			assertTrue(mediaElement.resource == null);
		}

		public function testSetResource():void
		{
			var mediaElement:MediaElement = createMediaElement();
			
			mediaElement.resource = resourceForMediaElement;
			assertTrue(mediaElement.resource != null);

			mediaElement.resource = null;
			assertTrue(mediaElement.resource == null);
		}
		
		public function testAddMetadata():void
		{
			var mediaElement:MediaElement = createMediaElement();
			mediaElement.addEventListener(MediaElementEvent.METADATA_ADD, onAdd);
			var addCalled:Boolean = false;
			
			var nsurl1:String = "nsurl1";
			var nsurl2:String = "nsurl2";
			var meta1:Metadata = new Metadata();
			var meta2:Metadata = new Metadata();
			
			mediaElement.addMetadata(nsurl1, meta1);
			assertTrue(addCalled);
			
			mediaElement.addMetadata(nsurl2, meta2);
			
			assertEquals(mediaElement.getMetadata(nsurl1), meta1);
			assertEquals(mediaElement.getMetadata(nsurl2), meta2);
			
			// Test addition through the undocumented API results in
			// an event.  (This is how we simulate metadata being added
			// internally.)
			addCalled = false;
			mediaElement.metadata.addValue("foo", meta1);
			assertEquals(mediaElement.getMetadata("foo"), meta1);
			assertTrue(addCalled);

			// Test the Catching of Errors
			try
			{
				mediaElement.addMetadata(null, meta1);
				
				fail();
			}
			catch(error:ArgumentError)
			{
				assertEquals(error.message, OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			try
			{
				mediaElement.addMetadata(nsurl1, null);
				
				fail();
			}
			catch(error:ArgumentError)
			{
				assertEquals(error.message, OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			function onAdd(event:MediaElementEvent):void
			{
				addCalled = true;
				assertNotNull(event.metadata);				
			}				
		}

		public function testRemoveMetadata():void
		{
			var mediaElement:MediaElement = createMediaElement();
			mediaElement.addEventListener(MediaElementEvent.METADATA_REMOVE, onRemove);
			var removeCalled:Boolean = false;
			
			var nsurl1:String = "nsurl1";
			var nsurl2:String = "nsurl2";
			var meta1:Metadata = new Metadata();
			var meta2:Metadata = new Metadata();
			
			mediaElement.addMetadata(nsurl1, meta1);
			mediaElement.addMetadata(nsurl2, meta2);
			
			assertFalse(removeCalled);
			assertEquals(mediaElement.removeMetadata(nsurl2), meta2);
			assertTrue(removeCalled);
			assertEquals(mediaElement.removeMetadata(nsurl2), null);
			assertEquals(mediaElement.removeMetadata(nsurl1), meta1);

			// Test removal through the undocumented API results in
			// an event.  (This is how we simulate metadata being removed
			// internally.)
			removeCalled = false;
			mediaElement.addMetadata("foo", meta1);
			assertEquals(mediaElement.metadata.removeValue("foo"), meta1);
			assertTrue(removeCalled);

			// Test the Catching of Errors
			try
			{
				mediaElement.removeMetadata(null);
				
				fail();
			}
			catch(error:ArgumentError)
			{
				assertEquals(error.message, OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}

			function onRemove(event:MediaElementEvent):void
			{
				removeCalled = true;
				assertNotNull(event.metadata);				
			}				
		}
		
		public function testGetMetadata():void
		{
			var mediaElement:MediaElement = createMediaElement();
			
			var nsurl1:String = "nsurl1";
			var nsurl2:String = "nsurl2";
			var meta1:Metadata = new Metadata();
			var meta2:Metadata = new Metadata();
			
			mediaElement.addMetadata(nsurl1, meta1);
			mediaElement.addMetadata(nsurl2, meta2);
			
			assertEquals(mediaElement.getMetadata(nsurl2), meta2);
			assertEquals(mediaElement.getMetadata(nsurl1), meta1);
			assertEquals(mediaElement.getMetadata("foo"), null);

			// Test the Catching of Errors
			try
			{
				mediaElement.getMetadata(null);
				
				fail();
			}
			catch(error:ArgumentError)
			{
				assertEquals(error.message, OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
		}

		public function testGetMetadataNamespaceURLs():void
		{
			var mediaElement:MediaElement = createMediaElement();
			
			var nsurl1:String = "nsurl1";
			var nsurl2:String = "nsurl2";
			var meta1:Metadata = new Metadata();
			var meta2:Metadata = new Metadata();
			
			mediaElement.addMetadata(nsurl1, meta1);
			mediaElement.addMetadata(nsurl2, meta2);
			
			assertTrue(mediaElement.metadataNamespaceURLs.length == 2);
			assertTrue(		(	mediaElement.metadataNamespaceURLs[0] == "nsurl1"
							&&	mediaElement.metadataNamespaceURLs[1] == "nsurl2"
							)
					  	||	(	mediaElement.metadataNamespaceURLs[0] == "nsurl2"
							&&	mediaElement.metadataNamespaceURLs[1] == "nsurl1"
							)
					  );
		}
		
		public function testMediaErrorEventDispatch():void
		{
			if (hasLoadTrait)
			{
				var mediaElement:MediaElement = createMediaElement();
				mediaElement.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
				var loadTrait:LoadTrait = mediaElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
				assertTrue(loadTrait);
				
				eventDispatcher.addEventListener("testComplete", addAsync(mustReceiveEvent, 1000));
				
				var eventCtr:int = 0;
				
				// Make sure error events dispatched on the trait are redispatched
				// on the MediaElement.
				loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(99)));
				loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(MediaErrorCodes.NETSTREAM_FILE_STRUCTURE_INVALID)));
				
				function onMediaError(event:MediaErrorEvent):void
				{
					eventCtr++;
					
					if (eventCtr == 1)
					{
						assertTrue(event.error.errorID == 99);
						assertTrue(event.error.message == "");
						assertTrue(event.target == mediaElement);
					}
					else if (eventCtr == 2)
					{
						assertTrue(event.error.errorID == MediaErrorCodes.NETSTREAM_FILE_STRUCTURE_INVALID);
						assertTrue(event.error.message == "File has invalid structure");
						assertTrue(event.target == mediaElement);
						
						eventDispatcher.dispatchEvent(new Event("testComplete"));
					}
					else fail();
				}
			}
		}
		
		public function testContainer():void
		{
			var mediaElement:MediaElement = createMediaElement();
			var containerA:MediaContainer = new MediaContainer();
			var containerB:MediaContainer = new MediaContainer();
			
			assertNull(mediaElement.container);
			assertDispatches
				( mediaElement
				, [ContainerChangeEvent.CONTAINER_CHANGE]
				, function():void{containerA.addMediaElement(mediaElement);}
				);
				
			assertEquals(containerA, mediaElement.container);
			
			assertDispatches
				( mediaElement
				, [ContainerChangeEvent.CONTAINER_CHANGE]
				, function():void{containerB.addMediaElement(mediaElement);}
				);
			
			assertEquals(containerB, mediaElement.container);
			
			assertDispatches
				( mediaElement
				, [ContainerChangeEvent.CONTAINER_CHANGE]
				, function():void{containerB.removeMediaElement(mediaElement);}
				);
				
			assertNull(mediaElement.container);
		}
		
		// Protected
		//
		
		protected function createMediaElement():MediaElement
		{
			// Subclasses can override to specify the MediaElement subclass
			// to test.
			return new MediaElement(); 
		}
		
		protected function get hasLoadTrait():Boolean
		{
			// Subclasses can override to specify that they start with the
			// LoadTrait.
			return false;
		}
		
		protected function get resourceForMediaElement():MediaResourceBase
		{
			// Subclasses can override to specify a resource that the
			// MediaElement can work with.
			return new URLResource("http://www.example.com");
		}

		protected function get existentTraitTypesOnInitialization():Array
		{
			// Subclasses can override to specify the trait types which are
			// expected upon initialization.
			return [];
		}

		protected function get existentTraitTypesAfterLoad():Array
		{
			// Subclasses can override to specify the trait types which are
			// expected after a load.  Ignored if the MediaElement
			// lacks the LoadTrait.
			return [];
		}
		
		final protected function mustReceiveEvent(event:Event):void
		{
			// Placeholder to ensure an event is received.
		}

		final protected function mustNotReceiveEvent(event:Event):void
		{
			// Placeholder to ensure an event is NOT received.
			fail();
		}
		
		final protected function get eventDispatcher():EventDispatcher
		{
			return _eventDispatcher;
		}
		
		// Internals
		//
		
		private function verifyGetTraitTypes(mediaElement:MediaElement, expectedTraitTypes:Array):void
		{
			assertTrue(mediaElement.traitTypes != null);
			assertTrue(mediaElement.traitTypes.length == expectedTraitTypes.length);

			// Verify all expected traits are in traitTypes.
			for each (var traitType:String in expectedTraitTypes)
			{
				assertTrue(mediaElement.traitTypes.indexOf(traitType) >= 0);
			}
			
			// Verify all other traits are not in traitTypes.
			var nonExistentTraitTypes:Array = inverseOf(expectedTraitTypes);
			for each (traitType in nonExistentTraitTypes)
			{
				assertTrue(mediaElement.traitTypes.indexOf(traitType) == -1);
			}
		}
		
		private function verifyHasTrait(mediaElement:MediaElement, expectedTraitTypes:Array):void
		{
			// Verify hasTrait returns true for all expected traits.
			for each (var traitType:String in expectedTraitTypes)
			{
				assertTrue(mediaElement.hasTrait(traitType) == true);
			}
			
			// Verify hasTrait returns false for all unexpected traits.
			var nonExistentTraitTypes:Array = inverseOf(expectedTraitTypes);
			for each (traitType in nonExistentTraitTypes)
			{
				assertTrue(mediaElement.hasTrait(traitType) == false);
			}
		}
		
		private function verifyGetTrait(mediaElement:MediaElement, expectedTraitTypes:Array):void
		{
			// Verify getTrait returns a result for all expected traits.
			for each (var traitType:String in expectedTraitTypes)
			{
				assertTrue(mediaElement.getTrait(traitType) != null);
			}
			
			// Verify getTrait returns false for all unexpected traits.
			var nonExistentTraitTypes:Array = inverseOf(expectedTraitTypes);
			for each (traitType in nonExistentTraitTypes)
			{
				assertTrue(mediaElement.getTrait(traitType) == null);
			}
		}

		private function callAfterLoad(func:Function, triggerTestCompleteEvent:Boolean=true):MediaElement
		{
			assertTrue(hasLoadTrait);
			
			if (triggerTestCompleteEvent)
			{
				eventDispatcher.addEventListener("testComplete", addAsync(mustReceiveEvent, ASYNC_DELAY));
			}
			
			var mediaElement:MediaElement = createMediaElement();
			mediaElement.resource = resourceForMediaElement;

			var loadTrait:LoadTrait = mediaElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
			assertTrue(loadTrait != null);
			loadTrait.addEventListener
					( LoadEvent.LOAD_STATE_CHANGE
					, onTestCallAfterLoad
					);
			loadTrait.load();
			
			function onTestCallAfterLoad(event:LoadEvent):void
			{
				if (event.loadState == LoadState.READY)
				{
					loadTrait.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onTestCallAfterLoad);
					
					if (func != null)
					{
						func(mediaElement, existentTraitTypesAfterLoad);
					}
					
					if (triggerTestCompleteEvent)
					{
						eventDispatcher.dispatchEvent(new Event("testComplete"));
					}
				}
			}
			
			return mediaElement;
		}
		
		private function callAfterUnload(func:Function, mediaElement:MediaElement):void
		{
			assertTrue(hasLoadTrait);
			
			eventDispatcher.addEventListener("testComplete", addAsync(mustReceiveEvent, ASYNC_DELAY));
			
			var loadTrait:LoadTrait = mediaElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
			assertTrue(loadTrait != null);
			
			// If the MediaElement is not yet loaded, wait until it is.
			if (loadTrait.loadState == LoadState.READY)
			{
				completeCallAfterUnload(func, mediaElement);
			}
			else
			{
				loadTrait.addEventListener
						( LoadEvent.LOAD_STATE_CHANGE
						, onTestCallAfterUnload
						);
						
				function onTestCallAfterUnload(event:LoadEvent):void
				{
					if (event.loadState == LoadState.READY)
					{
						loadTrait.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onTestCallAfterUnload);
						
						completeCallAfterUnload(func, mediaElement);
					}
				}
			}
		}
		
		private function completeCallAfterUnload(func:Function, mediaElement:MediaElement):void
		{
			var loadTrait:LoadTrait = mediaElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
			assertTrue(loadTrait != null);

			loadTrait.addEventListener
					( LoadEvent.LOAD_STATE_CHANGE
					, onTestCompleteCallAfterUnload
					);
			loadTrait.unload();
			
			function onTestCompleteCallAfterUnload(event:LoadEvent):void
			{
				if (event.loadState == LoadState.UNINITIALIZED)
				{
					loadTrait.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onTestCompleteCallAfterUnload);

					func(mediaElement, existentTraitTypesOnInitialization);
					
					eventDispatcher.dispatchEvent(new Event("testComplete"));
				}
			}
		}
		
		private function inverseOf(traitTypes:Array):Array
		{
			var inverseTraitTypes:Array = [];
			
			addIfNotPresent(traitTypes, inverseTraitTypes, MediaTraitType.AUDIO);
			addIfNotPresent(traitTypes, inverseTraitTypes, MediaTraitType.BUFFER);
			addIfNotPresent(traitTypes, inverseTraitTypes, MediaTraitType.DRM);
			addIfNotPresent(traitTypes, inverseTraitTypes, MediaTraitType.DYNAMIC_STREAM);
			addIfNotPresent(traitTypes, inverseTraitTypes, MediaTraitType.LOAD);
			addIfNotPresent(traitTypes, inverseTraitTypes, MediaTraitType.PLAY);
			addIfNotPresent(traitTypes, inverseTraitTypes, MediaTraitType.SEEK);
			addIfNotPresent(traitTypes, inverseTraitTypes, MediaTraitType.TIME);
			addIfNotPresent(traitTypes, inverseTraitTypes, MediaTraitType.DISPLAY_OBJECT);
			
			return inverseTraitTypes;
		}
		
		private function addIfNotPresent(traitTypes:Array, results:Array, traitType:String):void
		{
			if (traitTypes.indexOf(traitType) == -1)
			{
				results.push(traitType);
			}
		}
		
		private static const ASYNC_DELAY:Number = 8000;
		
		private var _eventDispatcher:EventDispatcher;
	}
}