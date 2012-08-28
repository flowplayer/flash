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
	import flash.errors.IllegalOperationError;
	
	import flexunit.framework.Assert;
	
	import org.osmf.elements.ImageElement;
	import org.osmf.elements.ImageLoader;
	import org.osmf.elements.VideoElement;
	import org.osmf.net.NetLoader;
	import org.osmf.net.NetLoaderForTest;
	import org.osmf.utils.Version;

	public class TestPluginInfo
	{
		[Test]
		public function testPluginInfo():void
		{
			var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
			items.push
				(	new MediaFactoryItem
						( "test.video"
							, new NetLoaderForTest(null, false).canHandleResource
							, function():MediaElement
							{
								return new VideoElement();
							}
						)
				);
			items.push
				(	new MediaFactoryItem
					( "test.image"
						, new ImageLoader().canHandleResource
						, function():MediaElement
						{
							return new ImageElement();
						}
					)
				);
			
			var pluginInfo:PluginInfo = new PluginInfo(items);
			
			Assert.assertTrue(pluginInfo.numMediaFactoryItems == 2);
			Assert.assertTrue(pluginInfo.getMediaFactoryItemAt(0).id == "test.video");
			Assert.assertTrue(pluginInfo.getMediaFactoryItemAt(1).id == "test.image");
			try
			{
				pluginInfo.getMediaFactoryItemAt(2);
				
				Assert.fail();
			}
			catch (error:RangeError)
			{
			}
			
			Assert.assertTrue(pluginInfo.frameworkVersion == Version.version);
			Assert.assertTrue(pluginInfo.isFrameworkVersionSupported(null) == false);
			Assert.assertTrue(pluginInfo.isFrameworkVersionSupported("") == false);
			Assert.assertTrue(pluginInfo.isFrameworkVersionSupported(Version.version) == true);
		}
	}
}