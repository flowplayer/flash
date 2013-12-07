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
	 * Represents a media:credit element in a Media RSS feed.
	 **/
	public class MediaRSSCredit
	{
		/**
		 * Specified the role the entity played.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function get role():String
		{
			return _role;
		}
		
		public function set role(value:String):void
		{
			_role = value;
		}
		
		/**
		 * The URI that identifieds the role scheme.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function get scheme():String
		{
			return _scheme;
		}
		
		public function set scheme(value:String):void
		{
			_scheme = value;
		}
		
		/**
		 * The text value of the media:credit element.
		 **/
		public function get text():String
		{
			return _text;
		}
		
		public function set text(value:String):void
		{
			_text = value;
		}
		
		private var _role:String;
		private var _scheme:String;
		private var _text:String;
	}
}
