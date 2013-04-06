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
	/**
	 * Represents a media:text element in a Media
	 * RSS feed.
	 * 
	 * @see http://video.search.yahoo.com/mrss
	 **/ 
	public class MediaRSSText extends MediaRSSTextBase
	{
		/**
		 * Constructor.
		 **/
		public function MediaRSSText()
		{
			super();
		}
		
		/**
		 * The primary language encapsulated in the 
		 * media object.
		 **/
		public function get language():String
		{
			return _lang;
		}
		
		public function set language(value:String):void
		{
			_lang = value;
		}
		
		/**
		 * The start time offset in seconds the
		 * text starts being relevant to the
		 * media object.
		 **/
		public function get start():Number
		{
			return _start;
		}
		
		public function set start(value:Number):void
		{
			_start = value;
		}
		
		/**
		 * The end time in seconds the
		 * text is relevant to the 
		 * media object.
		 **/
		public function get end():Number
		{
			return _end;
		}
		
		public function set end(value:Number):void
		{
			_end = value;
		}
		
		private var _lang:String;
		private var _start:Number;
		private var _end:Number;
	}
}
