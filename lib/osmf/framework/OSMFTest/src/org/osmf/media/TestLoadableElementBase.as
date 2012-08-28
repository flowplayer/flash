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
	
	import flash.events.Event;
	
	import org.osmf.events.LoadEvent;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.DynamicLoadableElement;
	import org.osmf.utils.MockHTTPLoader;
	import org.osmf.utils.NullResource;
	import org.osmf.utils.SimpleLoader;
	import org.osmf.utils.SimpleResource;
	
	import org.flexunit.Assert;
	
	public class TestLoadableElementBase extends TestMediaElement
	{
		override protected function createMediaElement():MediaElement
		{
			return new LoadableElementBase(null, new SimpleLoader()); 
		}
		
		override protected function get hasLoadTrait():Boolean
		{
			return true;
		}
		
		override protected function get resourceForMediaElement():MediaResourceBase
		{
			return new NullResource();
		}
		
		override protected function get existentTraitTypesOnInitialization():Array
		{
			return [MediaTraitType.LOAD];
		}

		override protected function get existentTraitTypesAfterLoad():Array
		{
			return [MediaTraitType.LOAD];
		}
		
		[Test]
		public function testConstructor():void
		{
			new LoadableElementBase(null, new SimpleLoader());
			new LoadableElementBase(null, null);
		}
		
		[Test]
		public function testSetResourceSetsLoader():void
		{
			var alternateLoaders:Vector.<LoaderBase> = new Vector.<LoaderBase>();
			alternateLoaders.push(new MockHTTPLoader());
			alternateLoaders.push(new SimpleLoader());
			var mediaElement:MediaElement = new DynamicLoadableElement(null, null, alternateLoaders);
			
			Assert.assertTrue(mediaElement.getTrait(MediaTraitType.LOAD) == null);
			mediaElement.resource = new URLResource("http://example.com");
			Assert.assertTrue(mediaElement.getTrait(MediaTraitType.LOAD) != null);
			mediaElement.resource = new SimpleResource("foo");
			Assert.assertTrue(mediaElement.getTrait(MediaTraitType.LOAD) != null);
		}
		
		[Test]
		public function testSetResourceWithUnhandleResourceSetsLoader():void
		{
			var alternateLoaders:Vector.<LoaderBase> = new Vector.<LoaderBase>();
			alternateLoaders.push(new MockHTTPLoader());
			alternateLoaders.push(new SimpleLoader());
			var mediaElement:MediaElement = new DynamicLoadableElement(null, null, alternateLoaders);
			
			mediaElement.resource = new SimpleResource(SimpleResource.UNHANDLED);
			Assert.assertTrue(mediaElement.getTrait(MediaTraitType.LOAD) != null);
		}
	}
}