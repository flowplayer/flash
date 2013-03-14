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
package org.osmf.syndication.model.extensions.mrss
{
	public class MediaRSSThumbnail
	{
		/**
		 * The URL of the media element.
		 **/
		public function get url():String
		{
			return _url;
		}
		
		public function set url(value:String):void
		{
			_url = value;
		}
		
		/**
		 * Height of the content in pixels.
		 **/
		public function get height():int
		{
			return _height;
		}
		
		public function set height(value:int):void
		{
			_height = value;
		} 
		
		/**
		 * Width of the content in pixels.
		 **/
		public function get width():int
		{
			return _width;
		}
		
		public function set width(value:int):void
		{
			_width = value;
		}
		
		/**
		 * Time specifies the time offset in relation
		 * to the media object.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function get time():String
		{
			return _time;
		}
		
		public function set time(value:String):void
		{
			_time = value;
		}
		
		private var _url:String;
		private var _height:int;
		private var _width:int;
		private var _time:String;
	}
}
