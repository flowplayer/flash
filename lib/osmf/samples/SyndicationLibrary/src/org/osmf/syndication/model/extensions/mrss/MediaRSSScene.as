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
	 * Represents a media:scene element in a
	 * Media RSS feed.
	 *
	 * @see http://video.search.yahoo.com/mrss
	 **/
	public class MediaRSSScene
	{
		/**
		 * The scene title.
		 **/
		public function get title():String
		{
			return _title;
		}
		
		public function set title(value:String):void
		{
			_title = value;
		}
		
		/**
		 * Description of the scene.
		 **/
		public function get description():String
		{
			return _description;
		}
		
		public function set description(value:String):void
		{
			_description = value;
		}
		
		/**
		 * Start time for the scene.
		 **/
		public function get startTime():String
		{
			return _startTime;
		}
		
		public function set startTime(value:String):void
		{
			_startTime = value;
		}
		
		/**
		 * End time for the scene.
		 **/		 
		public function get endTime():String
		{
			return _endTime;
		}
		
		public function set endTime(value:String):void
		{
			_endTime = value;
		}
		
		private var _title:String;
		private var _description:String;
		private var _startTime:String;
		private var _endTime:String;
	}
}
