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
package org.osmf.syndication.model
{
	/**
	 * Represents an enclosure, or a media object that
	 * is attached to a syndication item.
	 */
	public class Enclosure
	{
		/**
		 * Constructor.
		 **/
		public function Enclosure()
		{
		}

		/**
		 * The URL of the enclosure.
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
		 * The length of the enclosure in bytes.
		 **/
		public function get length():Number
		{
			return _length;
		}
		
		public function set length(value:Number):void
		{
			_length = value;
		}
		
		/**
		 * The type of enclosure, should be one of the
		 * standard MIME types.
		 **/
		public function get type():String
		{
			return _type;
		}
		
		public function set type(value:String):void
		{
			_type = value;
		}

		private var _url:String;
		private var _length:Number;
		private var _type:String;
	}
}
