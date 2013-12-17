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
	import __AS3__.vec.Vector;
	
	import org.osmf.syndication.model.Enclosure;
	import org.osmf.syndication.model.Entry;
	
	/**
	 * This class represents an item in a syndication feed.
	 */
	public class RSSItem extends Entry
	{
		/**
		 * Constructor.
		 */
		public function RSSItem()
		{
			super();
		}		
		
		/**
		 * An email address of the author of the item.
		 **/
		public function get author():String
		{
			return _author;
		}
		
		public function set author(value:String):void
		{
			_author = value;
		}

		/**
		 * The categories for the item.
		 **/
		public function get categories():Vector.<RSSCategory>
		{
			return _categories;
		}
		
		public function set categories(value:Vector.<RSSCategory>):void
		{
			_categories = value;
		}
		
		/**
		 * The URL of the item.
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
		 * A URL of a page for comments relating to the 
		 * item.
		 **/
		public function get comments():String
		{
			return _comments;
		}
		
		public function set comments(value:String):void
		{
			_comments = value;
		}
		
		/**
		 * A string that uniquely identifies the item.
		 **/
		public function get guid():String
		{
			return _guid;
		}
		
		public function set guid(value:String):void
		{
			_guid = value;
		}
		
		/**
		 * The source of the syndication item.
		 **/
		public function get source():RSSSource
		{
			return _source;
		}
		
		public function set source(value:RSSSource):void
		{
			_source = value;
		}
		
		private var _link:String;
		private var _author:String;
		private var _categories:Vector.<RSSCategory>;
		private var _comments:String;
		private var _guid:String;
		private var _source:RSSSource;
	}
}
