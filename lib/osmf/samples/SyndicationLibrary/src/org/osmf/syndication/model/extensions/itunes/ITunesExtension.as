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
package org.osmf.syndication.model.extensions.itunes
{
	import __AS3__.vec.Vector;
	
	import org.osmf.syndication.model.extensions.FeedExtension;
	
	public class ITunesExtension extends FeedExtension
	{
		public function ITunesExtension()
		{
			super();
		}

		/**
		 * The content of this tag is shown
		 * in the Artist column in iTunes.
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
		 * If <code>true</code>, that means the
		 * to block the feed or the episode. 
		 **/
		public function get block():String
		{
			return _block;
		}
		
		public function set block(value:String):void
		{
			_block = value;
		}
		
		/** 
		 * The ITunesCategory objects.
		 **/
		public function get categories():Vector.<ITunesCategory>
		{
			return _categories;
		}
		
		public function set categories(value:Vector.<ITunesCategory>):void
		{
			_categories = value;
		}
		
		/**
		 * Duration in seconds.
		 **/
		public function get duration():Number
		{
			return _duration;
		}
		
		public function set duration(value:Number):void
		{
			_duration = value;
		}
		
		/**
		 * Value indicates whether or not the content
		 * contains explicit material and should be one of
		 * the public constants defined in this class.
		 * 
		 * @see ITunesExplicitType
		 **/
		public function get explicit():String
		{
			return _explicit;
		}
		
		public function set explicit(value:String):void
		{
			_explicit = value;
		}
		
		/**
		 * The artwork for the podcast is read from
		 * the itunes:image tag's href attribute.
		 **/
		public function get imageURL():String
		{
			return _imageURL;
		}
		
		public function set imageURL(value:String):void
		{
			_imageURL = value;
		}
		
		/**
		 * Keywords are separated with commas and
		 * can contain a maximum of 12 text keywords.
		 **/
		public function get keywords():String
		{
			return _keywords;
		}
		
		public function set keywords(value:String):void
		{
			_keywords = value;
		}
		
		/**
		 * Allows you to change the URL where the podcast feed is
		 * located.
		 * 
		 * @see http://www.apple.com/itunes/podcasts/specs.html#rss
		 **/
		public function get newFeedURL():String
		{
			return _newFeedURL;
		}
		
		public function set newFeedURL(value:String):void
		{
			_newFeedURL = value;
		}
		
		/**
		 * The owner of the podcast.
		 **/
		public function get owner():ITunesOwner
		{
			return _owner;
		}
		
		public function set owner(value:ITunesOwner):void
		{
			_owner = value;
		}
		
		/**
		 * The subtitle or description of the content.
		 **/
		public function get subtitle():String
		{
			return _subtitle;
		}
		
		public function set subtitle(value:String):void
		{
			_subtitle = value;
		}
		
		/**
		 * A summary of the content, can be up to 
		 * 4000 characters.
		 **/
		public function get summary():String
		{
			return _summary;
		}
		
		public function set summary(value:String):void
		{
			_summary = value;
		}
		
		private var _author:String;
		private var _block:String;
		private var _categories:Vector.<ITunesCategory>;
		private var _imageURL:String;
		private var _duration:Number;
		private var _explicit:String;
		private var _keywords:String;
		private var _newFeedURL:String;
		private var _owner:ITunesOwner;
		private var _subtitle:String;
		private var _summary:String;
	}
}
