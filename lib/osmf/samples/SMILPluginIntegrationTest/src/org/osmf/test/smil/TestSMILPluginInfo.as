/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.test.smil
{
	import flexunit.framework.TestCase;
	
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.PluginInfo;
	import org.osmf.media.URLResource;
	import org.osmf.smil.SMILPluginInfo;	

	public class TestSMILPluginInfo extends TestCase
	{
		public function testGetMediaFactoryItemAt():void
		{
			var pluginInfo:PluginInfo = new SMILPluginInfo();
			
			assertNotNull(pluginInfo);
			
			var item:MediaFactoryItem = pluginInfo.getMediaFactoryItemAt(0);
			assertNotNull(item);

			var mediaFactory:MediaFactory = new MediaFactory();
			mediaFactory.addItem(item);
			var mediaElement:MediaElement = mediaFactory.createMediaElement(new URLResource(SMILTestConstants.SMIL_DOCUMENT_SEQ_URL));
			assertNotNull(mediaElement);						
		}
		
		public function testGetMediaFactoryItemAtWithBadIndex():void
		{
			var pluginInfo:PluginInfo = new SMILPluginInfo();
			
			assertNotNull(pluginInfo);

			try
			{			
				var item:MediaFactoryItem = pluginInfo.getMediaFactoryItemAt(10);
				fail();
			}
			catch(error:RangeError)
			{
			}
		}
		
		public function testIsFrameworkVersionSupported():void
		{
			var pluginInfo:PluginInfo = new SMILPluginInfo();
			assertNotNull(pluginInfo);
			
			assertEquals(true, pluginInfo.isFrameworkVersionSupported("1.0.0"));
			assertEquals(false, pluginInfo.isFrameworkVersionSupported("0.0.1"));
			assertEquals(false, pluginInfo.isFrameworkVersionSupported("0.5.1"));
			assertEquals(false, pluginInfo.isFrameworkVersionSupported("0.7.0"));
			assertEquals(false, pluginInfo.isFrameworkVersionSupported("0.4.9"));
			assertEquals(false, pluginInfo.isFrameworkVersionSupported(null));
			assertEquals(false, pluginInfo.isFrameworkVersionSupported(""));
			assertEquals(false, pluginInfo.isFrameworkVersionSupported("abc"));
			assertEquals(false, pluginInfo.isFrameworkVersionSupported("foo.bar"));
			assertEquals(false, pluginInfo.isFrameworkVersionSupported("foobar."));
		}
		
		public function testNumMediaInfos():void
		{
			var pluginInfo:PluginInfo = new SMILPluginInfo();
			assertNotNull(pluginInfo);

			assertTrue(pluginInfo.numMediaFactoryItems > 0);			
		}
	}
}
