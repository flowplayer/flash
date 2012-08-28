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
	import __AS3__.vec.Vector;
	
	import flexunit.framework.Assert;
	
	import org.osmf.utils.DynamicMediaElement;
	import org.osmf.utils.SampleResourceHandler;
	
	public class TestMediaFactoryItem
	{
		[Before]
		public function setUp():void
		{			
			createdElements = new Vector.<MediaElement>();
		}
		
		[After]
		public function tearDown():void
		{
			createdElements = null;
		}
		
		[Test]
		public function testConstructor():void
		{
			var item:MediaFactoryItem = new MediaFactoryItem
										( "foo"
										, new SampleResourceHandler(canHandleResource).canHandleResource
										, function ():MediaElement { return null; }
										);
			Assert.assertTrue(item != null);
			
			// Verify that any null param triggers an exception.
			//
			
			try
			{
				item = new MediaFactoryItem
								( null
								, new SampleResourceHandler(canHandleResource).canHandleResource
								, function ():MediaElement { return null; }
								);
				Assert.fail();
			}
			catch (error:ArgumentError)
			{
			}

			try
			{
				item = new MediaFactoryItem
								( "foo"
								, null
								, function ():MediaElement { return null; }
								);
				Assert.fail();
			}
			catch (error:ArgumentError)
			{
			}

			try
			{
				item = new MediaFactoryItem
								( "foo"
								, new SampleResourceHandler(canHandleResource).canHandleResource
								, null
								);
				Assert.fail();
			}
			catch (error:ArgumentError)
			{
			}
		}
		
		[Test]
		public function testGetId():void
		{
			var item:MediaFactoryItem = createMediaFactoryItem("anId");
			Assert.assertTrue(item.id == "anId");
		}
		
		[Test]
		public function testGetCanHandleResourceFunction():void
		{
			var item:MediaFactoryItem = createMediaFactoryItem("id");
			var func:Function = item.canHandleResourceFunction;
			Assert.assertTrue(func != null);
			
			Assert.assertTrue(func.call(null, VALID_RESOURCE) == true);
			Assert.assertTrue(func.call(null, INVALID_RESOURCE) == false);
		}
		
		[Test]
		public function testGetMediaElementCreationFunction():void
		{
			var item:MediaFactoryItem = createMediaFactoryItem("id");
			var func:Function = item.mediaElementCreationFunction;
			Assert.assertTrue(func != null);
			
			var element1:MediaElement = func.call();
			Assert.assertTrue(element1 != null);
			Assert.assertTrue(element1 is DynamicMediaElement);
			var element2:MediaElement = func.call();
			Assert.assertTrue(element2 != null);
			Assert.assertTrue(element2 is DynamicMediaElement);
			Assert.assertTrue(element1 != element2);
		}

		[Test]
		public function testGetType():void
		{
			var item:MediaFactoryItem = createMediaFactoryItem("id");
			Assert.assertTrue(item.type == MediaFactoryItemType.STANDARD);
		}
		
		private function createMediaFactoryItem(id:String):MediaFactoryItem
		{
			return new MediaFactoryItem
					( id
					, new SampleResourceHandler(canHandleResource).canHandleResource
					, createDynamicMediaElement
					);
		}
		
		private function canHandleResource(resource:MediaResourceBase):Boolean
		{
			return resource == VALID_RESOURCE ? true : false;
		}
		
		private function createDynamicMediaElement():MediaElement
		{
			return new DynamicMediaElement();
		}
		
		private function creationCallback(mediaElement:MediaElement):void
		{
			createdElements.push(mediaElement);
		}
		
		private var createdElements:Vector.<MediaElement>;
		
		private static const VALID_RESOURCE:URLResource = new URLResource("http://www.example.com/valid");
		private static const INVALID_RESOURCE:URLResource = new URLResource("http://www.example.com/invalid");
	}
}