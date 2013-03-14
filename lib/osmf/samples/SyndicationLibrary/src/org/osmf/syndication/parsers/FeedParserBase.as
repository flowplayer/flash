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
	import org.osmf.syndication.model.extensions.FeedExtension;
	import org.osmf.syndication.parsers.extensions.FeedExtensionParser;
	
	/**
	 * Base class for all feed parsers.
	 **/
	public class FeedParserBase
	{
		/**
		 * Override this method in a specific feed parser class.
		 **/
		public function parse(xml:XML):Feed
		{
			return null;
		}

		/**
		 * Add a feed extension parser. A feed extension parser knows how to
		 * parse specific feed extension XML tags, such as
		 * the iTunes or Media RSS extensions.
		 **/
		public function addFeedExtensionParser(parser:FeedExtensionParser):void
		{
			if (_feedExtensionParsers == null)
			{
				_feedExtensionParsers = new Vector.<FeedExtensionParser>;
			} 
			
			_feedExtensionParsers.push(parser);
		}
		
		/**
		 * Iterates over the collection of FeedExtensionParser objects
		 * and calls the parse method, passing in the node. Feed parsers
		 * should call this method passing in the feed and entry tags so
		 * any extension parsers added via the addFeedExtensionParser can 
		 * be called.
		 **/
		protected function parseFeedExtensions(xml:XML):Vector.<FeedExtension>
		{
			var feedExtensions:Vector.<FeedExtension>;
			
			for each (var feedExtensionsParser:FeedExtensionParser in _feedExtensionParsers)
			{
				var feedExtension:FeedExtension = feedExtensionsParser.parse(xml);
				if (feedExtension != null)
				{
					if (feedExtensions == null)
					{
						feedExtensions = new Vector.<FeedExtension>();
					}
					feedExtensions.push(feedExtension);
				}
			}
			
			return feedExtensions;
		}
		
		
		private var _feedExtensionParsers:Vector.<FeedExtensionParser>;
	}
}
