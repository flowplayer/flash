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
package org.osmf.syndication.parsers
{
	import __AS3__.vec.Vector;
	
	import org.osmf.syndication.model.Feed;
	import org.osmf.syndication.parsers.extensions.ITunesExtensionParser;
	import org.osmf.syndication.parsers.extensions.MediaRSSExtensionParser;
	
	/**
	 * This class is responsible for parsing any
	 * syndication feed.
	 **/
	public class FeedParser extends FeedParserBase
	{
		/**
		 * Constructor.
		 **/
		public function FeedParser()
		{
			super();
			addFeedParsers();
		}
		
		/**
		 * This method iterates over all available
		 * parsers and tries each one until it
		 * returns a non-null Feed object.
		 * 
		 * @throws ArgumentError If xml is null.
		 **/
		override public function parse(xml:XML):Feed
		{
			if (xml == null)
			{
				throw new ArgumentError();
			}
			
			var feed:Feed;
			
			// Iterate over all parsers until one returns a Feed object
			for each (var feedParser:FeedParserBase in feedParsers)
			{
				feed = feedParser.parse(xml);
				if (feed != null)
				{
					break;
				}
			}
			
			return feed;
		}
		
		/**
		 * This method adds all the parsers this class knows about
		 * along with any respective feed extension parsers.
		 **/
		protected function addFeedParsers():void
		{
			feedParsers = new Vector.<FeedParserBase>();
			
			// Add the Atom  parser
			var atomParser:AtomParser = new AtomParser();
			atomParser.addFeedExtensionParser(new ITunesExtensionParser());
			atomParser.addFeedExtensionParser(new MediaRSSExtensionParser());
			feedParsers.push(atomParser);
			
			// Add the RSS 2.0 parser and all available feed extensions
			var rss20Parser:RSS20Parser = new RSS20Parser();
			rss20Parser.addFeedExtensionParser(new ITunesExtensionParser());
			rss20Parser.addFeedExtensionParser(new MediaRSSExtensionParser());
			feedParsers.push(rss20Parser);
		}
		
		private var feedParsers:Vector.<FeedParserBase>;
	}
}
