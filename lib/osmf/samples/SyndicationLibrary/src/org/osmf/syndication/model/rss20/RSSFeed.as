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
	
	import org.osmf.syndication.model.Feed;
	import org.osmf.utils.OSMFStrings;
	
	/**
	 * This class represents the Channel XML
	 * tag in an RSS 2.0 feed.
	 **/
	public class RSSFeed extends Feed
	{
		/**
		 * Constructor.
		 **/
		public function RSSFeed()
		{
			super();
		}
		
		/**
		 * The URL to a website corresponding to the
		 * syndication element. Usually an HTML page.
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
		 * The Category collection.
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
		 * The publication date for the content in the RSS Feed. 
		 * All date-times in RSS conform to the Date and Time 
		 * Specification of RFC 822, with the exception that the 
		 * year may be expressed with two characters or 
		 * four characters (four preferred).	Sat, 07 Sep 2002 00:00:01 GMT
		 */
		public function get pubDate():String
		{
			return _pubDate;
		}
		
		public function set pubDate(value:String):void
		{
			_pubDate = value;
		}
		
		
		/** 
		 * The language the RSS Feed is written in. This allows aggregators to group 
		 * all Italian language sites, for example, on a single page. A list of 
		 * allowable values can be found the LanguageCodes class.
		 * 
		 * @see org.osmf.rss.model.LanguageCodes
		 */
		public function get language():String
		{
			return _language;
		}
		
		public function set language(value:String):void
		{
			_language = value;
		}
		
		/**
		 * Copyright notice for content in the RSS Feed.
		 */
		public function get copyright():String
		{
			return _copyright;
		}
		
		public function set copyright(value:String):void
		{
			_copyright = value;
		}
		
		/**
		 * 	Email address for person responsible for editorial content.
		 */
		public function get managingEditor():String
		{
			return _managingEditor;
		}
		
		public function set managingEditor(value:String):void
		{
			_managingEditor = value;
		}
		
		/**
		 * Email address for person responsible for technical issues 
		 * relating to the RSS Feed.
		 */
		public function get webMaster():String
		{
			return _webMaster;
		}
		
		public function set webMaster(value:String):void
		{
			_webMaster = value;
		}
				
		/**
		 * The last time the content of the RSS Feed changed.
		 * All date-times in RSS conform to the Date and Time 
		 * Specification of RFC 822, with the exception that the 
		 * year may be expressed with two characters or 
		 * four characters (four preferred).	Sat, 07 Sep 2002 00:00:01 GMT
		 */
		public function get lastBuildDate():String
		{
			return _lastBuildDate;
		}
		
		public function set lastBuildDate(value:String):void
		{
			_lastBuildDate = value;
		}
		
		/**
		 * 	A string indicating the program used to generate the RSS Feed.
		 */
		public function get generator():String
		{
			return _generator;
		}
		
		public function set generator(value:String):void
		{
			_generator = value;
		}
		
		/**
		 * A URL that points to the documentation for the format 
		 * used in the RSS file.
		 */
		public function get docs():String
		{
			return _docs;
		}
		
		public function set docs(value:String):void
		{
			_docs = value;
		}
		
		/**
		 * 	Allows processes to register with a cloud to be 
		 * notified of updates to the RSS Feed, implementing a 
		 * lightweight publish-subscribe protocol for 
		 * RSS feeds.
		 */
		 public function get cloud():RSSCloud
		 {
		 	return _cloud;
		 }
		 
		 public function set cloud(value:RSSCloud):void
		 {
		 	_cloud = value;
		 }
		 
		 /**
		 * ttl stands for time to live. It's a number of minutes 
		 * that indicates how long an RSS Feed can be cached before 
		 * refreshing from the source.
		 */
		public function get ttl():Object
		{
			return _ttl;
		}
		
		public function set ttl(value:Object):void
		{
			_ttl = value;
		}
		
		/**
		 * Specifies a GIF, JPEG or PNG image that can be 
		 * displayed with the RSS Feed.
		 */
		public function get image():RSSImage
		{
			return _image;
		}
		
		public function set image(value:RSSImage):void
		{
			_image = value;
		}
		
		/**
		 * The PICS rating for the RSS Feed.
		 */
		public function get rating():String
		{
			return _rating;
		}
		
		public function set rating(value:String):void
		{
			_rating = value;
		}
		
		private var _link:String;
		private var _categories:Vector.<RSSCategory>;		
		private var _pubDate:String;
		private var _language:String; // Should be a string const from org.osmf.rss.model.LanguageCodes
		private var _copyright:String;
		private var _managingEditor:String;
		private var _webMaster:String;
		private var _lastBuildDate:String;
		private var _generator:String;
		private var _docs:String;
		private var _cloud:RSSCloud;
		private var _ttl:Object;
		private var _image:RSSImage;
		private var _rating:String;	
		private var _skipHours:Vector.<int>;
		private var _skipDays:Vector.<String>;
	}
}
