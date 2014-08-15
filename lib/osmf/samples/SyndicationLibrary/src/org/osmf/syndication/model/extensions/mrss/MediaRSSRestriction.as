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
	 * Represents a media:restriction element in a 
	 * Media RSS document.
	 * 
	 * @see http://video.search.yahoo.com/mrss
	 **/
	public class MediaRSSRestriction
	{
		/**
		 * Indicates the type of relationship
		 * the restriction represents.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function get relationship():String
		{
			return _relationship;
		}
		
		public function set relationship(value:String):void
		{
			_relationship = value;
		}
		
		/**
		 * Specifies the type of restriction.
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
		 * The value of the media:restriction element
		 * in a Media RSS feed.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function get text():String
		{
			return _text;
		}
		
		public function set text(value:String):void
		{
			_text = value;
		}
		
		private var _relationship:String;
		private var _type:String;
		private var _text:String;
	}
}
