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

package {

	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertTrue;
	import org.osmf.media.PluginInfo;
	import org.osmf.youtube.*;

	public class TestYouTubePlugin
	{
		[Before]
		public function setUp():void
		{
			youtubePlugin = new YouTubePlugin();

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
		public function testYouTubePlugin():void
		{
			assertNotNull(youtubePlugin);
		}

		[Test]
		public function testGetPluginInfo():void
		{
			assertTrue(youtubePlugin.pluginInfo is YouTubePluginInfo);
		}

		private var youtubePlugin:YouTubePlugin;		

	}
}