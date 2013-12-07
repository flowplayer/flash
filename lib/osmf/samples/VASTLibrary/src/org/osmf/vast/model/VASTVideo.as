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
* 
*****************************************************/
package org.osmf.vast.model
{
	import __AS3__.vec.Vector;
	
	/**
	 * This class represents a Video tag in a VAST document.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class VASTVideo
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function VASTVideo()
		{
			super();
			
			_mediaFiles = new Vector.<VASTMediaFile>();
		}

		/**
		 * The duration of the video expressed in XML time format, hh:mm:ss.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get duration():String 
		{
			return _duration;
		}
		
		public function set duration(value:String):void 
		{
			_duration = value;
		}
		
		/**
		 * The Ad ID for the video creative.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get adID():String 
		{
			return _adID;
		}
		
		public function set adID(value:String):void 
		{
			_adID = value;
		}
		
		/**
		 * The actions to take upon the video being clicked.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get videoClick():VASTVideoClick 
		{
			return _videoClick;
		}

		public function set videoClick(value:VASTVideoClick):void
		{
			_videoClick = value;
		}
		
		/**
		 * A Vector of VASTMediaFile objects.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get mediaFiles():Vector.<VASTMediaFile> 
		{
			return _mediaFiles;
		}
		
		/**
		 * Adds an item to the Vector of VASTMediaFile objects.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function addMediaFile(mediaFile:VASTMediaFile):void 
		{
			_mediaFiles.push(mediaFile);
		}

		private var _duration:String;
		private var _adID:String;
		private var _videoClick:VASTVideoClick;
		private var _mediaFiles:Vector.<VASTMediaFile>;		
	}
}
