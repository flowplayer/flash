/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 *  The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 *  (the "License"); you may not use this file except in
 *  compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 * 
 **********************************************************/

package org.osmf.youtube
{
	import flexunit.framework.Assert;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertTrue;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.youtube.elements.YouTubeElement;

	public class TestYoutubePluginInfo
	{		
		[Before]
		public function setUp():void
		{
			youtubePluginInfo = new YouTubePluginInfo();
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
		
		[Test]
		public function testYoutubePluginInfo():void
		{
			assertNotNull(youtubePluginInfo);
		}

		[Test]
		public function testGetMediaFactoryItemAt():void
		{
			assertEquals("com.youtube.YouTubePluginInfo", youtubePluginInfo.getMediaFactoryItemAt(0).id);
		}

		[Test]
		public function testNumMediaFactoryItems():void
		{
			assertEquals(1, youtubePluginInfo.numMediaFactoryItems);
		}

		[Test]
		public function testMediaElementCreationFunction():void
		{
			var mediaFactoryItem:MediaFactoryItem
					= youtubePluginInfo.getMediaFactoryItemAt(0);

			assertTrue(mediaFactoryItem.mediaElementCreationFunction.call() is YouTubeElement);
		}

		private var youtubePluginInfo:YouTubePluginInfo;
	}
}