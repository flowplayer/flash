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
	import __AS3__.vec.Vector;
	
	import org.osmf.syndication.model.extensions.FeedExtension;
	
	/**
	 * This class represents the root level object
	 * of the syndication document object model.
	 **/
	public class Feed
	{		
		/**
		 * The title of the feed.
		 **/
		public function get title():FeedText
		{
			return _title;
		}
		
		public function set title(value:FeedText):void
		{
			_title = value;
		}
		
		/**
		 * Identifies the feed using a universally unique and
		 * permanent URI.
		 **/
		public function get id():String
		{
			return _id;
		}
		
		public function set id(value:String):void
		{
			_id = value;
		}
		
		/**
		 * A phrase or sentence describing the 
		 * syndication element.
		 **/
		public function get description():FeedText
		{
			return _description;
		}
		
		public function set description(value:FeedText):void
		{
			_description = value;
		}

		/**
		 * The collection of Entry objects.
		 **/
		public function get entries():Vector.<Entry>
		{
			return _entries;
		}
		
		public function set entries(value:Vector.<Entry>):void
		{
			_entries = value;
		}
		
		/**
		 * The collection of FeedExtension objects.
		 **/
		public function get feedExtensions():Vector.<FeedExtension>
		{
			return _feedExtensions;
		}
		
		public function set feedExtensions(value:Vector.<FeedExtension>):void
		{
			_feedExtensions = value;	
		}
		
		private var _id:String;
		private var _title:FeedText;
		private var _description:FeedText;
		private var _entries:Vector.<Entry>;
		private var _feedExtensions:Vector.<FeedExtension>;
	}
}
