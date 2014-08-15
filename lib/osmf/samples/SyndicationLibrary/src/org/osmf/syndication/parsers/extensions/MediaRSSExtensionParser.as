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
	
	import flash.utils.Dictionary;
	
	import org.osmf.syndication.model.extensions.FeedExtension;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSCategory;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSCommunity;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSContent;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSCopyright;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSCredit;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSDescription;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSElementBase;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSEmbed;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSExtension;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSGroup;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSHash;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSLicense;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSPeerLink;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSPlayer;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSPrice;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSRating;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSRestriction;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSScene;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSStatus;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSSubtitle;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSText;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSThumbnail;
	import org.osmf.syndication.model.extensions.mrss.MediaRSSTitle;
	
	/**
	 * Parser for Media RSS Extentions.
	 * 
	 * @see http://video.search.yahoo.com/mrss
	 **/
	public class MediaRSSExtensionParser extends FeedExtensionParser
	{
		/**
		 * Looks at the XML node supplied and returns a MediaRSSExtension
		 * object if Media RSS extension XML tags are found on the node.
		 * 
		 * @throws ArgumentError If xml is null.
		 **/
		override public function parse(xml:XML):FeedExtension
		{
			if (xml == null)
			{
				throw new ArgumentError();
			}

			var media:Namespace = xml.namespace("media");

			// If the namespace does not exist, there is no point
			// in continuing.
			if (media == null)
			{
				return null;
			}
			
			var mediaRSSExtension:MediaRSSExtension;
			var mediaGroups:Vector.<MediaRSSGroup> = new Vector.<MediaRSSGroup>();	
			var children:XMLList = xml.children();
			
			if (children.length() > 0)
			{
				for (var i:int = 0; i < children.length(); i++)
				{
					var childNode:XML = children[i];
					
					// Ignore any tags outside our namespace
					if (media == childNode.namespace())
					{
						if (mediaRSSExtension == null)
						{
							mediaRSSExtension = new MediaRSSExtension();
						}
						
						switch (childNode.nodeKind())
						{
							case "element":
								switch (childNode.localName())
								{
									case TAG_NAME_MRSS_GROUP:
										var group:MediaRSSGroup = parseGroup(childNode);
										mediaGroups.push(group);
										break;
									case TAG_NAME_MRSS_CONTENT:
										var content:MediaRSSContent = parseContent(childNode);
										mediaRSSExtension.content = content;
										break;
								}
						}
					}
				}
			}
			
			if (mediaRSSExtension != null)
			{
				if (mediaGroups.length > 0)
				{
					mediaRSSExtension.groups = mediaGroups;
				}
				parseOptionalElements(mediaRSSExtension, xml);			
			}

			return mediaRSSExtension;
		}
		
		/**
		 * Handles parsing of the media:group element which is a
		 * sub-element of item. The group element allows grouping
		 * of media:content elements that are effectively
		 * the same content, yet different representations, such
		 * as the same video encoded differently.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		private function parseGroup(groupNode:XML):MediaRSSGroup
		{
			var group:MediaRSSGroup = new MediaRSSGroup();
			var children:XMLList = groupNode.children();
			var contents:Vector.<MediaRSSContent>;
			
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
								case TAG_NAME_MRSS_CONTENT:
									if (contents == null)
									{
										contents = new Vector.<MediaRSSContent>();
									}
									var content:MediaRSSContent = parseContent(childNode);
									contents.push(content);
									break;
							}
					}
				}
			}
			
			if (contents != null)
			{
				group.contents = contents;
			}
			
			// Look for any of the optional elements on this element.
			parseOptionalElements(group, groupNode);				
			return group;
		}
		
		/**
		 * Handles parsing of the media:content element which is a 
		 * sub-element of either item or media:group.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		private function parseContent(contentNode:XML):MediaRSSContent
		{
			var content:MediaRSSContent = new MediaRSSContent();
			
			content.bitrate = contentNode.@[ATTRIB_NAME_BITRATE];
			content.channels = parseInt(contentNode.@[ATTRIB_NAME_CHANNELS]);
			content.duration = contentNode.@[ATTRIB_NAME_DURATION];
			content.expression = contentNode.@[ATTRIB_NAME_EXPRESSION];
			content.fileSize = Number(contentNode.@[ATTRIB_NAME_FILE_SIZE]);
			content.framerate = parseInt(contentNode.@[ATTRIB_NAME_FRAME_RATE]);
			content.height = parseInt(contentNode.@[ATTRIB_NAME_HEIGHT]);
			content.isDefault = contentNode.@[ATTRIB_NAME_IS_DEFAULT];
			content.language = contentNode.@[ATTRIB_NAME_LANGUAGE];
			content.medium = contentNode.@[ATTRIB_NAME_MEDIUM];
			content.samplingRate = Number(contentNode.@[ATTRIB_NAME_SAMPLE_RATE]);
			content.type = contentNode.@[ATTRIB_NAME_TYPE];
			content.url = contentNode.@[ATTRIB_NAME_URL];
			content.width = parseInt(contentNode.@[ATTRIB_NAME_WIDTH]);
			
			// Look for any of the optional elements on this element
			parseOptionalElements(content, contentNode);
			return content;
		}
		
		/**
		 * Handles the parsing of optional elements. The 
		 * primary elements are media:group and media:content.
		 * All other elements are optional and handled here.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/ 
		private function parseOptionalElements(element:MediaRSSElementBase, node:XML):void
		{
			var thumbnails:Vector.<MediaRSSThumbnail>;
			var categories:Vector.<MediaRSSCategory>;
			var hashes:Vector.<MediaRSSHash>;
			var credits:Vector.<MediaRSSCredit>;
			var texts:Vector.<MediaRSSText>;
			var restrictions:Vector.<MediaRSSRestriction>;
			var prices:Vector.<MediaRSSPrice>;
			var subtitles:Vector.<MediaRSSSubtitle>;
			var rights:Vector.<String>;
			var children:XMLList = node.children();
			
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
								case TAG_NAME_MRSS_RATING:
									var rating:MediaRSSRating = new MediaRSSRating();
									rating.scheme = childNode.@[ATTRIB_NAME_SCHEME];
									rating.text = childNode;
									element.rating = rating;
									break;
								case TAG_NAME_MRSS_TITLE:
									var title:MediaRSSTitle = new MediaRSSTitle();
									title.type = childNode.@[ATTRIB_NAME_TYPE];
									title.text = childNode;
									element.title = title;
									break;
								case TAG_NAME_MRSS_DESCRIPTION:
									var description:MediaRSSDescription = new MediaRSSDescription();
									description.type = childNode.@[ATTRIB_NAME_TYPE];
									description.text = childNode;
									element.description = description;
									break;
								case TAG_NAME_MRSS_KEYWORDS:
									element.keywords = childNode;
									break;
								case TAG_NAME_MRSS_THUMBNAIL:
									var thumbnail:MediaRSSThumbnail = new MediaRSSThumbnail();
									thumbnail.height = childNode.@[ATTRIB_NAME_HEIGHT];
									thumbnail.width = childNode.@[ATTRIB_NAME_WIDTH];
									thumbnail.time = childNode.@[ATTRIB_NAME_TIME];
									thumbnail.url = childNode.@[ATTRIB_NAME_URL];
									if (thumbnails == null)
									{
										thumbnails = new Vector.<MediaRSSThumbnail>();
									}
									thumbnails.push(thumbnail);
									break;
								case TAG_NAME_MRSS_CATEGORY:
									var category:MediaRSSCategory = new MediaRSSCategory();
									category.scheme = childNode.@[ATTRIB_NAME_SCHEME];
									category.label = childNode.@[ATTRIB_NAME_LABEL];
									category.text = childNode;
									if (categories == null)
									{
										categories = new Vector.<MediaRSSCategory>();
									}
									categories.push(category);									
									break;
								case TAG_NAME_MRSS_HASH:
									var hash:MediaRSSHash = new MediaRSSHash();
									hash.algo = childNode.@[ATTRIB_NAME_ALGORITHM];
									hash.text = childNode;
									if (hashes == null)
									{
										hashes = new Vector.<MediaRSSHash>();
									}
									hashes.push(hash);
									break;
								case TAG_NAME_MRSS_PLAYER:
									var player:MediaRSSPlayer = new MediaRSSPlayer();
									player.url = childNode.@[ATTRIB_NAME_URL];
									player.height = childNode.@[ATTRIB_NAME_HEIGHT];
									player.width = childNode.@[ATTRIB_NAME_WIDTH];
									element.player = player;
									break;
								case TAG_NAME_MRSS_CREDIT:
									var credit:MediaRSSCredit = new MediaRSSCredit();
									credit.role = childNode.@[ATTRIB_NAME_ROLE];
									credit.scheme = childNode.@[ATTRIB_NAME_SCHEME];
									credit.text = childNode;
									if (credits == null)
									{
										credits = new Vector.<MediaRSSCredit>();
									}
									credits.push(credit);
									break;
								case TAG_NAME_MRSS_COPYRIGHT:
									var copyright:MediaRSSCopyright = new MediaRSSCopyright();
									copyright.url = childNode.@[ATTRIB_NAME_URL];
									copyright.text = childNode;
									element.copyright = copyright;
									break;
								case TAG_NAME_MRSS_TEXT:
									var text:MediaRSSText = new MediaRSSText();
									text.type = childNode.@[ATTRIB_NAME_TYPE];
									text.language = childNode.@[ATTRIB_NAME_LANGUAGE];
									if (texts == null)
									{
										texts = new Vector.<MediaRSSText>();
									}
									texts.push(text);
									break;
								case TAG_NAME_MRSS_RESTRICTION:
									var restriction:MediaRSSRestriction = new MediaRSSRestriction();
									restriction.relationship = childNode.@[ATTRIB_NAME_RELATIONSHIP];
									restriction.type = childNode.@[ATTRIB_NAME_TYPE];
									restriction.text = childNode;
									if (restrictions == null)
									{
										restrictions = new Vector.<MediaRSSRestriction>();
									}
									restrictions.push(restriction);
									break;
								case TAG_NAME_MRSS_COMMUNITY:
									var community:MediaRSSCommunity = parseCommunity(childNode);
									if (community != null)
									{
										element.community = community;
									}
									break;
								case TAG_NAME_MRSS_COMMENTS:
									element.comments = parseComments(childNode);
									break;
								case TAG_NAME_MRSS_EMBED:
									element.embed = parseEmbed(childNode);
									break;
								case TAG_NAME_MRSS_RESPONSES:
									element.responses = parseResponses(childNode);
									break;
								case TAG_NAME_MRSS_BACK_LINKS:
									element.backLinks = parseBackLinks(childNode);
									break;
								case TAG_NAME_MRSS_STATUS:
									var status:MediaRSSStatus = new MediaRSSStatus();
									status.state = childNode.@[ATTRIB_NAME_STATE];
									status.reason = childNode.@[ATTRIB_NAME_REASON];
									element.status = status;
									break;
								case TAG_NAME_MRSS_PRICE:
									var price:MediaRSSPrice = new MediaRSSPrice();
									price.type = childNode.@[ATTRIB_NAME_TYPE];
									price.info = childNode.@[ATTRIB_NAME_INFO];
									price.price = childNode.@[ATTRIB_NAME_PRICE];
									price.currency = childNode.@[ATTRIB_NAME_CURRENCY];
									if (prices == null)
									{
										prices = new Vector.<MediaRSSPrice>();
									}
									prices.push(price);
									break;
								case TAG_NAME_MRSS_LICENSE:
									var license:MediaRSSLicense = new MediaRSSLicense();
									license.type = childNode.@[ATTRIB_NAME_TYPE];
									license.url = childNode.@[ATTRIB_NAME_HREF];
									license.text = childNode;
									element.license = license;
									break;
								case TAG_NAME_MRSS_SUBTITLE:
									var subtitle:MediaRSSSubtitle = new MediaRSSSubtitle();
									subtitle.language = childNode.@[ATTRIB_NAME_LANGUAGE];
									subtitle.type = childNode.@[ATTRIB_NAME_TYPE];
									subtitle.url = childNode.@[ATTRIB_NAME_HREF];
									if (subtitles == null)
									{
										subtitles = new Vector.<MediaRSSSubtitle>();
									}
									subtitles.push(subtitle);
									break;
								case TAG_NAME_MRSS_PEER_LINK:
									var peerLink:MediaRSSPeerLink = new MediaRSSPeerLink();
									peerLink.type = childNode.@[ATTRIB_NAME_TYPE];
									peerLink.url = childNode.@[ATTRIB_NAME_HREF];
									element.peerLink = peerLink;
									break;
								case TAG_NAME_MRSS_LOCATION:
									break;
								case TAG_NAME_MRSS_RIGHTS:
									var rightsStatus:String = childNode.@[ATTRIB_NAME_STATUS];
									if (rights == null)
									{
										rights = new Vector.<String>();
									}
									rights.push(rightsStatus);
									break;
								case TAG_NAME_MRSS_SCENES:
									element.scenes = parseScenes(childNode);
									break;
							}
					}			
				}
			}
			
			if (thumbnails != null && thumbnails.length > 0)
			{
				element.thumbnails = thumbnails;
			}
			
			if (categories != null && categories.length > 0)
			{
				element.categories = categories;
			}
			
			if (hashes != null && hashes.length > 0)
			{
				element.hashes = hashes;
			}
			
			if (credits != null && credits.length > 0)
			{
				element.credits = credits;
			}
			
			if (texts != null && texts.length > 0)
			{
				element.texts = texts;
			}
			
			if (restrictions != null && restrictions.length > 0)
			{
				element.restrictions = restrictions;
			}
			
			if (prices != null && prices.length > 0)
			{
				element.prices = prices;
			}
			
			if (subtitles != null && subtitles.length > 0)
			{
				element.subtitles = subtitles;
			}
			
			if (rights != null && rights.length > 0)
			{
				element.rights = rights;
			}
		}
		
		/**
		 * Handles parsing of the media:community element.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		private function parseCommunity(communityNode:XML):MediaRSSCommunity
		{
			var community:MediaRSSCommunity = new MediaRSSCommunity();
			var children:XMLList = communityNode.children();
			
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
								case TAG_NAME_MRSS_STAR_RATING:
									community.starRatingAverage = Number(childNode.@[ATTRIB_NAME_AVERAGE]);
									community.starRatingCount = parseInt(childNode.@[ATTRIB_NAME_COUNT]);
									community.starRatingMin = parseInt(childNode.@[ATTRIB_NAME_MIN]);
									community.starRatingMax = parseInt(childNode.@[ATTRIB_NAME_MAX]);
									break;
								case TAG_NAME_MRSS_STATISTICS:
									community.statisticsViews = childNode.@[ATTRIB_NAME_VIEWS];
									community.statisticsFavorites = childNode.@[ATTRIB_NAME_FAVORITES];
									break;
								case TAG_NAME_MRSS_TAGS:
									community.tags = childNode;
									break;
							}
					}
				}
			}
			
			return community;
		}
		
		/**
		 * Handles parsing of the media:comments element.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		private function parseComments(commentsNode:XML):Vector.<String>
		{
			var comments:Vector.<String> = new Vector.<String>();
			var children:XMLList = commentsNode.children();
			
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
								case TAG_NAME_MRSS_COMMENT:
									var comment:String = childNode;
									comments.push(comment);
									break;
							}
					}
				}
			}
			
			return comments;
		}

		/**
		 * Handles parsing of the media:embed element.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		private function parseEmbed(embedNode:XML):MediaRSSEmbed
		{
			var embed:MediaRSSEmbed = new MediaRSSEmbed();
			var embedValues:Dictionary = new Dictionary();
			var children:XMLList = embedNode.children();
			
			embed.url = embedNode.@[ATTRIB_NAME_URL];
			embed.width = parseInt(embedNode.@[ATTRIB_NAME_WIDTH]);
			embed.height = parseInt(embedNode.@[ATTRIB_NAME_HEIGHT]);
			
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
								case TAG_NAME_MRSS_PARAM:
									var key:String = childNode.@[ATTRIB_NAME_NAME];
									var value:String = childNode;
									if (key != null && key.length > 0 && value != null && value.length > 0)
									{
										embedValues[key] = value;
									}
									break;
							}
					}
				}
			}
			
			embed.embedValues = embedValues;
			return embed;
		}

		/**
		 * Handles parsing of the media:responses element.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		private function parseResponses(responsesNode:XML):Vector.<String>
		{
			var responses:Vector.<String> = new Vector.<String>();
			var children:XMLList = responsesNode.children();
			
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
								case TAG_NAME_MRSS_RESPONSE:
									var response:String = childNode;
									responses.push(response);
									break;
							}
					}
				}
			}
			
			return responses;
		}
		
		/**
		 * Handles parsing of the media:backLinks element.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		private function parseBackLinks(backLinksNode:XML):Vector.<String>
		{
			var backLinks:Vector.<String> = new Vector.<String>();
			var children:XMLList = backLinksNode.children();
			
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
								case TAG_NAME_MRSS_BACK_LINK:
									var backLink:String = childNode;
									backLinks.push(backLink);
									break;
							}
					}
				}
			}
			
			return backLinks;
		}
		
		/**
		 * Handles parsing of the media:scenes element.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		private function parseScenes(scenesNode:XML):Vector.<MediaRSSScene>
		{
			var scenes:Vector.<MediaRSSScene> = new Vector.<MediaRSSScene>();
			var children:XMLList = scenesNode.children();
			
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
								case TAG_NAME_MRSS_SCENE:
									var scene:MediaRSSScene = new MediaRSSScene();
									scene.title = childNode.sceneTitle;
									scene.description = childNode.sceneDescription;
            						scene.startTime = childNode.sceneStartTime;
            						scene.endTime = childNode.sceneEndTime;
									scenes.push(scene);
									break;
							}
					}
				}
			}
			
			return scenes;
		}
		
		private static const TAG_NAME_MRSS_GROUP:String 		= "group";
		private static const TAG_NAME_MRSS_CONTENT:String 		= "content";
		private static const TAG_NAME_MRSS_RATING:String 		= "rating";
		private static const TAG_NAME_MRSS_TITLE:String 		= "title";	
		private static const TAG_NAME_MRSS_DESCRIPTION:String 	= "description";
		private static const TAG_NAME_MRSS_KEYWORDS:String 		= "keywords";
		private static const TAG_NAME_MRSS_THUMBNAIL:String 	= "thumbnail";
		private static const TAG_NAME_MRSS_CATEGORY:String 		= "category";
		private static const TAG_NAME_MRSS_HASH:String 			= "hash";
		private static const TAG_NAME_MRSS_PLAYER:String 		= "player";
		private static const TAG_NAME_MRSS_CREDIT:String 		= "credit";
		private static const TAG_NAME_MRSS_COPYRIGHT:String 	= "copyright";
		private static const TAG_NAME_MRSS_TEXT:String 			= "text";
		private static const TAG_NAME_MRSS_RESTRICTION:String 	= "restriction";
		private static const TAG_NAME_MRSS_COMMUNITY:String 	= "community";
		private static const TAG_NAME_MRSS_COMMENTS:String 		= "comments";
		private static const TAG_NAME_MRSS_COMMENT:String 		= "comment";
		private static const TAG_NAME_MRSS_EMBED:String 		= "embed";
		private static const TAG_NAME_MRSS_PARAM:String			= "param";
		private static const TAG_NAME_MRSS_RESPONSES:String 	= "responses";
		private static const TAG_NAME_MRSS_RESPONSE:String 		= "response";		
		private static const TAG_NAME_MRSS_BACK_LINKS:String 	= "backLinks";
		private static const TAG_NAME_MRSS_BACK_LINK:String		= "backLink";
		private static const TAG_NAME_MRSS_STATUS:String 		= "status";
		private static const TAG_NAME_MRSS_PRICE:String 		= "price";
		private static const TAG_NAME_MRSS_LICENSE:String 		= "license";
		private static const TAG_NAME_MRSS_SUBTITLE:String 		= "subTitle";
		private static const TAG_NAME_MRSS_PEER_LINK:String 	= "peerLink";
		private static const TAG_NAME_MRSS_LOCATION:String 		= "location";
		private static const TAG_NAME_MRSS_RIGHTS:String 		= "rights";
		private static const TAG_NAME_MRSS_SCENES:String 		= "scenes";
		private static const TAG_NAME_MRSS_STAR_RATING:String	= "starRating"
		private static const TAG_NAME_MRSS_STATISTICS:String	= "statistics";
		private static const TAG_NAME_MRSS_TAGS:String			= "tags";
		private static const TAG_NAME_MRSS_SCENE:String			= "scene";
		
		private static const ATTRIB_NAME_URL:String 		= "url";
		private static const ATTRIB_NAME_FILE_SIZE:String 	= "fileSize"; 
		private static const ATTRIB_NAME_TYPE:String 		= "type";
		private static const ATTRIB_NAME_MEDIUM:String 		= "medium";
		private static const ATTRIB_NAME_IS_DEFAULT:String 	= "isDefault"; 
		private static const ATTRIB_NAME_EXPRESSION:String 	= "expression"; 
		private static const ATTRIB_NAME_BITRATE:String 	= "bitrate"; 
		private static const ATTRIB_NAME_FRAME_RATE:String 	= "framerate";
		private static const ATTRIB_NAME_SAMPLE_RATE:String = "samplingrate";
		private static const ATTRIB_NAME_CHANNELS:String 	= "channels";
		private static const ATTRIB_NAME_DURATION:String 	= "duration"; 
		private static const ATTRIB_NAME_HEIGHT:String 		= "height";
		private static const ATTRIB_NAME_WIDTH:String 		= "width"; 
		private static const ATTRIB_NAME_LANGUAGE:String 	= "lang";
		private static const ATTRIB_NAME_SCHEME:String 		= "scheme";
		private static const ATTRIB_NAME_TIME:String		= "time";
		private static const ATTRIB_NAME_ALGORITHM:String	= "algo";
		private static const ATTRIB_NAME_LABEL:String		= "label";
		private static const ATTRIB_NAME_ROLE:String 		= "role";
		private static const ATTRIB_NAME_AVERAGE:String		= "average";
		private static const ATTRIB_NAME_COUNT:String		= "count";
		private static const ATTRIB_NAME_MIN:String			= "min";
		private static const ATTRIB_NAME_MAX:String			= "max";
		private static const ATTRIB_NAME_VIEWS:String		= "views";
		private static const ATTRIB_NAME_FAVORITES:String	= "favorites";
		private static const ATTRIB_NAME_RELATIONSHIP:String= "relationship";
		private static const ATTRIB_NAME_NAME:String		= "name";
		private static const ATTRIB_NAME_STATE:String		= "state";
		private static const ATTRIB_NAME_REASON:String		= "reason";
		private static const ATTRIB_NAME_CURRENCY:String	= "currency";
		private static const ATTRIB_NAME_INFO:String		= "info";
		private static const ATTRIB_NAME_PRICE:String		= "price";
		private static const ATTRIB_NAME_HREF:String		= "href";
		private static const ATTRIB_NAME_STATUS:String		= "status";
	}
}
