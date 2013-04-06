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
package org.osmf.syndication.model.rss20
{
	/**
	 * Represents an image tag in a syndication feed.
	 **/
	public class RSSImage
	{
		/**
		 * Constructor.
		 */
		public function RSSImage()
		{
		}

		/**
		 * The URL of the image.
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
		 * The URL of the site, when the channel is 
		 * rendered, the image is a link to the site.
		 **/
		public function get link():String
		{
			return _link;
		}
		
		public function set link(value:String):void
		{
			_link = value;
		}
		
		/**
		 * The title of the image.
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
		 * The width of the image in pixels.
		 **/
		public function get width():Object
		{
			return _width;
		}
		
		public function set width(value:Object):void
		{
			_width = value;
		}
		
		/**
		 * The height of the image in pixels.
		 **/
		public function get height():Object
		{
			return _height;
		}
		
		public function set height(value:Object):void
		{
			_height = value;
		}
		
		private var _url:String;
		private var _link:String;
		private var _title:String;
		private var _width:Object;
		private var _height:Object;
	}
}
