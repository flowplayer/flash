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
	 * Represents a media:price element in a
	 * Media RSS feed.
	 * 
	 * @see http://video.search.yahoo.com/mrss
	 **/
	public class MediaRSSPrice
	{
		/**
		 * The Type value such as "rent", "purchase",
		 * "package", etc.
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
		 * URL pointing to a the package or subscription
		 * information.
		 *
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function get info():String
		{
			return _info;
		}
		
		public function set info(value:String):void
		{
			_info = value;
		}
		
		/**
		 * Price of the media object.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function get price():String
		{
			return _price;
		}
		
		public function set price(value:String):void
		{
			_price = value;
		}
		
		/**
		 * Currency code.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function get currency():String
		{
			return _currency;
		}
		
		public function set currency(value:String):void
		{
			_currency = value;
		}
		
		private var _type:String;
		private var _info:String;
		private var _price:String;
		private var _currency:String;
	}
}
