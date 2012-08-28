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
 **********************************************************/

package
{
	import flexunit.framework.Assert;
	
	import mx.core.Application;
	import mx.core.FlexGlobals;
	
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.flexunit.asserts.fail;
	
	public class TestStrobeMediaPlayback
	{		
		[Before]
		public function setUp():void
		{
			player = new StrobeMediaPlayback();
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
		public function testAddToStage():void
		{
			player.name = "player";
			FlexGlobals.topLevelApplication.stage.addChild(player);
			
			assertStrictlyEquals(player, FlexGlobals.topLevelApplication.stage.getChildByName("player"));
		}

		
		[Test]
		public function testInitialize():void
		{
			try
			{
				player.initialize(PARAMS_ONLY_VIDEO, FlexGlobals.topLevelApplication.stage, FlexGlobals.topLevelApplication.loaderInfo, null);
			}
			catch (e:Error)
			{
				fail(e.message);
			}

		}
		
		[Test]
		public function testInitializeWithPlugins():void
		{
			try
			{
				player.initialize(PARAMS_SINGLE_PLUGIN, FlexGlobals.topLevelApplication.stage, FlexGlobals.topLevelApplication.loaderInfo, null);
			}
			catch (e:Error)
			{
				fail(e.message);
			}
		}
		
		[Test]
		public function testStrobeMediaPlayback():void
		{
			assertNotNull(player);
		}

		private var player:StrobeMediaPlayback;	
		
		/* static */
		
		private static const STAGE_INDEX:uint = 53;
		
		private static const PARAMS_ONLY_VIDEO:Object 
			= { src: "http://media.url/movie.flv" } 
			
		private static const PARAMS_SINGLE_PLUGIN:Object = 
			{ src: "http://media.url/movie.flv"
			, plugin_dummy: "http://path.to/dummy/plugin.swf"
			} 

	}
}