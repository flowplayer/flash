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

package org.osmf.player.utils 
{
	import flash.geom.Rectangle;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.asserts.fail;
	import org.osmf.elements.LightweightVideoElement;
	import org.osmf.elements.ProxyElement;
	import org.osmf.media.MediaElement;
	import org.osmf.player.configuration.VideoRenderingMode;
	import org.osmf.player.errors.StrobePlayerError;
	import org.osmf.player.errors.StrobePlayerErrorCodes;
	

	public class TestVideoRenderingUtils
	{		
		[Before]
		public function setUp():void
		{
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
		
		[test]
		public function testComputeOptimalFullScreenSourceRectSame():void
		{
			var rect:Rectangle = VideoRenderingUtils.computeOptimalFullScreenSourceRect(1920, 1080, 1920, 1080);
			assertEquals(1920, rect.width);
			assertEquals(1080, rect.height);
		}
		
		[Test]
		public function testComputeOptimalFullScreenSourceRectHalf():void
		{
			var rect:Rectangle = VideoRenderingUtils.computeOptimalFullScreenSourceRect(1000, 1000, 500, 500);
			assertEquals(500, rect.width);
			assertEquals(500, rect.height);
		}
		
		[Test]
		public function testComputeOptimalFullScreenSourceRectW():void
		{
			var rect:Rectangle = VideoRenderingUtils.computeOptimalFullScreenSourceRect(1920, 1080, 640, 480);
			assertEquals(1920/1080, rect.width/rect.height);
		}
		
		[Test]
		public function testComputeOptimalFullScreenSourceRectH():void
		{
			var rect:Rectangle = VideoRenderingUtils.computeOptimalFullScreenSourceRect(1920, 1080, 480, 640);
			assertEquals((1920/1080).toFixed(5), (rect.width/rect.height).toFixed(5));
		}
		
		
		[Test]
		public function testComputeOptimalFullScreenSourceRectSmallScreen():void
		{
			var rect:Rectangle = VideoRenderingUtils.computeOptimalFullScreenSourceRect(640, 480, 1920, 1080);
			assertEquals(640/480, rect.width/rect.height);
		}
		
		[Test]
		public function testDetermineSmoothingDualHQ():void
		{
			var smoothing:Boolean = VideoRenderingUtils.determineSmoothing(VideoRenderingMode.AUTO, true);		
			assertEquals(false, smoothing);
		}
		
		[Test]
		public function testDetermineSmoothingDualSQ():void
		{
			var smoothing:Boolean = VideoRenderingUtils.determineSmoothing(VideoRenderingMode.AUTO, false);		
			assertEquals(true, smoothing);
		}
		
		[Test]
		public function testDetermineSmoothingEnabled():void
		{
			var smoothing:Boolean = VideoRenderingUtils.determineSmoothing(VideoRenderingMode.SMOOTHING, false);		
			assertEquals(true, smoothing);
		}		
		
		[Test]
		public function testDetermineSmoothingDisabled():void
		{
			var smoothing:Boolean = VideoRenderingUtils.determineSmoothing(VideoRenderingMode.NONE, false);		
			assertEquals(false, smoothing);
		}
		

		[Test]
		public function testDetermineSmoothingException():void
		{
			try
			{
				var smoothing:Boolean = VideoRenderingUtils.determineSmoothing(67, false);		
				fail("Should have thrown an exception");
			}
			catch(e:*)
			{
				assertTrue("Error of the wrong type", e is StrobePlayerError);
				assertEquals("Wrong error code", StrobePlayerErrorCodes.ILLEGAL_INPUT_VARIABLE, e.errorID);
				assertEquals("Wrong message", "Illegal input variables", e.message);
				assertNull(e.detail);
			}
		}
		
		[Test]
		public function testDetermineDeblockingDualHQ():void
		{
			var deblocking:int = VideoRenderingUtils.determineDeblocking(VideoRenderingMode.AUTO, true);		
			assertEquals(1, deblocking);
		}
		
		[Test]
		public function testDetermineDeblockingDualSQ():void
		{
			var deblocking:int = VideoRenderingUtils.determineDeblocking(VideoRenderingMode.AUTO, false);		
			assertEquals(0, deblocking);
		}
		
		[Test]
		public function testDetermineDeblockingEnabled():void
		{
			var deblocking:int = VideoRenderingUtils.determineDeblocking(VideoRenderingMode.DEBLOCKING, false);		
			assertEquals(0, deblocking);
		}		
		
		[Test]
		public function testDetermineDeblockingDisabled():void
		{
			var deblocking:int = VideoRenderingUtils.determineDeblocking(VideoRenderingMode.NONE, false);		
			assertEquals(1, deblocking);
		}
		
		[Test]
		public function testDetermineDeblockingException():void
		{
			try
			{
				var deblocking:int = VideoRenderingUtils.determineDeblocking(2343, false);		
				fail("Should have thrown an exception");
			}
			catch(e:*)
			{
				assertTrue("Error of the wrong type", e is StrobePlayerError);
				assertEquals("Wrong error code", StrobePlayerErrorCodes.ILLEGAL_INPUT_VARIABLE, e.errorID);
				assertEquals("Wrong message", "Illegal input variables", e.message);
				assertNull(e.detail);			
			}
		}
		
		[Test]
		public function testApplyHDSDBestPractices():void
		{	
			var mediaElement:LightweightVideoElement = new LightweightVideoElement();
			VideoRenderingUtils.applyHDSDBestPractices(mediaElement, VideoRenderingMode.SMOOTHING_DEBLOCKING, false);		
			assertTrue(mediaElement.smoothing);
			assertEquals(0, mediaElement.deblocking);
		}
		
		[Test]
		public function testApplyHDSDBestPracticesDualSD():void
		{	
			var mediaElement:LightweightVideoElement = new LightweightVideoElement();
			VideoRenderingUtils.applyHDSDBestPractices(mediaElement, VideoRenderingMode.AUTO, false);		
			assertTrue(mediaElement.smoothing);
			assertEquals(0, mediaElement.deblocking);
		}
		
		[Test]
		public function testApplyHDSDBestPracticesDualHD():void
		{	
			var mediaElement:LightweightVideoElement = new LightweightVideoElement();
			VideoRenderingUtils.applyHDSDBestPractices(mediaElement, VideoRenderingMode.AUTO, true);		
			assertFalse(mediaElement.smoothing);
			assertEquals(1, mediaElement.deblocking);
		}		
	}
}