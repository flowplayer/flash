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

package org.osmf.player.elements
{
	import flexunit.framework.Assert;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.flexunit.asserts.assertTrue;
	import org.osmf.player.chrome.metadata.ChromeMetadata;
	import org.osmf.player.chrome.widgets.AutoHideWidget;
	import org.osmf.player.chrome.widgets.Widget;
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaElement;
	import org.osmf.metadata.Metadata;
	import org.osmf.player.chrome.ChromeProvider;
	import org.osmf.player.chrome.ControlBar;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitType;
	
	public class TestControlBarElement
	{		
		[Before]
		public function setUp():void
		{
			var cp:ChromeProvider = ChromeProvider.getInstance();
			if (cp.loaded == false)
			{
				cp.load(null);
			}
			
			controlBarElement = new ControlBarElement();
			viewable = controlBarElement.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
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
		public function testGet_autoHide():void
		{
			controlBarElement.target = new VideoElement();				
			assertFalse((viewable.displayObject as AutoHideWidget).autoHide);
		}
		
		[Test]
		public function testSet_autoHide():void
		{
			controlBarElement.target = new VideoElement();
			controlBarElement.autoHide = true;
			assertStrictlyEquals(true, (viewable.displayObject as AutoHideWidget).autoHide);
		}


		[Test]
		public function testSet_autoHideOnNullTarget():void
		{
			controlBarElement.autoHide = true;
			
			assertTrue(controlBarElement.autoHide);
		}

		[Test]
		public function testSet_autoHideTimeoutOnNullTarget():void
		{
			controlBarElement.autoHideTimeout = AUTOHIDE_TIMEOUT;
			
			//test against the default value
			assertNull((viewable.displayObject as Widget).media);
		}



		
		[Test]
		public function testSet_autoHideTimeout():void
		{	
			controlBarElement.target = new VideoElement();
			controlBarElement.autoHideTimeout = AUTOHIDE_TIMEOUT;
			assertEquals(AUTOHIDE_TIMEOUT, (viewable.displayObject as AutoHideWidget).autoHideTimeout);			
		}
		
		[Test]
		public function testControlBarElement():void
		{
			assertTrue(viewable.displayObject is Widget);
		}
		
		[Test]
		public function testGet_height():void
		{
			assertEquals(INITIAL_HEIGHT, controlBarElement.height);
		}
		
		[Test]
		public function testSet_target():void
		{
			var me:MediaElement = new VideoElement();
			controlBarElement.target = me;

			assertStrictlyEquals(me, (viewable.displayObject as Widget).media);
		}
		
		[Test]
		public function testSet_tintColor():void
		{
			controlBarElement.tintColor = TINT_COLOR;
			
			assertEquals(TINT_COLOR, (viewable.displayObject as Widget).tintColor);
		}
//		
//		[Test]
//		public function testGet_width():void
//		{
//			assertEquals(INITIAL_WIDTH, controlBarElement.width);
//		}
		
		[Test]
		public function testSet_width():void
		{
			controlBarElement.width = 465;
			
			assertEquals(465, controlBarElement.width);
		}
		
		private var controlBarElement:ControlBarElement;
		private var viewable:DisplayObjectTrait;
		
		/* static */
		private static const INITIAL_WIDTH:int = 151;
		private static const WIDTH:int = 465;
		private static const INITIAL_HEIGHT:int = 35;
		private static const AUTOHIDE_TIMEOUT:int = 17;
		private static const TINT_COLOR:int = 0xaa1111;
	}
}