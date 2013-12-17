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
package org.osmf.syndication.model.atom
{
	import __AS3__.vec.Vector;
	
	import org.osmf.syndication.model.Entry;
	import org.osmf.syndication.model.FeedText;

	/**
	 * Represents an entry element in an Atom feed.
	 **/
	public class AtomEntry extends Entry
	{
		/**
		 * Constructor.
		 **/
		public function AtomEntry()
		{
			super();
		}
		
		/**
		 * Indicates the last time the entry was 
		 * modified in a significant way.
		 **/
		public function get updated():String
		{
			return _updated;
		}
		
		public function set updated(value:String):void
		{
			_updated = value;
		}
		
		/**
		 * The author(s) of the feed.
		 **/
		public function get authors():Vector.<AtomPerson>
		{
			return _authors;
		}
		
		public function set authors(values:Vector.<AtomPerson>):void
		{
			_authors = values;
		}
		
		/**
		 * Contains, or links to, the complete 
		 * content of the entry.
		 **/
		public function get content():AtomContent
		{
			return _content;
		}
		
		public function set content(value:AtomContent):void
		{
			_content = value;
		}
		
		/**
		 * Identifies a related Web page.
		 **/
		public function get link():AtomLink
		{
			return _link;
		}
		
		public function set link(value:AtomLink):void
		{
			_link = value;
		}
		
		/**
		 * Categories the entry belongs to.
		 **/
		public function get categories():Vector.<AtomCategory>
		{
			return _categories;
		}
		
		public function set categories(values:Vector.<AtomCategory>):void
		{
			_categories = values;
		}
		
		/**
		 * Contributors to the entry.
		 **/
		public function get contributors():Vector.<AtomPerson>
		{
			return _contributors;
		}
		
		public function set contributors(values:Vector.<AtomPerson>):void
		{
			_contributors = values;
		}
		
		/**
		 * If an entry is copied from one feed into another
		 * feed, then the source feed's metadata (all child
		 * elements of a feed other than the entry elements)
		 * should be preserved. 
		 **/
		public function get source():AtomFeed
		{
			return _source;
		}
		
		public function set source(value:AtomFeed):void
		{
			_source = value;
		}
		
		/**
		 * Information about rights, such as
		 * copyrights.
		 **/
		public function get rights():FeedText
		{
			return _rights;
		}
		
		public function set rights(value:FeedText):void
		{
			_rights = value;
		}
		
		private var _updated:String;
		private var _authors:Vector.<AtomPerson>;
		private var _content:AtomContent;
		private var _link:AtomLink;
		private var _categories:Vector.<AtomCategory>;
		private var _contributors:Vector.<AtomPerson>;
		private var _source:AtomFeed;
		private var _rights:FeedText;
		
	}
}
