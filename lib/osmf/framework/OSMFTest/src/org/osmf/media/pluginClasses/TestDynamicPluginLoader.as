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
package org.osmf.media.pluginClasses
{
	import flexunit.framework.Assert;
	
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaType;
	import org.osmf.media.URLResource;
	import org.osmf.utils.Version;
	
	/**
	 * Note that because DynamicPluginLoader must make network calls and cannot
	 * be mocked (due to Flash API restrictions around LoaderInfo), we only
	 * test a subset of the functionality here.  The rest is tested in the
	 * integration test suite, under TestDynamicPluginLoaderIntegration.
	 * 
	 * Tests which do not require network access should be added here.
	 * 
	 * Tests which do should be added to TestDynamicPluginLoaderIntegration.
	 **/
	public class TestDynamicPluginLoader
	{
		[Test]
		public function testCanHandleResource():void
		{
			var loader:DynamicPluginLoader = new DynamicPluginLoader(new MediaFactory(), Version.version);

			// Verify some valid resources based on metadata information
			var resource:URLResource = new URLResource("http://example.com/image");
			resource.mediaType = MediaType.SWF;
			Assert.assertTrue(loader.canHandleResource(resource));
			
			resource = new URLResource("http://example.com/image");
			resource.mimeType = "application/x-shockwave-flash";
			Assert.assertTrue(loader.canHandleResource(resource));

			resource = new URLResource("http://example.com/image");
			resource.mediaType = MediaType.SWF;
			resource.mimeType = "application/x-shockwave-flash";
			Assert.assertTrue(loader.canHandleResource(resource));

			// Add some invalid cases based on metadata information
			
			resource = new URLResource("http://example.com/image");
			resource.mediaType = MediaType.IMAGE;
			Assert.assertFalse(loader.canHandleResource(resource));
			
			resource = new URLResource("http://example.com/image");
			resource.mimeType = "Invalid Mime Type";
			Assert.assertFalse(loader.canHandleResource(resource));

			resource = new URLResource("http://example.com/image");
			resource.mediaType = MediaType.SWF;
			resource.mimeType = "Invalid Mime Type";
			Assert.assertFalse(loader.canHandleResource(resource));

			resource = new URLResource("http://example.com/image");
			resource.mediaType = MediaType.IMAGE;
			resource.mimeType = "application/x-shockwave-flash";
			Assert.assertFalse(loader.canHandleResource(resource));

			resource = new URLResource("http://example.com/image");
			resource.mediaType = MediaType.IMAGE;
			resource.mimeType = "Invalid Mime Type";
			Assert.assertFalse(loader.canHandleResource(resource));
		}
		
		public function testLoad():void
		{
			// See TestDynamicPluginLoaderIntegration for the actual tests.
		}

		public function testUnload():void
		{
			// See TestDynamicPluginLoaderIntegration for the actual tests.
		}
	}
}