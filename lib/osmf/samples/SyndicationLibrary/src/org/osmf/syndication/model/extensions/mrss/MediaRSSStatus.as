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
	 * Represents a media:status element in a
	 * Media RSS Feed.
	 **/
	public class MediaRSSStatus
	{
		/**
		 * The state of the media object,
		 * such as "active", "blocked", etc.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function get state():String
		{
			return _state;
		}		
		
		public function set state(value:String):void
		{
			_state = value;
		}
		
		/**
		 * The reason explaining why the media object
		 * has been blocked/deleted. Can be plain 
		 * text or a url.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function get reason():String
		{
			return _reason;
		}
		
		public function set reason(value:String):void
		{
			_reason = value;
		}
		
		private var _state:String;
		private var _reason:String;
	}
}
