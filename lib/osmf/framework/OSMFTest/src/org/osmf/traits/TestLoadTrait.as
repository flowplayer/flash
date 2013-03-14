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
	
	import org.flexunit.Assert;
	import org.osmf.events.LoadEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.utils.SimpleLoader;
	import org.osmf.utils.SimpleResource;
	
	public class TestLoadTrait
	{
		[Before]
		public function setUp():void
		{
			eventDispatcher = new EventDispatcher();
			eventCount = 0;
			doTwice = false;
			useNullLoader = false;
		}
		
		[After]
		public function tearDown():void
		{
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
			return new LoadTrait(args.length > 0 ? args[0] : null, args.length > 1 ? args[1] : null);
		}

		/**
		 * Subclasses can override to specify their own loader.
		 **/
		protected function createLoader():LoaderBase
		{
			return useNullLoader ? null : new SimpleLoader();
		}
		
		/**
		 * Subclasses can override to specify their own resource.
		 **/
		protected function get successfulResource():MediaResourceBase
		{
			return new SimpleResource(SimpleResource.SUCCESSFUL);
		}

		protected function get failedResource():MediaResourceBase
		{
			return new SimpleResource(SimpleResource.FAILED);
		}

		protected function get unhandledResource():MediaResourceBase
		{
			return new SimpleResource(SimpleResource.UNHANDLED);
		}
		
		protected function get loadIsAsynchronous():Boolean
		{
			return false;
		}
		
		/**
		 * Subclasses can override if the media being loaded has a positive
		 * byte count.
		 **/
		protected function get expectedBytesTotal():Number
		{
			return NaN;
		}
		
		/**
		 * Subclasses can override to indicate that all bytes should be loaded
		 * when the trait enters the READY state.
		 **/
		protected function get allBytesLoadedWhenReady():Boolean
		{
			return false;
		}

		/**
		 * Subclasses can override to indicate that the bytesTotal property should
		 * be set to its correct value when the trait enters the READY state.
		 **/
		protected function get bytesTotalSetWhenReady():Boolean
		{
			return false;
		}
		
		[Test]		
		public function testGetResource():void
		{
			var loadTrait:LoadTrait = createLoadTrait(null);
			
			Assert.assertTrue(loadTrait.resource == null);
			
			var resource:MediaResourceBase = successfulResource;
			
			loadTrait = createLoadTrait(resource);
			
			Assert.assertTrue(loadTrait.resource != null);
			Assert.assertTrue(loadTrait.resource == resource);
		}

		[Test]
		public function testGetLoadState():void
		{
			var loadTrait:LoadTrait = createLoadTrait();
			
			Assert.assertTrue(loadTrait.loadState == LoadState.UNINITIALIZED);
		}
		
		[Test]
		public function testGetBytesLoaded():void
		{
			var loadTrait:LoadTrait = createLoadTrait();
			
			Assert.assertTrue(isNaN(loadTrait.bytesLoaded));
		}

		[Test]
		public function testGetBytesTotal():void
		{
			var loadTrait:LoadTrait = createLoadTrait();
			
			Assert.assertTrue(isNaN(loadTrait.bytesTotal));
		}

		[Test(expects="flash.errors.IllegalOperationError")]
		public function testNullLoader():void
		{
			useNullLoader = true;	
			var loadTrait:LoadTrait = createLoadTrait();
			
			loadTrait.load();				
		}

		[Test(expects="flash.errors.IllegalOperationError")]
		public function testLoadWithInvalidResource():void
		{
			var loadTrait:LoadTrait = createLoadTrait(unhandledResource);
			
			loadTrait.load();
		}
		
		protected final function createLoadTrait(resource:MediaResourceBase=null):LoadTrait
		{
			return createInterfaceObject(createLoader(), resource) as LoadTrait; 
		}
				
		private static const TEST_TIME:int = 5000;
		
		private var eventDispatcher:EventDispatcher;
		private var eventCount:int = 0;
		private var currentLoadTrait:LoadTrait;
		private var doTwice:Boolean;
		private var useNullLoader:Boolean;
	}
}