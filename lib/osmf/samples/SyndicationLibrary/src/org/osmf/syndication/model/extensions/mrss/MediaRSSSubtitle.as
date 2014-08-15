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
	 * Represents a media:subTitle tag in a
	 * Media RSS Feed.
	 **/
	public class MediaRSSSubtitle
	{
		/**
		 * The mime type of the subtitle.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function get type():String
		{
			return _type;
		}
		
		public function set type(value:String):void
		{
			_type = value;
		}
		
		/**
		 * Language of the subtitle.
		 * 
		 * @see http://video.search.yahoo.com/mrss
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
		 * The URL of the subtitle.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function get url():String
		{
			return _href;
		}
		
		public function set url(value:String):void
		{
			_href = value;
		}
		
		private var _type:String;
		private var _lang:String;
		private var _href:String;
	}
}
