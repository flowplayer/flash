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
	import org.osmf.elements.AudioElement;
	import org.osmf.elements.ProxyElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.media.pluginClasses.SimpleVideoPluginInfo;
	import org.osmf.utils.DynamicMediaElement;
	import org.osmf.utils.DynamicReferenceMediaElement;
	import org.osmf.utils.SampleResourceHandler;
	
	import org.flexunit.Assert;
	
	public class TestMediaFactory
	{
		[Before]
		public function setUp():void
		{			
			this.mediaFactory = new MediaFactory();
		}
		
		[Test]
		public function testAddMediaFactoryItem():void
		{
			var id:String = "a1";
			
			var item1:MediaFactoryItem = createMediaFactoryItem(id);
			
			Assert.assertTrue(mediaFactory.getItemById(id) == null);
			
			mediaFactory.addItem(item1);
			Assert.assertTrue(mediaFactory.getItemById(id) == item1);
			Assert.assertTrue(mediaFactory.numItems == 1);
			
			// Adding a second one with the same ID should cause the first
			// to be replaced.
			var item2:MediaFactoryItem = createMediaFactoryItem(id);
			mediaFactory.addItem(item2);
			Assert.assertTrue(mediaFactory.getItemById(id) == item2);
			Assert.assertTrue(mediaFactory.numItems == 1);
		}

		[Test(expects="ArgumentError")]
		public function testAddItemWithInvalidParam():void
		{
			mediaFactory.addItem(null);
		}

		[Test]
		public function testRemoveItem():void
		{
			var id:String = "a1";
			
			var item:MediaFactoryItem = createMediaFactoryItem(id);

			// Calling it on an empty factory is a no-op.
			mediaFactory.removeItem(item);
			
			mediaFactory.addItem(item);
			Assert.assertTrue(mediaFactory.getItemById(id) == item);
			
			mediaFactory.removeItem(item);
			Assert.assertTrue(mediaFactory.getItemById(id) == null);
			
			// Calling it twice is a no-op.
			mediaFactory.removeItem(item);
		}

		[Test(expects="ArgumentError")]
		public function testRemoveItemWithInvalidParam():void
		{
			mediaFactory.removeItem(null);
		}
		
		[Test]
		public function testGetNumItems():void
		{
			Assert.assertTrue(mediaFactory.numItems == 0);
			
			var info1:MediaFactoryItem = createMediaFactoryItem("a1");
			var info2:MediaFactoryItem = createMediaFactoryItem("a2");
			var info3:MediaFactoryItem = createMediaFactoryItem("b3", null, null, MediaFactoryItemType.PROXY);
			var info4:MediaFactoryItem = createMediaFactoryItem("b4", null, null, MediaFactoryItemType.PROXY);
			
			mediaFactory.addItem(info1);
			Assert.assertTrue(mediaFactory.numItems == 1);
			mediaFactory.addItem(info2);
			Assert.assertTrue(mediaFactory.numItems == 2);

			mediaFactory.addItem(info3);
			Assert.assertTrue(mediaFactory.numItems == 3);
			mediaFactory.addItem(info4);
			Assert.assertTrue(mediaFactory.numItems == 4);

			mediaFactory.removeItem(info1);
			Assert.assertTrue(mediaFactory.numItems == 3);
			mediaFactory.removeItem(info2);
			Assert.assertTrue(mediaFactory.numItems == 2);
			
			mediaFactory.removeItem(info3);
			Assert.assertTrue(mediaFactory.numItems == 1);
			mediaFactory.removeItem(info4);
			Assert.assertTrue(mediaFactory.numItems == 0);
		}
		
		[Test]
		public function testGetItemAt():void
		{
			var a1:MediaFactoryItem = createMediaFactoryItem("a1","http://www.example.com/a1");
			var a2:MediaFactoryItem = createMediaFactoryItem("a2","http://www.example.com/a2");
			var a3:MediaFactoryItem = createMediaFactoryItem("a3","http://www.example.com/a3");
			var b1:MediaFactoryItem = createMediaFactoryItem("b1","http://www.example.com/b1", null, MediaFactoryItemType.PROXY);
			var b2:MediaFactoryItem = createMediaFactoryItem("b2","http://www.example.com/b2", null, MediaFactoryItemType.PROXY);
			var b3:MediaFactoryItem = createMediaFactoryItem("b3","http://www.example.com/b3", null, MediaFactoryItemType.PROXY);
			
			mediaFactory.addItem(a1);
			mediaFactory.addItem(b1);
			mediaFactory.addItem(a2);
			mediaFactory.addItem(b2);
			mediaFactory.addItem(a3);
			mediaFactory.addItem(b3);
			
			Assert.assertTrue(mediaFactory.getItemAt(-1) == null);
			Assert.assertTrue(mediaFactory.getItemAt(0) == a1);
			Assert.assertTrue(mediaFactory.getItemAt(1) == a2);
			Assert.assertTrue(mediaFactory.getItemAt(2) == a3);
			Assert.assertTrue(mediaFactory.getItemAt(3) == b1);
			Assert.assertTrue(mediaFactory.getItemAt(4) == b2);
			Assert.assertTrue(mediaFactory.getItemAt(5) == b3);
			Assert.assertTrue(mediaFactory.getItemAt(6) == null);
		}
		
		[Test]
		public function testGetItemById():void
		{
			mediaFactory.addItem(createMediaFactoryItem("a1"));
			mediaFactory.addItem(createMediaFactoryItem("a2"));
			mediaFactory.addItem(createMediaFactoryItem("a3"));
			mediaFactory.addItem(createMediaFactoryItem("b1", null, null, MediaFactoryItemType.PROXY));
			mediaFactory.addItem(createMediaFactoryItem("b2", null, null, MediaFactoryItemType.PROXY));
			mediaFactory.addItem(createMediaFactoryItem("b3", null, null, MediaFactoryItemType.PROXY));
			
			Assert.assertTrue(mediaFactory.getItemById("a1") != null);
			Assert.assertTrue(mediaFactory.getItemById("a2") != null);
			Assert.assertTrue(mediaFactory.getItemById("a3") != null);
			Assert.assertTrue(mediaFactory.getItemById("a4") == null);
			Assert.assertTrue(mediaFactory.getItemById("b1") != null);
			Assert.assertTrue(mediaFactory.getItemById("b2") != null);
			Assert.assertTrue(mediaFactory.getItemById("b3") != null);
			Assert.assertTrue(mediaFactory.getItemById("b4") == null);
			Assert.assertTrue(mediaFactory.getItemById(null) == null);
		}

		[Test]
		public function testCreateMediaElement():void
		{
			var createCount:int = 0;
			
			mediaFactory.addEventListener(MediaFactoryEvent.MEDIA_ELEMENT_CREATE, onTestCreateMediaElement);
			
			var a1:MediaFactoryItem = createMediaFactoryItem("a1","http://www.example.com/a1");
			mediaFactory.addItem(a1);
			
			Assert.assertTrue(mediaFactory.createMediaElement(new URLResource("http://www.example.com")) == null);
			Assert.assertTrue(mediaFactory.createMediaElement(new URLResource("http://www.example.com/a2")) == null);
			Assert.assertTrue(mediaFactory.createMediaElement(null) == null);
			
			Assert.assertTrue(createCount == 0);
			
			var mediaElement:MediaElement = mediaFactory.createMediaElement(new URLResource("http://www.example.com/a1"));
			Assert.assertTrue(mediaElement != null);
			Assert.assertTrue(mediaElement.resource != null);
			Assert.assertTrue(mediaElement.resource is URLResource);
			Assert.assertTrue(URLResource(mediaElement.resource).url.toString() == "http://www.example.com/a1");
			
			Assert.assertTrue(createCount == 1);
			
			function onTestCreateMediaElement(event:MediaFactoryEvent):void
			{
				createCount++;
				
				Assert.assertTrue(event.type == MediaFactoryEvent.MEDIA_ELEMENT_CREATE);
				Assert.assertTrue(event.mediaElement != null);
			}
		}

		[Test]
		public function testCreateMediaElementWithItemsToResolve():void
		{
			var a1:MediaFactoryItem = new MediaFactoryItem("org.osmf.a1", canAlwaysHandleResource, function ():MediaElement { return new VideoElement();});
			mediaFactory.addItem(a1);
			var a2:MediaFactoryItem = new MediaFactoryItem("org.osmf.a2", canAlwaysHandleResource, function ():MediaElement { return new VideoElement();});
			mediaFactory.addItem(a2);
			var a3:MediaFactoryItem = new MediaFactoryItem("org.othr.a3", canAlwaysHandleResource, function ():MediaElement { return new AudioElement();});
			mediaFactory.addItem(a3);
			var a4:MediaFactoryItem = new MediaFactoryItem("org.osmf.a4", canAlwaysHandleResource, function ():MediaElement { return new VideoElement();});
			mediaFactory.addItem(a4);
			
			var mediaElement:MediaElement = mediaFactory.createMediaElement(new URLResource("http://www.example.com/a"));
			Assert.assertTrue(mediaElement is AudioElement);
		}
		
		[Test]
		public function testCreateMediaElementWithInvalidMediaElementCreationFunctionReturnType():void
		{
			var a1:MediaFactoryItem = new MediaFactoryItem
				( "a1"
				, new SampleResourceHandler(null, "http://www.example.com/a1").canHandleResource
				, invalidReturnType
				);
			mediaFactory.addItem(a1);
			
			function invalidReturnType():String
			{
				return "hi";
			}

			Assert.assertTrue(mediaFactory.createMediaElement(new URLResource("http://www.example.com/a1")) == null);
		}
		
		[Test]
		public function testCreateMediaElementWithInvalidMediaElementCreationFunctionParams():void
		{
			var a1:MediaFactoryItem = new MediaFactoryItem
				( "a1"
					, new SampleResourceHandler(null, "http://www.example.com/a1").canHandleResource
					, invalidParams
				);
			mediaFactory.addItem(a1);
			
			function invalidParams(i:int,s:String):MediaElement
			{
				return new MediaElement();
			}
			
			Assert.assertTrue(mediaFactory.createMediaElement(new URLResource("http://www.example.com/a1")) == null);
		}
			
		[Test]
		public function testCreateMediaElementWithInvalidMediaElementCreationFunctionNullReturnValue():void
		{
			var a1:MediaFactoryItem = new MediaFactoryItem
				( "a1"
				, new SampleResourceHandler(null, "http://www.example.com/a1").canHandleResource
				, nullReturnValue
				);
			mediaFactory.addItem(a1);
			
			function nullReturnValue():MediaElement
			{
				return null;
			}
			
			Assert.assertTrue(mediaFactory.createMediaElement(new URLResource("http://www.example.com/a1")) == null);
		}

		[Test]
		public function testCreateMediaElementWithProxy():void
		{
			var standardInfo:MediaFactoryItem = createMediaFactoryItem("standardInfo", "http://www.example.com/standardInfo");
			mediaFactory.addItem(standardInfo);
						
			// By default, createMediaElement creates standard media elements.
			var mediaElement:MediaElement = mediaFactory.createMediaElement(new URLResource("http://www.example.com/standardInfo"));
			Assert.assertTrue(!(mediaElement is ProxyElement));
			Assert.assertTrue(mediaElement is DynamicMediaElement);

			// If we add a proxy media info whose media element is not a proxy,
			// then createMediaElement should return the standard media element.
			var invalidProxyInfo:MediaFactoryItem = createMediaFactoryItem("invalidProxyInfo", "http://www.example.com/standardInfo", null, MediaFactoryItemType.PROXY);
			mediaFactory.addItem(invalidProxyInfo);

			mediaElement = mediaFactory.createMediaElement(new URLResource("http://www.example.com/standardInfo"));
			Assert.assertTrue(!(mediaElement is ProxyElement));
			
			// If we add a proxy media info whose media element is a proxy, then
			// createMediaElement should return a proxy that wraps the standard
			// media element.
			var validProxyInfo:MediaFactoryItem = createProxyMediaFactoryItem("validProxyInfo", "http://www.example.com/standardInfo");
			mediaFactory.addItem(validProxyInfo);

			mediaElement = mediaFactory.createMediaElement(new URLResource("http://www.example.com/standardInfo"));
			Assert.assertTrue(mediaElement is ProxyElement);
			Assert.assertTrue((mediaElement as ProxyElement).proxiedElement is DynamicMediaElement);
			
			// Proxies can go many levels deep.
			var deepProxyInfo:MediaFactoryItem = createProxyMediaFactoryItem("deepProxyInfo", "http://www.example.com/standardInfo");
			mediaFactory.addItem(deepProxyInfo);

			mediaElement = mediaFactory.createMediaElement(new URLResource("http://www.example.com/standardInfo"));
			Assert.assertTrue(mediaElement is ProxyElement);
			Assert.assertTrue((mediaElement as ProxyElement).proxiedElement is ProxyElement);
			Assert.assertTrue(((mediaElement as ProxyElement).proxiedElement as ProxyElement).proxiedElement is DynamicMediaElement);
		}

		//---------------------------------------------------------------------
		
		private function createMediaFactoryItem(id:String, urlToMatch:String=null, args:Array=null, type:String=null):MediaFactoryItem
		{
			return new MediaFactoryItem
					( id
					, new SampleResourceHandler((urlToMatch ? null : canNeverHandleResource), urlToMatch).canHandleResource
					, createDynamicMediaElement
					, type != null ? type : MediaFactoryItemType.STANDARD
					);
		}
		
		private function createDynamicMediaElement():MediaElement
		{
			return new DynamicMediaElement();
		}

		private function createProxyMediaFactoryItem(id:String, urlToMatch:String=null, args:Array=null):MediaFactoryItem
		{
			return new MediaFactoryItem
					( id
					, new SampleResourceHandler((urlToMatch ? null : canNeverHandleResource), urlToMatch).canHandleResource
					, createProxyElement
					, MediaFactoryItemType.PROXY
					);
		}
		
		private function createProxyElement():MediaElement
		{
			return new ProxyElement(null);
		}
		
		private function createReferenceMediaFactoryItem(id:String, urlToMatch:String=null, referenceUrlToMatch:String=null, type:String=null):MediaFactoryItem
		{
			return new ReferenceMediaFactoryItem
					( id
					, new SampleResourceHandler((urlToMatch ? null : canNeverHandleResource), urlToMatch).canHandleResource
					, type != null ? type : MediaFactoryItemType.STANDARD
					, referenceUrlToMatch
					);
		}

		private function canNeverHandleResource(resource:MediaResourceBase):Boolean
		{
			return false;
		}

		private function canAlwaysHandleResource(resource:MediaResourceBase):Boolean
		{
			return true;
		}
		
		private var mediaFactory:MediaFactory;
	}
}

import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaFactoryItemType;
import org.osmf.utils.DynamicReferenceMediaElement;

class ReferenceMediaFactoryItem extends MediaFactoryItem
{
	public function ReferenceMediaFactoryItem(id:String, handler:Function, type:String, referenceUrlToMatch:String)
	{
		super(id, handler, createDynamicReferenceMediaElement, type);
		
		refElement = new DynamicReferenceMediaElement(referenceUrlToMatch);
	}
	
	private function createDynamicReferenceMediaElement():MediaElement
	{
		return refElement;
	}

	private function creationCallback(target:MediaElement):void
	{
		if (refElement.canReferenceMedia(target))
		{
			refElement.addReference(target);
		}
	}

	private var refElement:DynamicReferenceMediaElement;
}
