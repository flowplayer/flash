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
package org.osmf.elements
{
	import __AS3__.vec.Vector;
	
	import flash.errors.IllegalOperationError;
	
	import flexunit.framework.Assert;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.events.ContainerChangeEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.TestMediaElement;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.DynamicMediaElement;
	import org.osmf.utils.DynamicProxyElement;
	import org.osmf.utils.SimpleLoader;

	public class TestProxyElement extends TestMediaElement
	{
		override public function setUp():void
		{
			super.setUp();
			
			traitsAddedCount = 0;
			traitsRemovedCount = 0;
		}
		
		public function testConstructor():void
		{
			// No exception here.
			new ProxyElement(new MediaElement());
			
			// No exception here (though the wrappedElement must be set later).
			new ProxyElement(null);
		}
		
		public function testSetProxiedElement():void
		{
			var proxyElement:ProxyElement = createProxyElement();
			
			// Most operations will fail until the wrappedElement is set.
			try
			{
				proxyElement.resource = new URLResource(null);			
			}
			catch (error:IllegalOperationError)
			{
				Assert.fail();
			}
			
			Assert.assertFalse(proxyElement.hasTrait(MediaTraitType.TIME));
			
			var proxiedElement:DynamicMediaElement
				= new DynamicMediaElement( [MediaTraitType.TIME, MediaTraitType.LOAD]
										 , new SimpleLoader()
										 );

			proxyElement.proxiedElement = proxiedElement;
			
			Assert.assertTrue(proxyElement.hasTrait(MediaTraitType.TIME));
			Assert.assertTrue(proxyElement.hasTrait(MediaTraitType.PLAY) == false);
			
			// Setting a new wrapped element is possible.  Doing so should
			// cause the proxy's traits to change, and for some events to
			// fire.
			//
			
			proxyElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
			proxyElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
			
			var proxiedElement2:DynamicMediaElement
				= new DynamicMediaElement( [MediaTraitType.PLAY, MediaTraitType.LOAD]
										 , new SimpleLoader()
										 );
			
			Assert.assertTrue(traitsAddedCount == 0);
			Assert.assertTrue(traitsRemovedCount == 0);
			
			proxyElement.proxiedElement = proxiedElement2;
			
			Assert.assertTrue(proxyElement.hasTrait(MediaTraitType.TIME) == false);
			Assert.assertTrue(proxyElement.hasTrait(MediaTraitType.PLAY));
			
			Assert.assertTrue(traitsAddedCount == 2);
			Assert.assertTrue(traitsRemovedCount == 2);
			
			// Clearing the wrapped element is also possible.  This should
			// clear out the traits, and make many operations invalid.
			//
			
			proxyElement.proxiedElement = null;
			
			Assert.assertTrue(proxyElement.proxiedElement == null);

			Assert.assertFalse(proxyElement.hasTrait(MediaTraitType.TIME));

			Assert.assertTrue(traitsAddedCount == 2);
			Assert.assertTrue(traitsRemovedCount == 4);
		}
		
		public function testSetProxiedElementWithBaseTraits():void
		{
			// When setting a new proxied element, we should not get events
			// for traits that are overridden or blocked (FM-937).
			//

			var proxyElement:DynamicProxyElement = new DynamicProxyElement(null, [MediaTraitType.LOAD]);
			var blockedTraits:Vector.<String> = new Vector.<String>();
			blockedTraits.push(MediaTraitType.PLAY);
			proxyElement.setBlockedTraits(blockedTraits);

			var proxiedElement:DynamicMediaElement
				= new DynamicMediaElement( [MediaTraitType.PLAY, MediaTraitType.LOAD]
										 , new SimpleLoader()
										 );
										 
			proxyElement.proxiedElement = proxiedElement;

			proxyElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
			proxyElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
			
			var proxiedElement2:DynamicMediaElement
				= new DynamicMediaElement( [MediaTraitType.PLAY, MediaTraitType.LOAD]
										 , new SimpleLoader()
										 );

			proxyElement.proxiedElement = proxiedElement2;
			
			Assert.assertTrue(traitsAddedCount == 0);
			Assert.assertTrue(traitsRemovedCount == 0);
		}
		
		override public function testContainer():void
		{
			var mediaElement:ProxyElement = createMediaElement() as ProxyElement;
			mediaElement.proxiedElement = new MediaElement();
			
			var gatewayA:MediaContainer = new MediaContainer();
			var gatewayB:MediaContainer = new MediaContainer();
			
			Assert.assertNull(mediaElement.container);
			assertDispatches
				( mediaElement
				, [ContainerChangeEvent.CONTAINER_CHANGE]
				, function():void{gatewayA.addMediaElement(mediaElement);}
				);
				
			Assert.assertEquals(gatewayA, mediaElement.container);
			
			assertDispatches
				( mediaElement
				, [ContainerChangeEvent.CONTAINER_CHANGE]
				, function():void{gatewayB.addMediaElement(mediaElement);}
				);
			
			Assert.assertEquals(gatewayB, mediaElement.container);
			
			assertDispatches
				( mediaElement
				, [ContainerChangeEvent.CONTAINER_CHANGE]
				, function():void{mediaElement.container.removeMediaElement(mediaElement);}
				);
				
			Assert.assertNull(mediaElement.container);
		}
		
		public function testMetadataEventPropagation():void
		{
			var proxyElement:ProxyElement = createProxyElement();

			var metadataAdded:Boolean = false;
			
			proxyElement.addEventListener(MediaElementEvent.METADATA_ADD, onMetadataAdd);
			proxyElement.addMetadata("foo", new Metadata());
			
			function onMetadataAdd(event:MediaElementEvent):void
			{
				metadataAdded = true;
			}
			
			Assert.assertTrue(metadataAdded);
		}
		
		// Protected
		//
		
		protected function createProxyElement():ProxyElement
		{
			return new ProxyElement(null);
		}
		
		// Overrides
		//
		
		override protected function createMediaElement():MediaElement
		{
			return new ProxyElement(new MediaElement());
		}
		
		override protected function get hasLoadTrait():Boolean
		{
			return false;
		}
		
		override protected function get resourceForMediaElement():MediaResourceBase
		{
			return new URLResource("http://example.com");
		}
		
		override protected function get existentTraitTypesOnInitialization():Array
		{
			return [];
		}

		override protected function get existentTraitTypesAfterLoad():Array
		{
			return [];
		}
		
		// Internals
		//
		
		private function onTraitAdd(event:MediaElementEvent):void
		{
			traitsAddedCount++;
		}

		private function onTraitRemove(event:MediaElementEvent):void
		{
			traitsRemovedCount++;
		}
		
		private var traitsAddedCount:int;
		private var traitsRemovedCount:int;
	}
}