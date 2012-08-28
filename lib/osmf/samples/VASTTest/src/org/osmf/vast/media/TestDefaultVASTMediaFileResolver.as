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
package org.osmf.vast.media
{
	import __AS3__.vec.Vector;
	
	import flexunit.framework.TestCase;
	
	import org.osmf.vast.model.VASTMediaFile;
	
	public class TestDefaultVASTMediaFileResolver extends TestCase
	{
		public function testResolveMediaFiles():void
		{
			var mediaFiles:Vector.<VASTMediaFile> = new Vector.<VASTMediaFile>();
			mediaFiles.push(createMediaFileOfType("video/x-ms-wmv"));
			mediaFiles.push(createMediaFileOfType("video/x-flv"));
			mediaFiles.push(createMediaFileOfType("video/3gpp"));
			
			var resolver:DefaultVASTMediaFileResolver = new DefaultVASTMediaFileResolver();
			var mediaFile:VASTMediaFile = resolver.resolveMediaFiles(mediaFiles);
			assertTrue(mediaFile != null);
			assertTrue(mediaFile.type == "video/x-flv");
		}

		public function testResolveMediaFilesWithNoSupportedType():void
		{
			var mediaFiles:Vector.<VASTMediaFile> = new Vector.<VASTMediaFile>();
			mediaFiles.push(createMediaFileOfType("video/x-ms-wmv"));
			mediaFiles.push(createMediaFileOfType("video/xyz"));
			mediaFiles.push(createMediaFileOfType("video/abc"));
			
			var resolver:DefaultVASTMediaFileResolver = new DefaultVASTMediaFileResolver();
			var mediaFile:VASTMediaFile = resolver.resolveMediaFiles(mediaFiles);
			assertTrue(mediaFile == null);
		}
		
		private function createMediaFileOfType(mimeType:String):VASTMediaFile
		{
			var mediaFile:VASTMediaFile = new VASTMediaFile();
			mediaFile.type = mimeType;
			return mediaFile;
		}
	}
}