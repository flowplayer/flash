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
	
	import org.osmf.syndication.model.Enclosure;
	import org.osmf.syndication.model.Entry;
	import org.osmf.syndication.model.Feed;
	import org.osmf.syndication.model.FeedText;
	import org.osmf.syndication.model.extensions.FeedExtension;
	import org.osmf.syndication.model.rss20.RSSCategory;
	import org.osmf.syndication.model.rss20.RSSCloud;
	import org.osmf.syndication.model.rss20.RSSFeed;
	import org.osmf.syndication.model.rss20.RSSImage;
	import org.osmf.syndication.model.rss20.RSSItem;
	import org.osmf.syndication.model.rss20.RSSSource;
	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
	}
	
	/**
	 * Parses an RSS 2.0 feed.
	 **/
	public class RSS20Parser extends FeedParserBase
	{
		/**
		 * Parses an RSS 2.0 feed and returns a Feed object.
		 **/
		override public function parse(xml:XML):Feed
		{
			var rssFeed:RSSFeed;
			
			// Look at the root tag to verify this is an RSS feed
			if (xml.localName() == TAG_NAME_RSS)
			{
				var channelTag:XMLList = xml.children();
				var channelNode:XML = channelTag[0];
				rssFeed = parseChannel(channelNode);
			}
			
			return rssFeed;
		}
		
		private function parseChannel(channelNode:XML):RSSFeed
		{
			var children:XMLList = channelNode.children();
			var channel:RSSFeed;
			var items:Vector.<Entry> = new Vector.<Entry>();
			var categories:Vector.<RSSCategory> = new Vector.<RSSCategory>();
			var skipHours:Vector.<int> = new Vector.<int>();
			var skipDays:Vector.<String> = new Vector.<String>();
			
			if (channelNode.localName() == TAG_NAME_CHANNEL && children.length() > 0)
			{
				channel = new RSSFeed();
			
				for (var i:int = 0; i < children.length(); i++)
				{
					var childNode:XML = children[i];
					
					var ns:Namespace = childNode.namespace();
					var prefix:String = ns.prefix;
					
					// Ignore this tag if it has a prefix since RSS 2.0 tags
					// are not namespaced. This keeps us from grabing a duplicate
					// tag name in an extension, such as <media:description>
					if (prefix != "")
					{
						continue;
					}
					
					switch (childNode.nodeKind())
					{
						case "element":
							switch (childNode.localName())
							{
								case TAG_NAME_TITLE:
									channel.title = parseFeedText(childNode);
									break;
								case TAG_NAME_LINK:
									channel.link = childNode;
									break;
								case TAG_NAME_DESCRIPTION:
									channel.description = parseFeedText(childNode);
									break;
								case TAG_NAME_LANGUAGE:
									channel.language = childNode;
									break;
								case TAG_NAME_COPYRIGHT:
									channel.copyright = childNode;
									break;
								case TAG_NAME_MANAGING_EDITOR:
									channel.managingEditor = childNode;
									break;
								case TAG_NAME_WEB_MASTER:
									channel.webMaster = childNode;
									break;
								case TAG_NAME_PUB_DATE:
									channel.pubDate = childNode;
									break;
								case TAG_NAME_GENERATOR:
									channel.generator = childNode;
									break;
								case TAG_NAME_PUB_DATE:
									channel.pubDate = childNode;
									break;
								case TAG_NAME_LAST_BUILD_DATE:
									channel.lastBuildDate = childNode;
									break;
								case TAG_NAME_CATEGORY:
									var category:RSSCategory = new RSSCategory();
									category.domain = childNode.@[ATTRIB_NAME_DOMAIN];
									category.name = childNode;
									categories.push(category);
									break;
								case TAG_NAME_GENERATOR:
									channel.generator = childNode;
									break;
								case TAG_NAME_DOCS:
									channel.docs = childNode;
									break;
								case TAG_NAME_CLOUD:
									var cloud:RSSCloud = new RSSCloud();
									cloud.domain = childNode.@[ATTRIB_NAME_DOMAIN];
									cloud.path = childNode.@[ATTRIB_NAME_PATH];
									cloud.port = childNode.@[ATTRIB_NAME_PORT];
									cloud.protocol = childNode.@[ATTRIB_NAME_PROTOCOL];
									cloud.registerProcedure = childNode.@[ATTRIB_NAME_REGISTER_PROCEDURE];
									channel.cloud = cloud
									break;
								case TAG_NAME_TTL:
									channel.ttl = childNode;
									break;
								case TAG_NAME_IMAGE:
									var image:RSSImage = parseImage(childNode);
									channel.image = image;
									break;
								case TAG_NAME_RATING:
									channel.rating = childNode;
									break;
								case TAG_NAME_SKIP_HOURS:
									var skipHour:int = parseInt(childNode);
									skipHours.push(skipHour);
									break;
								case TAG_NAME_SKIP_DAYS:
									var skipDay:String = childNode;
									skipDays.push(skipDay);
									break;
								case TAG_NAME_ITEM:
									var item:RSSItem = parseItem(childNode);
									if (item)
									{
										items.push(item);
									}
									break;
								default:
									debugLog("Ignoring this tag in parseChannel(): "+childNode.namespace().prefix+":"+childNode.localName());
									break;
							}
					}
				}
			}
			
			if (channel != null)
			{
				if (items.length > 0)
				{
					channel.entries = items;
				}
				
				if (categories.length > 0)
				{
					channel.categories = categories;
				}
				
				var feedExtensionsCollection:Vector.<FeedExtension> = parseFeedExtensions(channelNode);
				channel.feedExtensions = feedExtensionsCollection;
			}
			
			return channel;
		}
		
		private function parseFeedText(textNode:XML):FeedText
		{
			var feedText:FeedText = new FeedText();
			feedText.text = textNode;
			return feedText;
		}
		
		private function parseImage(imageNode:XML):RSSImage
		{
			var children:XMLList = imageNode.children();
			var image:RSSImage = new RSSImage();
			
			for (var i:int = 0; i < children.length(); i++)
			{
				var childNode:XML = children[i];
				
				switch (childNode.nodeKind())
				{
					case "element":
						switch (childNode.localName())
						{
							case TAG_NAME_URL:
								image.url = childNode;
								break;
							case TAG_NAME_TITLE:
								image.title = childNode;
								break;
							case TAG_NAME_LINK:
								image.link = childNode;
								break;
							case TAG_NAME_WIDTH:
								image.width = childNode;
								break;
							case TAG_NAME_HEIGHT:
								image.height = childNode
								break;
						}
				}
			}
			
			return image;
		}
		
		private function parseItem(itemNode:XML):RSSItem
		{
			var children:XMLList = itemNode.children();
			var item:RSSItem;
			var categories:Vector.<RSSCategory> = new Vector.<RSSCategory>();
			
			if (itemNode.localName() == TAG_NAME_ITEM && children.length() > 0)
			{
				item = new RSSItem();
				
				for (var i:int = 0; i < children.length(); i++)
				{
					var childNode:XML = children[i];
					
					switch (childNode.nodeKind())
					{
						case "element":
							switch (childNode.localName())
							{
								case TAG_NAME_TITLE:
									item.title = parseFeedText(childNode);
									break;
								case TAG_NAME_LINK:
									item.link = childNode;
									break;
								case TAG_NAME_DESCRIPTION:
									item.description = parseFeedText(childNode);
									break;
								case TAG_NAME_AUTHOR:
									item.author = childNode;
									break;
								case TAG_NAME_CATEGORY:
									var category:RSSCategory = new RSSCategory();
									category.domain = childNode.@[ATTRIB_NAME_DOMAIN];
									category.name = childNode;
									categories.push(category);
									break;
								case TAG_NAME_COMMENTS:
									item.comments = childNode;
									break;
								case TAG_NAME_ENCLOSURE:
									var enclosure:Enclosure = new Enclosure();
									enclosure.url = childNode.@[ATTRIB_NAME_URL];
									enclosure.length = childNode.@[ATTRIB_NAME_LENGTH];
									enclosure.type = childNode.@[ATTRIB_NAME_TYPE];
									item.enclosure = enclosure;
									break;
								case TAG_NAME_GUID:
									item.guid = childNode;
									break;
								case TAG_NAME_PUB_DATE:
									item.published = childNode;
									break;
								case TAG_NAME_SOURCE:
									var source:RSSSource = new RSSSource();
									source.url = childNode.@[ATTRIB_NAME_URL];
									source.name = childNode;
									item.source = source;
									break;
							}
					}
				}
			}
			
			if (item != null)
			{
				if (categories.length > 0)
				{
					item.categories = categories;
				}
				
				var feedExtensionsCollection:Vector.<FeedExtension> = parseFeedExtensions(itemNode);
				item.feedExtensions = feedExtensionsCollection;
			}
			
			return item;
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
			private static const logger:Logger = org.osmf.logging.Log.getLogger("org.osmf.syndication.parsers.RSS20Parser");
		}
		
		// Tags names
		private static const TAG_NAME_RSS:String = "rss";
		private static const TAG_NAME_CHANNEL:String = "channel";
		private static const TAG_NAME_TITLE:String = "title";
		private static const TAG_NAME_LINK:String = "link";
		private static const TAG_NAME_DESCRIPTION:String = "description";
		private static const TAG_NAME_LANGUAGE:String = "language";
		private static const TAG_NAME_COPYRIGHT:String = "copyright";
		private static const TAG_NAME_MANAGING_EDITOR:String = "managingEditor";
		private static const TAG_NAME_WEB_MASTER:String = "webMaster";
		private static const TAG_NAME_PUB_DATE:String = "pubDate";
		private static const TAG_NAME_LAST_BUILD_DATE:String = "lastBuildDate";
		private static const TAG_NAME_CATEGORY:String = "category";
		private static const TAG_NAME_GENERATOR:String = "generator";
		private static const TAG_NAME_DOCS:String = "docs";
		private static const TAG_NAME_CLOUD:String = "cloud";
		private static const TAG_NAME_TTL:String = "ttl";
		private static const TAG_NAME_IMAGE:String = "image";
		private static const TAG_NAME_RATING:String = "rating";
		private static const TAG_NAME_TEXT_INPUT:String = "textInput";
		private static const TAG_NAME_SKIP_HOURS:String = "skipHours";
		private static const TAG_NAME_SKIP_DAYS:String = "skipDays";
		private static const TAG_NAME_AUTHOR:String = "author";
		private static const TAG_NAME_COMMENTS:String = "comments";		
		private static const TAG_NAME_GUID:String = "guid";		
		private static const TAG_NAME_SOURCE:String = "source";
		private static const TAG_NAME_ITEM:String = "item";
		private static const TAG_NAME_ENCLOSURE:String = "enclosure";
		private static const TAG_NAME_URL:String = "url";
		private static const TAG_NAME_HEIGHT:String = "height";
		private static const TAG_NAME_WIDTH:String = "width";
		
		// Attribute names
		private static const ATTRIB_NAME_URL:String = "url";
		private static const ATTRIB_NAME_LENGTH:String = "length";
		private static const ATTRIB_NAME_TYPE:String = "type";
		private static const ATTRIB_NAME_DOMAIN:String = "domain";
		private static const ATTRIB_NAME_HEIGHT:String = "height";
		private static const ATTRIB_NAME_WIDTH:String = "width";
		private static const ATTRIB_NAME_PATH:String = "path";
		private static const ATTRIB_NAME_PORT:String = "port";
		private static const ATTRIB_NAME_PROTOCOL:String = "protocol";
		private static const ATTRIB_NAME_REGISTER_PROCEDURE:String = "registerProcedure";
		private static const ATTRIB_NAME_TITLE:String = "title";
	}
}
