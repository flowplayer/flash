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
package org.osmf.syndication.parsers.extensions
{
	import __AS3__.vec.Vector;
	
	import org.osmf.syndication.model.extensions.FeedExtension;
	import org.osmf.syndication.model.extensions.itunes.ITunesCategory;
	import org.osmf.syndication.model.extensions.itunes.ITunesExtension;
	import org.osmf.syndication.model.extensions.itunes.ITunesOwner;
	import org.osmf.syndication.model.rss20.RSSCategory;
	import org.osmf.utils.TimeUtil;
	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
	}
	
	/**
	 * Handles the parsing of iTunes extension XML tags.
	 * 
	 * @see http://www.apple.com/itunes/podcasts/specs.html#rss
	 **/
	public class ITunesExtensionParser extends FeedExtensionParser
	{
		/**
		 * Looks at the XML node supplied and returns an ITunesExtension
		 * object if iTunes extension XML tags are found on the node.
		 * 
		 * @throws ArgumentError If xml is null.
		 **/
		override public function parse(xml:XML):FeedExtension
		{
			if (xml == null)
			{
				throw new ArgumentError();
			}
			
			var itunes:Namespace = xml.namespace("itunes");
			
			// If the namespace does not exist, there is no point
			// in continuing.
			if (itunes == null)
			{
				return null;
			}
			
			var children:XMLList = xml.children();
			var iTunesExtension:ITunesExtension;
			var categories:Vector.<ITunesCategory> = new Vector.<ITunesCategory>;
			
			if (children.length() > 0)
			{
				for (var i:int = 0; i < children.length(); i++)
				{
					var childNode:XML = children[i];
										
					// Ignore any tags outside our namespace
					if (itunes == childNode.namespace())
					{
						if (iTunesExtension == null)
						{
							iTunesExtension = new ITunesExtension();
						}

						switch (childNode.nodeKind())
						{
							case "element":
								switch (childNode.localName())
								{
									case TAG_NAME_ITUNES_AUTHOR:
										iTunesExtension.author = childNode;
										break;
									case TAG_NAME_ITUNES_BLOCK:
										iTunesExtension.block = childNode;
										break;
									case TAG_NAME_ITUNES_CATEGORY:
										var category:ITunesCategory = parseCategory(childNode);
										if (category != null)
										{
											categories.push(category);
										}
										break;
									case TAG_NAME_ITUNES_IMAGE:
										iTunesExtension.imageURL = childNode.@href;
										break;
									case TAG_NAME_ITUNES_DURATION:
										iTunesExtension.duration = TimeUtil.parseTime(childNode);
										break;
									case TAG_NAME_ITUNES_EXPLICIT:
										iTunesExtension.explicit = childNode;
										break;
									case TAG_NAME_ITUNES_KEYWORDS:
										iTunesExtension.keywords = childNode;
										break;
									case TAG_NAME_ITUNES_NEW_FEED_URL:
										iTunesExtension.newFeedURL = childNode;
										break;
									case TAG_NAME_ITUNES_OWNER:
										iTunesExtension.owner = parseOwner(childNode);
										break;
									case TAG_NAME_ITUNES_SUBTITLE:
										iTunesExtension.subtitle = childNode;
										break;
									case TAG_NAME_ITUNES_SUMMARY:
										iTunesExtension.summary = childNode;
										break;
									default:
										debugLog("Ignoring this tag in parse(): "+childNode.namespace().prefix+":"+childNode.localName());
										break;
								}
						}
					}
				}
			}
			
			if (iTunesExtension != null && categories.length > 0)
			{
				iTunesExtension.categories = categories;
			}
			
			return iTunesExtension;
		}
		
		private function parseCategory(categoryNode:XML):ITunesCategory
		{
			var category:ITunesCategory = new ITunesCategory();
			category.name = categoryNode.@text;
			var subCategories:Vector.<RSSCategory> = new Vector.<RSSCategory>();
			
			// Check for sub-categories
			var children:XMLList = categoryNode.children();
			for (var i:int = 0; i < children.length(); i++)
			{
				var childNode:XML = children[i];
										
				switch (childNode.nodeKind())
				{
					case "element":
						switch (childNode.localName())
						{
							case TAG_NAME_ITUNES_CATEGORY:
								var subCategory:ITunesCategory = new ITunesCategory();
								subCategory.name = childNode.@text;
								subCategories.push(subCategory);
								break;
						}
				}
			}
			
			category.subCategories = subCategories;
			return category;			
		}
		
		private function parseOwner(ownerNode:XML):ITunesOwner
		{
			var owner:ITunesOwner = new ITunesOwner();
			var children:XMLList = ownerNode.children();
			
			for (var i:int = 0; i < children.length(); i++)
			{
				var childNode:XML = children[i];
				
				switch (childNode.nodeKind())
				{
					case "element":
						switch (childNode.localName())
						{
							case TAG_NAME_ITUNES_NAME:
								owner.name = childNode;
								break;
							case TAG_NAME_ITUNES_EMAIL:
								owner.email = childNode;
								break;
						}
				}
			}
			
			return owner;
		}
		
		private function debugLog(msg:String):void
		{
			CONFIG::LOGGING
			{
				if (logger != null)
				{
					logger.debug(msg);
				}
			}
		}
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = org.osmf.logging.Log.getLogger("org.osmf.syndication.parsers.extensions.ITunesExtensionParser");
		}
		
		private static const TAG_NAME_ITUNES_AUTHOR:String = "author";
		private static const TAG_NAME_ITUNES_BLOCK:String = "block";
		private static const TAG_NAME_ITUNES_CATEGORY:String = "category";
		private static const TAG_NAME_ITUNES_IMAGE:String = "image";
		private static const TAG_NAME_ITUNES_DURATION:String = "duration";
		private static const TAG_NAME_ITUNES_EXPLICIT:String = "explicit";
		private static const TAG_NAME_ITUNES_KEYWORDS:String = "keywords";
		private static const TAG_NAME_ITUNES_NEW_FEED_URL:String = "new-feed-url";
		private static const TAG_NAME_ITUNES_OWNER:String = "owner";
		private static const TAG_NAME_ITUNES_NAME:String = "name";
		private static const TAG_NAME_ITUNES_EMAIL:String = "email";
		private static const TAG_NAME_ITUNES_SUBTITLE:String = "subtitle";
		private static const TAG_NAME_ITUNES_SUMMARY:String = "summary";
	}
}
