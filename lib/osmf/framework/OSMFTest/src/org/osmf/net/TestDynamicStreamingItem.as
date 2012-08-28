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
package org.osmf.net
{
	import flexunit.framework.Assert;

	public class TestDynamicStreamingItem
	{
		[Test]
		public function testStreamNameProperties():void
		{
			var dsi:DynamicStreamingItem = new DynamicStreamingItem(STREAM_NAME_1, BITRATE_1, WIDTH_1, HEIGHT_1);
			
			Assert.assertEquals(STREAM_NAME_1, dsi.streamName);		
			dsi.streamName = STREAM_NAME_2;
			Assert.assertEquals(STREAM_NAME_2, dsi.streamName);
		}
		
		[Test]
		public function testBitrateProperties():void
		{
			var dsi:DynamicStreamingItem = new DynamicStreamingItem(STREAM_NAME_1, BITRATE_1, WIDTH_1, HEIGHT_1);
			
			Assert.assertEquals(BITRATE_1, dsi.bitrate);
			dsi.bitrate = BITRATE_2;
			Assert.assertEquals(BITRATE_2, dsi.bitrate);
		}
		
		[Test]
		public function testWidthProperties():void
		{
			var dsi:DynamicStreamingItem = new DynamicStreamingItem(STREAM_NAME_1, BITRATE_1, WIDTH_1, HEIGHT_1);
			
			Assert.assertEquals(WIDTH_1, dsi.width);
			dsi.width = WIDTH_2;
			Assert.assertEquals(WIDTH_2, dsi.width);
		}
		
		[Test]
		public function testHeightProperties():void
		{
			var dsi:DynamicStreamingItem = new DynamicStreamingItem(STREAM_NAME_1, BITRATE_1, WIDTH_1, HEIGHT_1);
			
			Assert.assertEquals(HEIGHT_1, dsi.height);
			dsi.height = HEIGHT_2;
			Assert.assertEquals(HEIGHT_2, dsi.height);
		}
		
		private const STREAM_NAME_1:String = "mp4:foo/bar/myvideo.mp4";
		private const STREAM_NAME_2:String = "mp4:bar/foo/somevideo.f4v";
		private const BITRATE_1:Number = 3000;
		private const BITRATE_2:Number = 1500;
		private const WIDTH_1:int = 1280;
		private const WIDTH_2:int = 1920;
		private const HEIGHT_1:int = 720;
		private const HEIGHT_2:int = 1080;
	}
}
