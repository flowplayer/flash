/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.vast.media
{
	import __AS3__.vec.Vector;
	
	import org.osmf.elements.ProxyElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.URLResource;
	import org.osmf.vast.model.VASTAd;
	import org.osmf.vast.model.VASTDocument;
	import org.osmf.vast.model.VASTInlineAd;
	import org.osmf.vast.model.VASTMediaFile;
	
	/**
	 * Utility class for creating MediaElements from a VASTDocument.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class VAST1MediaGenerator
	{
		/**
		 * Constructor.
		 * 
		 * @param mediaFileResolver The resolver to use when a VASTDocument
		 * contains multiple representations of the same content (MediaFile).
		 * If null, this object will use a DefaultVASTMediaFileResolver.
		 * @param mediaFactory Optional MediaFactory.  If specified, this
		 * object will be used to generate MediaElements.  If not specified,
		 * then the MediaElements will be directly instantiated.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function VAST1MediaGenerator(mediaFileResolver:IVASTMediaFileResolver=null, mediaFactory:MediaFactory=null)
		{
			super();
			
			this.mediaFileResolver =
				 mediaFileResolver != null
				 ? mediaFileResolver
				 : new DefaultVASTMediaFileResolver();
			this.mediaFactory = mediaFactory;
		}
		
		/**
		 * Creates all relevant MediaElements from the specified VAST document.
		 * 
		 * @param vastDocument The VASTDocument that holds the raw VAST information.
		 * 
		 * @returns A Vector of MediaElements, where each MediaElement
		 * represents a different VASTAd within the VASTDocument. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function createMediaElements(vastDocument:VASTDocument):Vector.<MediaElement>
		{
			var mediaElements:Vector.<MediaElement> = new Vector.<MediaElement>();
			
			for each (var vastAd:VASTAd in vastDocument.ads)
			{
				var inlineAd:VASTInlineAd = vastAd.inlineAd;
				if (inlineAd != null)
				{
					var clickThru:String = null;
					if (	inlineAd.video != null
						&& 	inlineAd.video.videoClick != null
						&&	inlineAd.video.videoClick.clickThrough != null
						&&	inlineAd.video.videoClick.clickThrough.url != null)
					{
						clickThru = inlineAd.video.videoClick.clickThrough.url;
					}
					
					// Set up the MediaElement for the ad package.  Note that
					// when we support more than just video ads (e.g. companion
					// and non-linear ads), we should wrap them all in a
					// ParallelElement.
					//
					
					var proxyChain:Vector.<ProxyElement> = new Vector.<ProxyElement>();
					
					// Check for the Impressions.
					if (inlineAd.impressions != null && inlineAd.impressions.length > 0)
					{
						proxyChain.push(new VASTImpressionProxyElement(inlineAd.impressions));
					}
					
					// Check for TrackingEvents.
					if (inlineAd.trackingEvents != null && inlineAd.trackingEvents.length > 0)
					{
						proxyChain.push(new VASTTrackingProxyElement(inlineAd.trackingEvents, null, null, clickThru));
					}
					
					// Check for Video.
					if (inlineAd.video != null)
					{
						// Resolve the correct one.
						var mediaFile:VASTMediaFile = mediaFileResolver.resolveMediaFiles(inlineAd.video.mediaFiles);
						if (mediaFile != null)
						{
							var mediaURL:String = mediaFile.url;
											
							// If streaming, we may need to strip off the extension.
							if (mediaFile.delivery == VASTMediaFile.DELIVERY_STREAMING)
							{
								mediaURL = mediaURL.replace(/\.flv$|\.f4v$/i, "");
							}

							var rootElement:MediaElement;
							
							if (mediaFactory != null)
							{
								rootElement = mediaFactory.createMediaElement(new URLResource(mediaURL));
							}
							else
							{
								rootElement = new VideoElement(new URLResource(mediaURL));
							}
							
							// Resolve the chain of ProxyElements, ensuring that
							// the VideoElement is at the deepest point. 
							for each (var proxyElement:ProxyElement in proxyChain)
							{
								proxyElement.proxiedElement = rootElement;
								rootElement = proxyElement;
							}
							
							mediaElements.push(rootElement);
						}
					}
				}
			}
			
			return mediaElements;
		}
		
		private var mediaFactory:MediaFactory;
		private var mediaFileResolver:IVASTMediaFileResolver;
		
	}
}