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
	
	import flexunit.framework.Assert;
	
	import org.osmf.events.LoaderEvent;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.utils.SimpleResource;
	
	public class TestLoaderBase
	{
		[Before]
		public function setUp():void
		{
			_loader = createLoader();
			
			eventDispatcher = new EventDispatcher();
			eventCount = 0;
			mediaErrors = [];
			doTwice = false;
		}
		
		[After]
		public function tearDown():void
		{
			_loader = null;
			eventDispatcher = null;
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		protected function createInterfaceObject(... args):Object
		{
			return new LoaderBase();
		}
		
		[Ignore]
		[Test]
		public function testCanHandleResource():void
		{
			Assert.assertTrue(loader.canHandleResource(successfulResource) == true);
			Assert.assertTrue(loader.canHandleResource(failedResource) == true);
			Assert.assertTrue(loader.canHandleResource(unhandledResource) == false);
		}
		
		[Ignore]
		[Test(expect="flash.errors.IllegalOperationError")]
		public function testLoadWithInvalidResource():void
		{
			loader.load(createLoadTrait(loader, unhandledResource));
		}
		
		[Ignore]
		[Test(expect="flash.errors.IllegalOperationError")]
		public function ignore_testUnloadWithInvalidResource():void
		{
			loader.unload(createLoadTrait(loader, unhandledResource));
		}
		
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