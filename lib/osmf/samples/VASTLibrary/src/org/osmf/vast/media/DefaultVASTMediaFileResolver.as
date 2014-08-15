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
*  Contributor(s): Adobe Systems Inc.
*                  Eyewonder, LLC
*
*****************************************************/
package org.osmf.vast.media
{
	import org.osmf.vast.model.VASTMediaFile;
	
	/**
	 * DefaultVASTMediaFileResolver implements IVASTMediaFileResolver. It provides
	 * a default implementation to pick a VASTMediaFile object out of all those
	 * available in a VAST document. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class DefaultVASTMediaFileResolver implements IVASTMediaFileResolver
	{
		/**
		 * By default, return the first one with a supported MIME type.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function resolveMediaFiles(mediaFiles:Vector.<VASTMediaFile>):VASTMediaFile
		{	
			for (var i:int = 0; i < mediaFiles.length; i++)
			{
				if (supportsMimeType(mediaFiles[i].type))
				{
					return mediaFiles[i];
				}
			}
			
			return null;
		}
		
		private static function supportsMimeType(mimeType:String):Boolean
		{
			for each (var supportedMimeType:String in VIDEO_MIME_TYPES_SUPPORTED)
			{
				if (mimeType == supportedMimeType)
				{
					return true;
				}
			}
			
			return false;
		}
		
		private static const VIDEO_MIME_TYPES_SUPPORTED:Vector.<String> = Vector.<String>
		([
			"video/x-flv", 
			"video/x-f4v", 
			"video/mp4", 
			"video/mp4v-es", 
			"video/x-m4v", 
			"video/3gpp", 
			"video/3gpp2", 
			"video/quicktime",
			"application/x-shockwave-flash", 
		]);
	}
}
