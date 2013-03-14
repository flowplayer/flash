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
*  Contributor(s): Adobe Systems Inc.
*   
*****************************************************/
package org.osmf.vast.parser
{
	import __AS3__.vec.Vector;
	
	import org.osmf.vast.model.VASTAd;
	import org.osmf.vast.model.VASTAdBase;
	import org.osmf.vast.model.VASTAdPackageBase;
	import org.osmf.vast.model.VASTCompanionAd;
	import org.osmf.vast.model.VASTDocument;
	import org.osmf.vast.model.VASTInlineAd;
	import org.osmf.vast.model.VASTMediaFile;
	import org.osmf.vast.model.VASTNonLinearAd;
	import org.osmf.vast.model.VASTResourceType;
	import org.osmf.vast.model.VASTTrackingEvent;
	import org.osmf.vast.model.VASTTrackingEventType;
	import org.osmf.vast.model.VASTUrl;
	import org.osmf.vast.model.VASTVideo;
	import org.osmf.vast.model.VASTVideoClick;
	import org.osmf.vast.model.VASTWrapperAd;

	CONFIG::LOGGING
	{
	import org.osmf.logging.Logger;
	import org.osmf.logging.Log;
	}

	/**
	 * This class parses a VAST 1.0 document into a VAST object model.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class VASTParser
	{		
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function VASTParser()
		{
			super();
		}
		
		/**
		 * A synchronous method to parse the raw VAST XML data into a VAST
		 * object model.
		 * 
		 * @param xml The XML representation of the VAST document.
		 * @param useStrictMode Whether the parser should be strict about
		 * ensuring that the XML conforms to the VAST specification.  If true,
		 * then any lack of adherence to the VAST spec (such as missing a
		 * required element) will be treated as an error, resulting in a null
		 * return value.  If false, then only fatal parsing errors will result
		 * in a null return value.  The default is true. 
		 * 
		 * @throws ArgumentError If xml is null.
		 * 
		 * @returns The parsed document, or null if any error was encountered
		 * during the parse. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function parse(xml:XML, useStrictMode:Boolean=true):VASTDocument 
		{
			if (xml == null)
			{
				throw new ArgumentError();
			}
			
			var vastDocument:VASTDocument = null;

			if (xml.localName() == ROOT_TAG)
			{
				vastDocument = new VASTDocument();
					
				for (var i:int = 0; i < xml.Ad.length(); i++)
				{
					var adXML:XML = xml.Ad[i];
					
					var id:String = parseAttributeAsString(adXML, ID);
					var vastAd:VASTAd = new VASTAd(id);
					parseAdTag(adXML, vastAd);
					vastDocument.addAd(vastAd);
				}
				
				// Validate if necessary.
				if (useStrictMode && validate(vastDocument) == false)
				{
					vastDocument = null;
				}
			}
			
			return vastDocument;
		}
		
		private function parseAdTag(xml:XML, vastAd:VASTAd):void 
		{
			var children:XMLList = xml.children();
			
			for (var i:int = 0; i < children.length(); i++) 
			{
				var child:XML = children[i];
				
				switch (child.nodeKind()) 
				{
					case NODEKIND_ELEMENT:
					{
						switch (child.localName()) 
						{
							case INLINE:
								parseInLineTag(child, vastAd);
								break;
							case WRAPPER:
								parseWrapperTag(child, vastAd);
								break;
							default:
								CONFIG::LOGGING
								{
									logger.debug("parseAdTag() - Unsupported VAST tag: " + child.localName());
								}
								break;							
						}
						break;
					}
				}
			}
		}
		
		private function parseInLineTag(xml:XML, vastAd:VASTAd):void 
		{
			var vastInlineAd:VASTInlineAd = new VASTInlineAd();
			
			var children:XMLList = xml.children();
			
			for (var i:int = 0; i < children.length(); i++) 
			{
				var child:XML = children[i];
				
				switch (child.nodeKind()) 
				{
					case NODEKIND_ELEMENT:
					{
						switch (child.localName()) 
						{
							case AD_SYSTEM:
								vastInlineAd.adSystem = parseString(child);
								break;
							case AD_TITLE:
								vastInlineAd.adTitle = parseString(child);
								break;
							case DESCRIPTION:
								vastInlineAd.description = parseString(child);
								break;
							case SURVEY:
								vastInlineAd.surveyURL = parseURL(child);
								break;
							case ERROR:
								vastInlineAd.errorURL = parseURL(child);
								break;
							case IMPRESSION:
								parseImpressionTag(child, vastInlineAd);
								break;
							case TRACKING_EVENTS:
								parseTrackingEvents(child, vastInlineAd);
								break;
							case VIDEO:
								parseVideo(child, vastInlineAd);
								break;
							case COMPANION_ADS:
								parseInlineCompanionAds(child, vastInlineAd);
								break;
							case NON_LINEAR_ADS:
								parseInlineNonLinearAds(child, vastInlineAd);
								break;
							case EXTENSIONS:
								parseExtensions(child, vastInlineAd);
								break;
							default:
								CONFIG::LOGGING
								{
									logger.debug("parseInlineTag() - Unsupported VAST tag: " + child.localName());
								}
								break;								
						}
						break;
					}
				}
			}

			vastAd.inlineAd = vastInlineAd;
		}
		
		private function parseWrapperTag(xml:XML, vastAd:VASTAd):void 
		{
			var vastWrapperAd:VASTWrapperAd = new VASTWrapperAd();

			var children:XMLList = xml.children();
			
			for (var i:int = 0; i < children.length(); i++) 
			{
				var child:XML = children[i];
				
				switch (child.nodeKind()) 
				{
					case NODEKIND_ELEMENT:
					{
						switch (child.localName()) 
						{
							case AD_SYSTEM:
								vastWrapperAd.adSystem = parseString(child);
								break;
							case VAST_AD_TAG_URL:
								vastWrapperAd.vastAdTagURL = parseURL(child);
								break;
							case COMPANION_ADS:
								parseWrapperCompanionAds(child, vastWrapperAd);
								break;
							case NON_LINEAR_ADS:
								parseWrapperNonLinearAds(child, vastWrapperAd);
								break;
							case ERROR:
								vastWrapperAd.errorURL = parseURL(child);
								break;
							case IMPRESSION:
								parseImpressionTag(child, vastWrapperAd);
								break;
							case TRACKING_EVENTS:
								parseTrackingEvents(child, vastWrapperAd);
								break;
							case VIDEO_CLICKS:
								vastWrapperAd.videoClick = parseVideoClicks(child);
								break;
							case EXTENSIONS:
								parseExtensions(child, vastWrapperAd);
								break;
							default:
								CONFIG::LOGGING
								{
									logger.debug("parseWrapperTag() - Unsupported VAST tag: " + child.localName());
								}
								break;								
						}
						break;
					}
				}
			}

			vastAd.wrapperAd = vastWrapperAd;
		}
		
		private function parseImpressionTag(xml:XML, vastAdPackage:VASTAdPackageBase):void 
		{
			var children:XMLList = xml.children();
			
			for (var i:int = 0; i < children.length(); i++) 
			{
				var child:XML = children[i];
				
				switch (child.nodeKind()) 
				{
					case NODEKIND_ELEMENT:
					{
						switch(child.localName()) 
						{
							case URL:
								vastAdPackage.addImpression(parseVASTUrl(child));
								break;
						}
						break;
					}
				}
			}
		}
				
		private function parseTrackingEvents(xml:XML, vastAdPackage:VASTAdPackageBase):void 
		{
			var children:XMLList = xml.children();
			
			for (var i:int = 0; i < children.length(); i++) 
			{
				var child:XML = children[i];
				
				switch (child.nodeKind()) 
				{
					case NODEKIND_ELEMENT:
					{
						switch(child.localName()) 
						{
							case TRACKING:
							{
								var eventType:String = parseAttributeAsString(child, EVENT);
								var trackingEvent:VASTTrackingEvent =
									new VASTTrackingEvent
										(VASTTrackingEventType.fromString(eventType)
										);
								var trackingURLs:Vector.<VASTUrl> = parseURLTags(child);
									
								trackingEvent.urls = trackingURLs;
								vastAdPackage.addTrackingEvent(trackingEvent);
								break;
							}
							default:
								CONFIG::LOGGING
								{
									logger.debug("parseTrackingEvents() - Unsupported VAST tag: " + child.localName());
								}
								break;								
						}
						break;
					}
				}
			}
		}
		
		private function parseURLTags(xml:XML, maxNumURLs:int=-1):Vector.<VASTUrl> 
		{
			var urls:Vector.<VASTUrl> = new Vector.<VASTUrl>;
			
			var children:XMLList = xml.children();
			
			for (var i:int = 0; i < children.length(); i++) 
			{
				var child:XML = children[i];
				
				// Stop when we hit the maximum allowed number (if we have one).
				if (maxNumURLs >= 0 &&
					urls.length >= maxNumURLs)
				{
					break;
				}
				
				switch(child.nodeKind()) 
				{
					case NODEKIND_ELEMENT:
					{
						switch (child.localName()) 
						{
							case URL:
								urls.push(parseVASTUrl(child));
								break;
							default:
								CONFIG::LOGGING
								{
									logger.debug("parseURLTags() - Unsupported VAST tag: " + child.localName());
								}
								break;								
						}
						break;
					}
				}
			}
			return urls;
		}
		
		private function parseVideo(xml:XML, vastInlineAd:VASTInlineAd):void
		{
			var video:VASTVideo = new VASTVideo();
			
			var children:XMLList = xml.children();
			
			for (var i:int = 0; i < children.length(); i++) 
			{
				var child:XML = children[i];
				
				switch (child.nodeKind()) 
				{
					case NODEKIND_ELEMENT:
					{
						switch(child.localName()) 
						{
							case DURATION:
								video.duration = parseString(child);
								break;
							case AD_ID:
								video.adID = parseString(child);
								break;
							case VIDEO_CLICKS:
								video.videoClick = parseVideoClicks(child);
								break;
							case MEDIA_FILES:
								parseMediaFiles(child, video);
								break;
							default:
								CONFIG::LOGGING
								{
									logger.debug("parseVideo() - Unsupported VAST tag: " + child.localName());
								}
								break;								
						}
						break;
					}
				}
			}
			
			vastInlineAd.video = video;
		}
		
		private function parseMediaFiles(xml:XML, video:VASTVideo):void
		{
			var children:XMLList = xml.children();
			
			for (var i:int = 0; i < children.length(); i++) 
			{
				var child:XML = children[i];
				switch (child.nodeKind()) 
				{
					case NODEKIND_ELEMENT:
					{
						switch(child.localName()) 
						{
							case MEDIA_FILE:
							{
								var mediaFile:VASTMediaFile = new VASTMediaFile();
								
								mediaFile.id 		= parseAttributeAsString(child, ID);
								mediaFile.bitrate 	= parseAttributeAsNumber(child, BITRATE);
								mediaFile.height 	= parseAttributeAsInt	(child, HEIGHT);
								mediaFile.width 	= parseAttributeAsInt	(child, WIDTH);
								mediaFile.delivery 	= parseAttributeAsString(child, DELIVERY);
								mediaFile.type 		= parseAttributeAsString(child, TYPE);
								mediaFile.url 		= parseURL(child);
								
								video.addMediaFile(mediaFile);
								break;									
							}
							default:
								CONFIG::LOGGING
								{
									logger.debug("parseMediaFiles() - Unsupported VAST tag: " + child.localName());
								}
								break;
						}
						break;
					}
				}
			}
		}
		
		private function parseInlineCompanionAds(xml:XML, vastInlineAd:VASTInlineAd):void 
		{
			var children:XMLList = xml.children();
			
			for (var i:int = 0; i < children.length(); i++) 
			{
				var child:XML = children[i];
				
				switch (child.nodeKind()) 
				{
					case NODEKIND_ELEMENT:
					{
						switch(child.localName()) 
						{
							case COMPANION:
								parseInlineCompanionAd(child, vastInlineAd);								
								break;
							default:
								CONFIG::LOGGING
								{
									logger.debug("parseInlineCompanionAds() - Unsupported VAST tag: " + child.localName());
								}
								break;								
						}
						break;
					}
				}
			}
		}

		private function parseInlineCompanionAd(xml:XML, vastInlineAd:VASTInlineAd):void 
		{
			var companionAd:VASTCompanionAd = new VASTCompanionAd();
			parseAdBase(xml, companionAd);
			
			var children:XMLList = xml.children();
			
			for (var i:int = 0; i < children.length(); i++) 
			{
				var child:XML = children[i];
				
				switch (child.nodeKind()) 
				{
					case NODEKIND_ELEMENT:
					{
						switch(child.localName()) 
						{
							case ALT_TEXT:
								companionAd.altText = parseString(child);
								break;
							case COMPANION_CLICK_THROUGH:
								companionAd.clickThroughURL = parseURL(child);
								break;
						}
						break;
					}
				}
			}
			
			vastInlineAd.addCompanionAd(companionAd);
		}
		
		private function parseWrapperCompanionAds(xml:XML, vastWrapperAd:VASTWrapperAd):void 
		{
			var children:XMLList = xml.children();
			
			if (children.length() > 0) 
			{
				var child:XML = children[0];
				
				switch (child.nodeKind()) 
				{
					case NODEKIND_ELEMENT:
					{
						switch(child.localName()) 
						{
							case COMPANION_IMPRESSION:
								vastWrapperAd.companionImpressions = parseURLTags(child);
								break;
							case COMPANION_AD_TAG:
								var urls:Vector.<VASTUrl> = parseURLTags(child, 1);
								if (urls.length > 0)
								{
									vastWrapperAd.companionAdTag = urls[0];
								}
								break;
							default:
								CONFIG::LOGGING
								{
									logger.debug("parseWrapperCompanionAds() - Unsupported VAST tag: " + child.localName());
								}
								break;								
						}
						break;
					}
				}
			}
		}
		
		private function parseWrapperNonLinearAds(xml:XML, vastWrapperAd:VASTWrapperAd):void 
		{
			var children:XMLList = xml.children();
			
			if (children.length() > 0) 
			{
				var child:XML = children[0];
				
				switch (child.nodeKind()) 
				{
					case NODEKIND_ELEMENT:
					{
						switch(child.localName()) 
						{
							case NON_LINEAR_IMPRESSION:
								vastWrapperAd.nonLinearImpressions = parseURLTags(child);
								break;
							case NON_LINEAR_AD_TAG:
								var urls:Vector.<VASTUrl> = parseURLTags(child, 1);
								if (urls.length > 0)
								{
									vastWrapperAd.nonLinearAdTag = urls[0];
								}
								break;
							default:
								CONFIG::LOGGING
								{
									logger.debug("parseWrapperNonLinearAds() - Unsupported VAST tag: " + child.localName());
								}
								break;								
						}
						break;
					}
				}
			}
		}
		
		private function parseInlineNonLinearAds(xml:XML, vastInlineAd:VASTInlineAd):void 
		{
			var children:XMLList = xml.children();
			
			for (var i:int = 0; i < children.length(); i++) 
			{
				var child:XML = children[i];
				
				switch (child.nodeKind()) 
				{
					case NODEKIND_ELEMENT:
					{
						switch(child.localName()) 
						{
							case NON_LINEAR:
								parseInlineNonLinearAd(child, vastInlineAd);								
								break;
							default:
								CONFIG::LOGGING
								{
									logger.debug("parseInlineNonLinearAds() - Unsupported VAST tag: " + child.localName());
								}
								break;								
						}
						break;
					}
				}
			}
		}
		
		private function parseInlineNonLinearAd(xml:XML, vastInlineAd:VASTInlineAd):void 
		{
			var nonLinearAd:VASTNonLinearAd = new VASTNonLinearAd();
			parseAdBase(xml, nonLinearAd);

			nonLinearAd.scalable 			= parseAttributeAsBoolean(xml, SCALABLE)
			nonLinearAd.maintainAspectRatio = parseAttributeAsBoolean(xml, MAINTAIN_ASPECT_RATIO);
			nonLinearAd.apiFramework 		= parseAttributeAsString (xml, API_FRAMEWORK);
			
			var children:XMLList = xml.children();
			
			for (var i:int = 0; i < children.length(); i++) 
			{
				var child:XML = children[i];
				
				switch (child.nodeKind()) 
				{
					case NODEKIND_ELEMENT:
					{
						switch(child.localName()) 
						{
							case NON_LINEAR_CLICK_THROUGH:
								nonLinearAd.clickThroughURL = parseURL(child);
								break;
						}
						break;
					}
				}
			}
			
			vastInlineAd.addNonLinearAd(nonLinearAd);
		}

		private function parseAdBase(xml:XML, vastAdBase:VASTAdBase):void
		{
			var children:XMLList = xml.children();
			
			vastAdBase.id 				= parseAttributeAsString(xml, ID);
			vastAdBase.width 			= parseAttributeAsInt	(xml, WIDTH);
			vastAdBase.height 			= parseAttributeAsInt	(xml, HEIGHT);
			vastAdBase.expandedWidth 	= parseAttributeAsInt	(xml, EXPANDED_WIDTH);
			vastAdBase.expandedHeight 	= parseAttributeAsInt	(xml, EXPANDED_HEIGHT);
			vastAdBase.resourceType 	= VASTResourceType.fromString(parseAttributeAsString(xml, RESOURCE_TYPE));
			vastAdBase.creativeType 	= parseAttributeAsString(xml, CREATIVE_TYPE);

			for (var i:int = 0; i < children.length(); i++) 
			{
				var child:XML = children[i];
				
				switch (child.nodeKind()) 
				{
					case NODEKIND_ELEMENT:
					{
						switch(child.localName()) 
						{
							case URL:
								vastAdBase.url = parseURL(child);
								break;
							case CODE:
								vastAdBase.code = parseString(child);
								break;
							case AD_PARAMETERS:
								vastAdBase.adParameters = parseString(child);
								break;
						}
						break;
					}
				}
			}
		}

		private function parseExtensions(xml:XML, vastAdPackage:VASTAdPackageBase):void 
		{
			var children:XMLList = xml.children();
			
			for (var i:int = 0; i < children.length(); i++) 
			{
				var child:XML = children[i];
				
				switch (child.nodeKind()) 
				{
					case NODEKIND_ELEMENT:
					{
						switch(child.localName()) 
						{
							case EXTENSION:
								vastAdPackage.addExtension(child);
								break;
							default:
								CONFIG::LOGGING
								{
									logger.debug("parseExtensions() - Unsupported VAST tag: " + child.localName());
								}
								break;								
						}
						break;
					}
				}
			}
		}
		
		private function parseVideoClicks(xml:XML):VASTVideoClick
		{
			var videoClick:VASTVideoClick = new VASTVideoClick();
			
			var children:XMLList = xml.children();
			
			for (var i:int = 0; i < children.length(); i++) 
			{
				var child:XML = children[i];
				
				switch (child.nodeKind()) 
				{
					case NODEKIND_ELEMENT:
					{
						switch(child.localName()) 
						{
							case CLICK_THROUGH:
								var urls:Vector.<VASTUrl> = parseURLTags(child, 1);
								if (urls.length > 0)
								{
									videoClick.clickThrough = urls[0];
								}
								break;
							case CLICK_TRACKING:
								videoClick.clickTrackings = parseURLTags(child);
								break;
							case CUSTOM_CLICK:
								videoClick.customClicks = parseURLTags(child);
								break;
							default:
								CONFIG::LOGGING
								{
									logger.debug("parseVideoClicks() - Unsupported VAST tag: " + child.localName());
								}
								break;								
						}
						break;
					}
				}
			}
			
			return videoClick;
		}

		private function parseVASTUrl(xml:XML):VASTUrl
		{
			return new VASTUrl(parseURL(xml), parseAttributeAsString(xml, ID));
		}
		
		private function parseURL(xml:XML):String
		{
			var child:String = xml.children()[0];
			if (child != null)
			{
				// Strip all leading and trailing whitespace.
				child = child.replace(/^\s*|\s*$/g, "");
				if (child.length == 0)
				{
					child = null;
				}
			}
			
			return child;
		}
		
		private function parseString(xml:XML):String
		{
			var s:String = xml.toString();
			return s.length > 0 ? s : null;
		}

		private function parseAttributeAsString(xml:XML, attribute:String):String
		{
			if (xml.@[attribute].length() > 0)
			{
				return xml.@[attribute];
			}
			
			return null;
		}
		
		private function parseAttributeAsBoolean(xml:XML, attribute:String):Boolean
		{
			return xml.@[attribute] == "true";
		}

		private function parseAttributeAsInt(xml:XML, attribute:String):int
		{
			return xml.@[attribute];
		}

		private function parseAttributeAsNumber(xml:XML, attribute:String):Number
		{
			return xml.@[attribute];
		}
		
		private function validate(document:VASTDocument):Boolean
		{
			var isValid:Boolean = true;
			
			for each (var ad:VASTAd in document.ads)
			{
				var inlineAd:VASTInlineAd = ad.inlineAd;
				var wrapperAd:VASTWrapperAd = ad.wrapperAd;
				
				if (inlineAd != null &&
					wrapperAd != null)
				{
					CONFIG::LOGGING
					{
						logger.debug("Invalid VAST document:  Ad cannot have both Inline and Wrapper");
					}

					isValid = false;
					break;
				}
				
				// Validate any InlineAd.
				if (inlineAd != null)
				{
					if (inlineAd.adSystem == null ||
						inlineAd.adTitle == null ||
						inlineAd.impressions.length == 0)
					{
						CONFIG::LOGGING
						{
							logger.debug("Invalid VAST document:  InlineAd requires AdSystem, AdTitle, and Impression");
						}
								
						isValid = false;
						break;
					}
					
					// Validate all TrackingEvents.
					if (validateTrackingEvents(inlineAd.trackingEvents) == false)
					{
						isValid = false
						break;
					}
					
					// Validate any Video.
					var video:VASTVideo = inlineAd.video;
					if (video != null)
					{
						if (video.duration == null)
						{
							CONFIG::LOGGING
							{
								logger.debug("Invalid VAST document:  Video requires Duration");
							}
									
							isValid = false;
							break;
						}
						
						// Validate all MediaFiles.
						for each (var mediaFile:VASTMediaFile in video.mediaFiles)
						{
							if (mediaFile.url == null ||
								mediaFile.delivery == null ||
								mediaFile.bitrate == 0 ||
								mediaFile.width == 0 ||
								mediaFile.height == 0)
							{
								CONFIG::LOGGING
								{
									logger.debug("Invalid VAST document:  MediaFile requires URL, plus delivery, bitrate, width and height attributes");
								}
										
								isValid = false;
								break;
							}
						}
					}

					// Validate all CompanionAds.
					for each (var companionAd:VASTCompanionAd in inlineAd.companionAds)
					{
						if (validateAdBase(companionAd) == false)
						{
							CONFIG::LOGGING
							{
								logger.debug("Invalid VAST document:  CompanionAd requires width, height, and resourceType attributes");
							}
									
							isValid = false;
							break;
						}
					}
					
					// Validate all NonLinearAds.
					for each (var nonLinearAd:VASTNonLinearAd in inlineAd.nonLinearAds)
					{
						if (validateAdBase(nonLinearAd) == false)
						{
							CONFIG::LOGGING
							{
								logger.debug("Invalid VAST document:  NonLinearAd requires width, height, and resourceType attributes");
							}
									
							isValid = false;
							break;
						}
					}
					
					if (isValid == false)
					{
						break;
					}
				}
				
				// Validate any WrapperAd.
				if (wrapperAd != null)
				{
					if (wrapperAd.adSystem == null ||
						wrapperAd.vastAdTagURL == null ||
						wrapperAd.impressions.length == 0)
					{
						CONFIG::LOGGING
						{
							logger.debug("Invalid VAST document:  WrapperAd requires AdSystem, VASTAdTagURL, and Impression");
						}
								
						isValid = false;
						break;
					}
					
					// Validate all TrackingEvents.
					if (validateTrackingEvents(wrapperAd.trackingEvents) == false)
					{
						isValid = false
						break;
					}
				}
			}
			
			return isValid;
		}
		
		private function validateTrackingEvents(trackingEvents:Vector.<VASTTrackingEvent>):Boolean
		{
			// Validate all TrackingEvents.
			for each (var event:VASTTrackingEvent in trackingEvents)
			{
				if (event.type == null)
				{
					CONFIG::LOGGING
					{
						logger.debug("Invalid VAST document:  TrackingEvent requires valid type attribute");
					}
									
					return false;
				}
			}
			
			return true;
		}

		
		private function validateAdBase(adBase:VASTAdBase):Boolean
		{
			if (adBase.width == 0 ||
				adBase.height == 0 ||
				adBase.resourceType == null)
			{
				return false;
			}
				
			return true;
		}

		private static const NODEKIND_ELEMENT:String = "element";
				
		private static const ROOT_TAG:String 					= "VideoAdServingTemplate";
		private static const INLINE:String 						= "InLine";
		private static const WRAPPER:String 					= "Wrapper";
		private static const AD_SYSTEM:String 					= "AdSystem";
		private static const AD_TITLE:String 					= "AdTitle";
		private static const DESCRIPTION:String 				= "Description";
		private static const SURVEY:String 						= "Survey";
		private static const ERROR:String 						= "Error";
		private static const VAST_AD_TAG_URL:String 			= "VASTAdTagURL";
		private static const IMPRESSION:String 					= "Impression";
		private static const TRACKING_EVENTS:String 			= "TrackingEvents";
		private static const TRACKING:String 					= "Tracking";
		private static const URL:String 						= "URL";
		private static const CODE:String 						= "Code";
		private static const VIDEO:String 						= "Video";
		private static const DURATION:String 					= "Duration";
		private static const AD_ID:String 						= "AdID";
		private static const MEDIA_FILES:String 				= "MediaFiles";
		private static const MEDIA_FILE:String 					= "MediaFile";
		private static const VIDEO_CLICKS:String 				= "VideoClicks";
		private static const CLICK_TRACKING:String 				= "ClickTracking";
		private static const CLICK_THROUGH:String 				= "ClickThrough";
		private static const CUSTOM_CLICK:String 				= "CustomClick";
		private static const COMPANION_ADS:String 				= "CompanionAds";
		private static const COMPANION:String 					= "Companion";
		private static const COMPANION_CLICK_THROUGH:String 	= "CompanionClickThrough";
		private static const COMPANION_IMPRESSION:String		= "CompanionImpression";
		private static const COMPANION_AD_TAG:String			= "CompanionAdTag";
		private static const ALT_TEXT:String 					= "AltText";
		private static const AD_PARAMETERS:String 				= "AdParameters";
		private static const NON_LINEAR_ADS:String 				= "NonLinearAds";
		private static const NON_LINEAR:String 					= "NonLinear";
		private static const NON_LINEAR_CLICK_THROUGH:String 	= "NonLinearClickThrough";
		private static const NON_LINEAR_IMPRESSION:String		= "NonLinearImpression";
		private static const NON_LINEAR_AD_TAG:String			= "NonLinearAdTag";
		private static const EXTENSIONS:String 					= "Extensions";
		private static const EXTENSION:String 					= "Extension";
		
		private static const ID:String							= "id";
		private static const EVENT:String						= "event";
		private static const WIDTH:String						= "width";
		private static const HEIGHT:String						= "height";
		private static const EXPANDED_WIDTH:String				= "expandedWidth";
		private static const EXPANDED_HEIGHT:String				= "expandedHeight";
		private static const RESOURCE_TYPE:String				= "resourceType";
		private static const CREATIVE_TYPE:String				= "creativeType";
		private static const SCALABLE:String					= "scalable";
		private static const MAINTAIN_ASPECT_RATIO:String		= "maintainAspectRatio";
		private static const API_FRAMEWORK:String				= "apiFramework";
		private static const BITRATE:String 					= "bitrate";
		private static const DELIVERY:String 					= "delivery";
		private static const TYPE:String 						= "type";

		CONFIG::LOGGING
		private static const logger:Logger = Log.getLogger("org.osmf.vast.parser.VASTParser");
	}
}
