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
	
	import org.osmf.syndication.model.Entry;
	import org.osmf.syndication.model.Feed;
	import org.osmf.syndication.model.FeedText;
	import org.osmf.syndication.model.FeedTextType;
	import org.osmf.syndication.model.atom.AtomCategory;
	import org.osmf.syndication.model.atom.AtomContent;
	import org.osmf.syndication.model.atom.AtomEntry;
	import org.osmf.syndication.model.atom.AtomFeed;
	import org.osmf.syndication.model.atom.AtomGenerator;
	import org.osmf.syndication.model.atom.AtomLink;
	import org.osmf.syndication.model.atom.AtomPerson;
	import org.osmf.syndication.model.extensions.FeedExtension;
	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
	}
	
	
	/**
	 * Parses an Atom feed.
	 **/
	public class AtomParser extends FeedParserBase
	{
		/**
		 * Parses an Atom feed and returns a Feed object.
		 **/
		override public function parse(xml:XML):Feed
		{
			var atomFeed:AtomFeed;
			
			// Look at the root node and it's namespace to verify this is 
			// an Atom feed.
			if (xml.localName() == TAG_NAME_FEED && xml.namespace().uri == ATOM_NAMESPACE_URI)
			{
				atomFeed = parseFeed(xml);
			}
			
			return atomFeed;
		}
		
		private function parseFeed(feedNode:XML):AtomFeed
		{
			var children:XMLList = feedNode.children();
			var feed:AtomFeed;
			var authors:Vector.<AtomPerson>;
			var contributors:Vector.<AtomPerson>;
			var categories:Vector.<AtomCategory>;
			var entries:Vector.<Entry>;
			
			if (((feedNode.localName() == TAG_NAME_FEED) ||
				(feedNode.localName() == TAG_NAME_SOURCE)) && children.length() > 0)
			{
				feed = new AtomFeed();
				
				for (var i:int = 0; i < children.length(); i++)
				{
					var childNode:XML = children[i];
					
					switch (childNode.nodeKind())
					{
						case "element":
							switch (childNode.localName())
							{
								case TAG_NAME_ID:
									feed.id = childNode;
									break;
								case TAG_NAME_TITLE:
									feed.title = parseText(childNode);
									break;
								case TAG_NAME_UPDATED:
									feed.updated = childNode;
									break;
								case TAG_NAME_CONTRIBUTOR:
									var contributor:AtomPerson = parsePerson(childNode);
									if (contributors == null)
									{
										contributors = new Vector.<AtomPerson>();
									}
									contributors.push(contributor);
									break;
								case TAG_NAME_AUTHOR:
									var author:AtomPerson = parsePerson(childNode);
									if (authors == null)
									{
										authors = new Vector.<AtomPerson>();
									}
									authors.push(author);
									break;
								case TAG_NAME_LINK:
									var link:AtomLink = new AtomLink();
									link.hreflang = childNode.@[ATTRIB_NAME_HREFLANG];
									link.length = childNode.@[ATTRIB_NAME_LENGTH];
									link.rel = childNode.@[ATTRIB_NAME_REL];
									link.title = childNode.@[ATTRIB_NAME_TITLE];
									link.type = childNode.@[ATTRIB_NAME_TYPE];
									link.url = childNode.@[ATTRIB_NAME_HREF];
									feed.link = link;
									break;
								case TAG_NAME_CATEGORY:
									var category:AtomCategory = new AtomCategory();
									category.label = childNode.@[ATTRIB_NAME_LABEL];
									category.scheme = childNode.@[ATTRIB_NAME_SCHEME];
									category.term = childNode.@[ATTRIB_NAME_TERM];
									if (categories == null)
									{
										categories = new Vector.<AtomCategory>;
									}
									categories.push(category);
									break;
								case TAG_NAME_GENERATOR:
									var generator:AtomGenerator = new AtomGenerator();
									generator.text = childNode;
									generator.url = childNode.@[ATTRIB_NAME_URI];
									generator.version = childNode.@[ATTRIB_NAME_VERSION];
									feed.generator = generator;
									break;
								case TAG_NAME_ICON:
									feed.icon = childNode;
									break;
								case TAG_NAME_LOGO:
									feed.logo = childNode;
									break;
								case TAG_NAME_RIGHTS:
									feed.rights = parseText(childNode);
									break;
								case TAG_NAME_SUBTITLE:
									var subtitle:FeedText = parseText(childNode);
									feed.subtitle = subtitle;
									break;
								case TAG_NAME_ENTRY:
									var entry:AtomEntry = parseEntry(childNode);
									if (entry)
									{
										if (entries == null)
										{
											entries = new Vector.<Entry>();
										}
										
										entries.push(entry);
									}
									break;
							}
					}
				}
			} 
			
			if (feed != null)
			{
				if (contributors != null)
				{
					feed.contributors = contributors;
				}
				
				if (authors != null)
				{
					feed.authors = authors;
				}
				
				if (categories != null)
				{
					feed.categories = categories;
				}
				
				if (entries != null)
				{
					feed.entries = entries;
				}
				
				var feedExtensionsCollection:Vector.<FeedExtension> = parseFeedExtensions(feedNode);
				feed.feedExtensions = feedExtensionsCollection;
			}
			
			return feed;
		}
		
		private function parseEntry(entryNode:XML):AtomEntry
		{
			var children:XMLList = entryNode.children();
			var authors:Vector.<AtomPerson>;
			var categories:Vector.<AtomCategory>;			
			var contributors:Vector.<AtomPerson>;
			var entry:AtomEntry;
			
			if (entryNode.localName() == TAG_NAME_ENTRY && children.length() > 0)
			{
				entry = new AtomEntry();
				
				for (var i:int = 0; i < children.length(); i++)
				{
					var childNode:XML = children[i];
					
					switch (childNode.nodeKind())
					{
						case "element":
							switch (childNode.localName())
							{
								case TAG_NAME_ID:
									entry.id = childNode;
									break;
								case TAG_NAME_TITLE:
									entry.title = parseText(childNode);
									break;
								case TAG_NAME_UPDATED:
									entry.updated = childNode;
									break;
								case TAG_NAME_AUTHOR:
									var author:AtomPerson = parsePerson(childNode);
									if (authors == null)
									{
										authors = new Vector.<AtomPerson>();
									}
									authors.push(author);
									break;
								case TAG_NAME_CONTENT:
									var content:AtomContent = new AtomContent();
									content.src = childNode.@[ATTRIB_NAME_SOURCE];
									content.text = childNode;
									content.type = childNode.@[ATTRIB_NAME_TYPE];
									entry.content = content;
									break;
								case TAG_NAME_LINK:
									var link:AtomLink = new AtomLink();
									link.hreflang = childNode.@[ATTRIB_NAME_HREFLANG];
									link.length = childNode.@[ATTRIB_NAME_LENGTH];
									link.rel = childNode.@[ATTRIB_NAME_REL];
									link.title = childNode.@[ATTRIB_NAME_TITLE];
									link.type = childNode.@[ATTRIB_NAME_TYPE];
									link.url = childNode.@[ATTRIB_NAME_HREF];
									entry.link = link;
									break;
								case TAG_NAME_SUMMARY:
									entry.description = parseText(childNode);
									break;
								case TAG_NAME_CATEGORY:
									var category:AtomCategory = new AtomCategory();
									category.label = childNode.@[ATTRIB_NAME_LABEL];
									category.scheme = childNode.@[ATTRIB_NAME_SCHEME];
									category.term = childNode.@[ATTRIB_NAME_TERM];
									if (categories == null)
									{
										categories = new Vector.<AtomCategory>;
									}
									categories.push(category);
									break;
								case TAG_NAME_CONTRIBUTOR:
									var contributor:AtomPerson = parsePerson(childNode);
									if (contributors == null)
									{
										contributors = new Vector.<AtomPerson>();
									}
									contributors.push(contributor);
									break;
								case TAG_NAME_PUBLISHED:
									entry.published = childNode;
									break;
								case TAG_NAME_SOURCE:
									entry.source = parseFeed(childNode);
									break;
								case TAG_NAME_RIGHTS:
									var rights:FeedText = parseText(childNode);
									entry.rights = rights;
									break;
							}
					}
				}
			}
			
			if (entry != null)
			{
				if (authors != null)
				{
					entry.authors = authors;
				}
	
				if (categories != null)
				{
					entry.categories = categories;
				}
				
				if (contributors != null)
				{
					entry.contributors = contributors;
				}
				
				var feedExtensionsCollection:Vector.<FeedExtension> = parseFeedExtensions(entryNode);
				entry.feedExtensions = feedExtensionsCollection;
			}
			
			return entry;			
		}
		
		private function parsePerson(personNode:XML):AtomPerson
		{
			var person:AtomPerson = new AtomPerson();
			var children:XMLList = personNode.children();
			
			if (children.length() > 0)
			{
				for (var i:int = 0; i < children.length(); i++)
				{
					var childNode:XML = children[i];
					switch (childNode.nodeKind())
					{
						case "element":
							switch (childNode.localName())
							{
								case TAG_NAME_NAME:
									person.name = childNode;
									break;
								case TAG_NAME_EMAIL:
									person.email = childNode;
									break;
								case TAG_NAME_URI:
									person.url = childNode;
									break;
							}
					}
				}
			}
			
			return person;
		}
		
		private function parseText(textNode:XML):FeedText
		{
			var feedText:FeedText = new FeedText();
			feedText.type = textNode.@[ATTRIB_NAME_TYPE];
			switch (feedText.type)
			{
				case FeedTextType.XHTML: // the element contains inline xhtml, wrapped in a div element
					feedText.text = textNode.toXMLString();
					break;
				case FeedTextType.HTML: // the element contains entity escaped html
				case FeedTextType.TEXT: // the element contains plain text with no entity escaped html
				default:
					feedText.text = textNode;
					break;
			}
			return feedText;
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
			private static const logger:Logger = org.osmf.logging.Log.getLogger("org.osmf.syndication.parsers.AtomParser");
		}
		
		// Atom namespace
		private static const ATOM_NAMESPACE_URI:String = "http://www.w3.org/2005/Atom";
		// Tags names
		private static const TAG_NAME_FEED:String = "feed";
		private static const TAG_NAME_ID:String = "id";
		private static const TAG_NAME_TITLE:String = "title";
		private static const TAG_NAME_UPDATED:String = "updated";
		private static const TAG_NAME_AUTHOR:String = "author";
		private static const TAG_NAME_LINK:String = "link";
		private static const TAG_NAME_CATEGORY:String = "category";
		private static const TAG_NAME_CONTRIBUTOR:String = "contributor";
		private static const TAG_NAME_GENERATOR:String = "generator";
		private static const TAG_NAME_ICON:String = "icon";
		private static const TAG_NAME_LOGO:String = "logo";
		private static const TAG_NAME_RIGHTS:String = "rights";
		private static const TAG_NAME_SUBTITLE:String = "subtitle";
		private static const TAG_NAME_ENTRY:String = "entry";
		private static const TAG_NAME_NAME:String = "name";
		private static const TAG_NAME_CONTENT:String = "content";
		private static const TAG_NAME_SUMMARY:String = "summary";
		private static const TAG_NAME_PUBLISHED:String = "published";
		private static const TAG_NAME_SOURCE:String = "source";
		private static const TAG_NAME_EMAIL:String = "email";
		private static const TAG_NAME_URI:String = "uri";
		
		// Attribute names
		private static const ATTRIB_NAME_ID:String = "id";
		private static const ATTRIB_NAME_TITLE:String = "title";
		private static const ATTRIB_NAME_UPDATED:String = "updated";
		private static const ATTRIB_NAME_TERM:String = "term";
		private static const ATTRIB_NAME_URI:String = "uri";
		private static const ATTRIB_NAME_VERSION:String = "version";
		private static const ATTRIB_NAME_REL:String = "rel";
		private static const ATTRIB_NAME_HREF:String = "href";
		private static const ATTRIB_NAME_HREFLANG:String = "hreflang";
		private static const ATTRIB_NAME_LABEL:String = "label";
		private static const ATTRIB_NAME_LENGTH:String = "length";
		private static const ATTRIB_NAME_SCHEME:String = "scheme";
		private static const ATTRIB_NAME_TYPE:String = "type";
		private static const ATTRIB_NAME_SOURCE:String = "src";
	}
}
