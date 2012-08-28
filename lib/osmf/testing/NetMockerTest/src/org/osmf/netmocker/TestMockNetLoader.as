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
	import flexunit.framework.Assert;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.net.NetStreamLoadTrait;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.traits.TestLoaderBase;
	import org.osmf.utils.NullResource;
	import org.osmf.utils.TestConstants;
	
	public class TestMockNetLoader extends TestLoaderBase
	{
		override public function setUp():void
		{
			netLoader = new MockNetLoader();

			super.setUp();
		}
		
		override public function tearDown():void
		{
			super.tearDown();
			
			netLoader = null;
		}
		
		public function testConstructor():void
		{
			Assert.assertTrue(netLoader.netConnectionExpectation == NetConnectionExpectation.VALID_CONNECTION);
			Assert.assertTrue(netLoader.netStreamExpectedDuration == 0);
			Assert.assertTrue(netLoader.netStreamExpectedHeight == 0);
			Assert.assertTrue(netLoader.netStreamExpectedWidth == 0);
			Assert.assertTrue(netLoader.netStreamExpectedEvents.length == 0);
		}
		
		override protected function createInterfaceObject(... args):Object
		{
			return netLoader;
		}
		
		override protected function createLoadTrait(loader:LoaderBase, resource:MediaResourceBase):LoadTrait
		{
			if (resource == successfulResource)
			{
				netLoader.netConnectionExpectation = NetConnectionExpectation.VALID_CONNECTION;
			}
			else if (resource == failedResource)
			{
				netLoader.netConnectionExpectation = NetConnectionExpectation.REJECTED_CONNECTION;
			}
			else if (resource == unhandledResource)
			{
				netLoader.netConnectionExpectation = NetConnectionExpectation.REJECTED_CONNECTION;
			}
			return new NetStreamLoadTrait(netLoader, resource);
		}
		
		override protected function get successfulResource():MediaResourceBase
		{
			return SUCCESSFUL_RESOURCE;
		}

		override protected function get failedResource():MediaResourceBase
		{
			return UNSUCCESSFUL_RESOURCE;
		}

		override protected function get unhandledResource():MediaResourceBase
		{
			return UNHANDLED_RESOURCE;
		}

		private static const SUCCESSFUL_RESOURCE:URLResource = new URLResource(TestConstants.REMOTE_STREAMING_VIDEO);
		private static const UNSUCCESSFUL_RESOURCE:URLResource = new URLResource(TestConstants.INVALID_STREAMING_VIDEO);
		private static const UNHANDLED_RESOURCE:NullResource = new NullResource();
		
		private var netLoader:MockNetLoader;
	}
}