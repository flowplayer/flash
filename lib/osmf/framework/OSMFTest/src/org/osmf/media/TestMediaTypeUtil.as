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
	import __AS3__.vec.Vector;
	
	import flexunit.framework.Assert;
	
	public class TestMediaTypeUtil
	{
		[Test]
		public function testMatch():void
		{
			var supportedMedia:Vector.<String> = new Vector.<String>;
			supportedMedia.push(MediaType.AUDIO);
			var supportedMime:Vector.<String> = new Vector.<String>;
			supportedMime.push("audio/mp3");	
			supportedMime.push("audio/mpeg");
			
			Assert.assertEquals(MediaTypeUtil.METADATA_MATCH_FOUND, MediaTypeUtil.checkMetadataMatch(MediaType.AUDIO, "audio/mp3", supportedMedia, supportedMime));
			Assert.assertEquals(MediaTypeUtil.METADATA_MATCH_UNKNOWN, MediaTypeUtil.checkMetadataMatch(null, null, supportedMedia, supportedMime));		
			Assert.assertEquals(MediaTypeUtil.METADATA_CONFLICTS_FOUND, MediaTypeUtil.checkMetadataMatch(MediaType.VIDEO, null, supportedMedia, supportedMime));
			Assert.assertEquals(MediaTypeUtil.METADATA_CONFLICTS_FOUND, MediaTypeUtil.checkMetadataMatch(MediaType.AUDIO, "video/x-flv", supportedMedia, supportedMime));
			Assert.assertEquals(MediaTypeUtil.METADATA_MATCH_FOUND, MediaTypeUtil.checkMetadataMatch(MediaType.AUDIO, null, supportedMedia, supportedMime));
			Assert.assertEquals(MediaTypeUtil.METADATA_MATCH_FOUND, MediaTypeUtil.checkMetadataMatch(null, "audio/mpeg", supportedMedia, supportedMime));						
		}
		
		[Test]
		private function testResourceWithData(expectedResult:int, mediaType:String, mimeType:String, supportedMedia:Vector.<String>, supportedMime:Vector.<String>):void
		{
			var resource:URLResource = new URLResource("test");
			resource.mediaType = mediaType;
			resource.mimeType = mimeType;
			Assert.assertEquals(expectedResult, MediaTypeUtil.checkMetadataMatchWithResource(resource, supportedMedia, supportedMime));
		}
		
		[Test]
		public function testResourceMatch():void
		{
			var supportedMedia:Vector.<String> = new Vector.<String>;
			supportedMedia.push(MediaType.AUDIO);
			var supportedMime:Vector.<String> = new Vector.<String>;
			supportedMime.push("audio/mp3");	
			supportedMime.push("audio/mpeg");
								
			Assert.assertEquals(testResourceWithData(MediaTypeUtil.METADATA_MATCH_FOUND,MediaType.AUDIO, "audio/mp3", supportedMedia, supportedMime));			
			Assert.assertEquals(testResourceWithData(MediaTypeUtil.METADATA_MATCH_UNKNOWN, null, null, supportedMedia, supportedMime));					
			Assert.assertEquals(testResourceWithData(MediaTypeUtil.METADATA_CONFLICTS_FOUND, MediaType.VIDEO, null, supportedMedia, supportedMime));			
			Assert.assertEquals(testResourceWithData(MediaTypeUtil.METADATA_CONFLICTS_FOUND, MediaType.AUDIO, "video/x-flv", supportedMedia, supportedMime));			
			Assert.assertEquals(testResourceWithData(MediaTypeUtil.METADATA_MATCH_FOUND, MediaType.AUDIO, null, supportedMedia, supportedMime));			
			Assert.assertEquals(testResourceWithData(MediaTypeUtil.METADATA_MATCH_FOUND, null, "audio/mpeg", supportedMedia, supportedMime));						
		}
	}
}