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

	import flexunit.framework.Assert;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.events.ContainerChangeEvent;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.metadata.Metadata;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.OSMFStrings;
	import flash.utils.Dictionary;

	public class TestMediaElement
	{
		[Before]
		public function setUp():void
		{		
			_eventDispatcher = new EventDispatcher();
		}
		
		[After]
		public function tearDown():void
		{		
			_eventDispatcher = null;
		}

		[Test(expects="ArgumentError")]
		public function testGetTraitWhenParamIsNull():void
		{
			var mediaElement:MediaElement = createMediaElement();
			
			mediaElement.getTrait(null);
		}

		[Test]
		public function testGetResource():void
		{
			var mediaElement:MediaElement = createMediaElement();
			
			Assert.assertTrue(mediaElement.resource == null);
		}

		[Test]
		public function testSetResource():void
		{
			var mediaElement:MediaElement = createMediaElement();
			
			mediaElement.resource = resourceForMediaElement;
			Assert.assertTrue(mediaElement.resource != null);

			mediaElement.resource = null;
			Assert.assertTrue(mediaElement.resource == null);
		}
		
		[Test]
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
			Assert.assertTrue(addCalled);
			
			mediaElement.addMetadata(nsurl2, meta2);
			
			Assert.assertEquals(mediaElement.getMetadata(nsurl1), meta1);
			Assert.assertEquals(mediaElement.getMetadata(nsurl2), meta2);
			
			// Test addition through the undocumented API results in
			// an event.  (This is how we simulate metadata being added
			// internally.)
			addCalled = false;
			mediaElement.metadata.addValue("foo", meta1);
			Assert.assertEquals(mediaElement.getMetadata("foo"), meta1);
			Assert.assertTrue(addCalled);

			// Test the Catching of Errors
			try
			{
				mediaElement.addMetadata(null, meta1);
				
				Assert.fail();
			}
			catch(error:ArgumentError)
			{
				Assert.assertEquals(error.message, OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			try
			{
				mediaElement.addMetadata(nsurl1, null);
				
				Assert.fail();
			}
			catch(error:ArgumentError)
			{
				Assert.assertEquals(error.message, OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			function onAdd(event:MediaElementEvent):void
			{
				addCalled = true;
				Assert.assertNotNull(event.metadata);				
			}				
		}

		[Test]
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
			
			Assert.assertFalse(removeCalled);
			Assert.assertEquals(mediaElement.removeMetadata(nsurl2), meta2);
			Assert.assertTrue(removeCalled);
			Assert.assertEquals(mediaElement.removeMetadata(nsurl2), null);
			Assert.assertEquals(mediaElement.removeMetadata(nsurl1), meta1);

			// Test removal through the undocumented API results in
			// an event.  (This is how we simulate metadata being removed
			// internally.)
			removeCalled = false;
			mediaElement.addMetadata("foo", meta1);
			Assert.assertEquals(mediaElement.metadata.removeValue("foo"), meta1);
			Assert.assertTrue(removeCalled);

			// Test the Catching of Errors
			try
			{
				mediaElement.removeMetadata(null);
				
				Assert.fail();
			}
			catch(error:ArgumentError)
			{
				Assert.assertEquals(error.message, OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}

			function onRemove(event:MediaElementEvent):void
			{
				removeCalled = true;
				Assert.assertNotNull(event.metadata);				
			}				
		}
		
		[Test]
		public function testGetMetadata():void
		{
			var mediaElement:MediaElement = createMediaElement();
			
			var nsurl1:String = "nsurl1";
			var nsurl2:String = "nsurl2";
			var meta1:Metadata = new Metadata();
			var meta2:Metadata = new Metadata();
			
			mediaElement.addMetadata(nsurl1, meta1);
			mediaElement.addMetadata(nsurl2, meta2);
			
			Assert.assertEquals(mediaElement.getMetadata(nsurl2), meta2);
			Assert.assertEquals(mediaElement.getMetadata(nsurl1), meta1);
			Assert.assertEquals(mediaElement.getMetadata("foo"), null);

			// Test the Catching of Errors
			try
			{
				mediaElement.getMetadata(null);
				
				Assert.fail();
			}
			catch(error:ArgumentError)
			{
				Assert.assertEquals(error.message, OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
		}

		[Test]
		public function testGetMetadataNamespaceURLs():void
		{
			var mediaElement:MediaElement = createMediaElement();
			
			var nsurl1:String = "nsurl1";
			var nsurl2:String = "nsurl2";
			var meta1:Metadata = new Metadata();
			var meta2:Metadata = new Metadata();
			
			mediaElement.addMetadata(nsurl1, meta1);
			mediaElement.addMetadata(nsurl2, meta2);
			
			Assert.assertTrue(mediaElement.metadataNamespaceURLs.length == 2);
			Assert.assertTrue(		(	mediaElement.metadataNamespaceURLs[0] == "nsurl1"
							&&	mediaElement.metadataNamespaceURLs[1] == "nsurl2"
							)
					  	||	(	mediaElement.metadataNamespaceURLs[0] == "nsurl2"
							&&	mediaElement.metadataNamespaceURLs[1] == "nsurl1"
							)
					  );
		}
		
		[Test]
		public function testContainer():void
		{
			var mediaElement:MediaElement = createMediaElement();
			var containerA:MediaContainer = new MediaContainer();
			var containerB:MediaContainer = new MediaContainer();
			
			Assert.assertNull(mediaElement.container);
			assertDispatches
				( mediaElement
				, [ContainerChangeEvent.CONTAINER_CHANGE]
				, function():void{containerA.addMediaElement(mediaElement);}
				);
				
			Assert.assertEquals(containerA, mediaElement.container);
			
			assertDispatches
				( mediaElement
				, [ContainerChangeEvent.CONTAINER_CHANGE]
				, function():void{containerB.addMediaElement(mediaElement);}
				);
			
			Assert.assertEquals(containerB, mediaElement.container);
			
			assertDispatches
				( mediaElement
				, [ContainerChangeEvent.CONTAINER_CHANGE]
				, function():void{containerB.removeMediaElement(mediaElement);}
				);
				
			Assert.assertNull(mediaElement.container);
		}
		
		// Protected
		//
		
		private function verifyHasTrait(mediaElement:MediaElement, expectedTraitTypes:Array):void
		{
			// Verify hasTrait returns true for all expected traits.
			for each (var traitType:String in expectedTraitTypes)
			{
				Assert.assertTrue(mediaElement.hasTrait(traitType) == true);
			}
			
			// Verify hasTrait returns false for all unexpected traits.
			var nonExistentTraitTypes:Array = inverseOf(expectedTraitTypes);
			for each (traitType in nonExistentTraitTypes)
			{
				Assert.assertTrue(mediaElement.hasTrait(traitType) == false);
			}
		}
		
		private function verifyGetTrait(mediaElement:MediaElement, expectedTraitTypes:Array):void
		{
			// Verify getTrait returns a result for all expected traits.
			for each (var traitType:String in expectedTraitTypes)
			{
				Assert.assertTrue(mediaElement.getTrait(traitType) != null);
			}
			
			// Verify getTrait returns false for all unexpected traits.
			var nonExistentTraitTypes:Array = inverseOf(expectedTraitTypes);
			for each (traitType in nonExistentTraitTypes)
			{
				Assert.assertTrue(mediaElement.getTrait(traitType) == null);
			}
		}
		
		protected function assertDispatches(dispatcher:EventDispatcher, types:Array, f:Function, ...arguments):*
		{
			var result:*;
			var dispatched:Dictionary = new Dictionary();
			function handler(event:Event):void
			{
				dispatched[event.type] = true;
			}
			
			var type:String;
			for each (type in types)
			{
				dispatcher.addEventListener(type, handler);
			}
			
			result = f.apply(null, arguments);
			
			for each (type in types)
			{
				dispatcher.removeEventListener(type, handler);
			}
			
			for each (type in types)
			{
				if (dispatched[type] != true)
				{
					Assert.fail("Event of type " + type + " was not fired.");
				}
			}
			
			return result;
		}
		
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
			Assert.fail();
		}
		
		final protected function get eventDispatcher():EventDispatcher
		{
			return _eventDispatcher;
		}
		
		// Internals
		//
		
		private function verifyGetTraitTypes(mediaElement:MediaElement, expectedTraitTypes:Array):void
		{
			Assert.assertTrue(mediaElement.traitTypes != null);
			Assert.assertTrue(mediaElement.traitTypes.length == expectedTraitTypes.length);

			// Verify all expected traits are in traitTypes.
			for each (var traitType:String in expectedTraitTypes)
			{
				Assert.assertTrue(mediaElement.traitTypes.indexOf(traitType) >= 0);
			}
			
			// Verify all other traits are not in traitTypes.
			var nonExistentTraitTypes:Array = inverseOf(expectedTraitTypes);
			for each (traitType in nonExistentTraitTypes)
			{
				Assert.assertTrue(mediaElement.traitTypes.indexOf(traitType) == -1);
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
		
		private var _eventDispatcher:EventDispatcher;
	}
}