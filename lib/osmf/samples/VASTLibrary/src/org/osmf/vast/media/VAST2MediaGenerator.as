/*****************************************************
*  
*  Copyright 2010 Eyewonder, LLC.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Eyewonder, LLC.
*  Portions created by Eyewonder, LLC. are Copyright (C) 2010 
*  Eyewonder, LLC. A Limelight Networks Business. All Rights Reserved. 
*  
*****************************************************/

package org.osmf.vast.media
{
	import __AS3__.vec.Vector;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.osmf.elements.ProxyElement;
	import org.osmf.elements.SWFLoader;
	import org.osmf.elements.VideoElement;
	import org.osmf.elements.beaconClasses.Beacon;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.HTTPLoader;
	import org.osmf.vast.model.VAST2MediaFile;
	import org.osmf.vast.model.VAST2Translator;
	import org.osmf.vast.model.VASTTrackingEvent;
	import org.osmf.vast.model.VASTTrackingEventType;
	import org.osmf.vast.model.VASTUrl;
	import org.osmf.vast.parser.base.VAST2CompanionElement;
	import org.osmf.vpaid.elements.VPAIDElement;
	import org.osmf.vpaid.metadata.VPAIDMetadata;
	
	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
		import org.osmf.logging.Log;
	}

	/**
	 * Utility class for creating MediaElements from a VASTDocument.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class VAST2MediaGenerator
	{
		/**
		 * Constructor.
		 * 
		 * @param mediaFileResolver The resolver to use when a VASTDocument
		 * contains multiple representations of the same content (MediaFile).
		 * If null, this object will use a DefaultVASTMediaFileResolver.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function VAST2MediaGenerator(mediaFileResolver:IVAST2MediaFileResolver=null, mediaFactory:MediaFactory=null)
		{
			super();
			
			this.mediaFileResolver =
				 mediaFileResolver != null
				 ? mediaFileResolver
				 : new DefaultVAST2MediaFileResolver();
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
		public function createMediaElements(vastDocument:VAST2Translator, vastPlacement:String = null):Vector.<MediaElement>
		{
			var mediaElements:Vector.<MediaElement> = new Vector.<MediaElement>();
			
			this.vastDocument = vastDocument;
			vastDocument.adPlacement = (vastPlacement == null)?vastDocument.PLACEMENT_LINEAR:vastPlacement;
			
			if(vastDocument.clickThruUrl != null || vastDocument.clickThruUrl != "")
			{
				clickThru = vastDocument.clickThruUrl
			}
			
			
			cacheBuster = new CacheBuster();
			
	
			var trackingEvents:Vector.<VASTTrackingEvent> = new Vector.<VASTTrackingEvent>;
			var proxyChain:Vector.<ProxyElement> = new Vector.<ProxyElement>();
			
			// Check for the Impressions.
			if (vastDocument.impressionArray != null && vastDocument.impressionArray.length > 0)
			{
				var impressionArray:Vector.<VASTUrl> = new Vector.<VASTUrl>;
				for each(var impressionObj:Object in vastDocument.impressionArray)
				{
					var impressionURL:VASTUrl = new VASTUrl(impressionObj.url);
					impressionArray.push(impressionURL);
				}
			}
			
			if(vastDocument.trkClickThruEvent != null && vastDocument.trkClickThruEvent.length > 0)
			{
				
				var clickThruEvent:VASTTrackingEvent = new VASTTrackingEvent(VASTTrackingEventType.CLICK_THRU);
				var clickThruArray:Vector.<VASTUrl> = new Vector.<VASTUrl>;
				
				for each(var clickThruObj:Object in vastDocument.trkClickThruEvent)
				{
					
					var clickThruURL:VASTUrl = new VASTUrl(clickThruObj.url);
					clickThruArray.push(clickThruURL);
				}

				clickThruEvent.urls = clickThruArray;
				trackingEvents.push(clickThruEvent);						
			}
			
		
			if(vastDocument.errorArray != null && vastDocument.errorArray.length > 0)
			{
				var errorEvent:VASTTrackingEvent = new VASTTrackingEvent(VASTTrackingEventType.ERROR);
				var errorArray:Vector.<VASTUrl> = new Vector.<VASTUrl>;

				for each(var errorObj:Object in vastDocument.errorArray)
				{
					var errorURL:VASTUrl = new VASTUrl(errorObj.url);
					errorArray.push(errorURL);
				}

				errorEvent.urls = errorArray;
				trackingEvents.push(errorEvent);						
			}			
			
			
			// Check for the Start trackers.
			if(vastDocument.trkStartEvent != null && vastDocument.trkStartEvent.length > 0)
			{
				var startEvent:VASTTrackingEvent = new VASTTrackingEvent(VASTTrackingEventType.START);
				var urlArray:Vector.<VASTUrl> = new Vector.<VASTUrl>;

				for each(var startObj:Object in vastDocument.trkStartEvent)
				{
					var startURL:VASTUrl = new VASTUrl(startObj.url);
					urlArray.push(startURL);
				}

				startEvent.urls = urlArray;
				trackingEvents.push(startEvent);						
			}
			
				// Check for the Midpoint trackers.
			if(vastDocument.trkMidPointEvent != null && vastDocument.trkMidPointEvent.length > 0)
			{
				var midPointEvent:VASTTrackingEvent = new VASTTrackingEvent(VASTTrackingEventType.MIDPOINT);
				var midPointArray:Vector.<VASTUrl> = new Vector.<VASTUrl>;
				
				for each(var midpointObj:Object in vastDocument.trkMidPointEvent)
				{
					var midPointURL:VASTUrl = new VASTUrl(midpointObj.url);
					midPointArray.push(midPointURL);
				}
				
				midPointEvent.urls = midPointArray;
				trackingEvents.push(midPointEvent);	
			}
				// Check for the First Quartile trackers.
			if(vastDocument.trkFirstQuartileEvent != null && vastDocument.trkFirstQuartileEvent.length > 0)
			{
				var firstQuartileArray:Vector.<VASTUrl> = new Vector.<VASTUrl>;
				var firstQuartileEvent:VASTTrackingEvent = new VASTTrackingEvent(VASTTrackingEventType.FIRST_QUARTILE);
				
				for each(var firstQuartileObj:Object in vastDocument.trkFirstQuartileEvent)
				{
					var firstQuartileURL:VASTUrl = new VASTUrl(firstQuartileObj.url);
					firstQuartileArray.push(firstQuartileURL);
				}	
				
				firstQuartileEvent.urls = firstQuartileArray;
				trackingEvents.push(firstQuartileEvent);
			}
				// Check for the Third Quartiles trackers.
			if(vastDocument.trkThirdQuartileEvent != null && vastDocument.trkThirdQuartileEvent.length > 0)
			{
				var thirdQuartileEvent:VASTTrackingEvent = new VASTTrackingEvent(VASTTrackingEventType.THIRD_QUARTILE);
				var thirdQuartileArray:Vector.<VASTUrl> = new Vector.<VASTUrl>;
				
				for each(var thirdQuartileObj:Object in vastDocument.trkThirdQuartileEvent)
				{
					var thirdQuartileURL:VASTUrl = new VASTUrl(thirdQuartileObj.url);
					thirdQuartileArray.push(thirdQuartileURL);
				}
				
				thirdQuartileEvent.urls = thirdQuartileArray;
				trackingEvents.push(thirdQuartileEvent);
					
			}
				// Check for the Complete trackers.
			if(vastDocument.trkCompleteEvent != null && vastDocument.trkCompleteEvent.length > 0)
			{
				var completeArray:Vector.<VASTUrl> = new Vector.<VASTUrl>;
				var completeEvent:VASTTrackingEvent = new VASTTrackingEvent(VASTTrackingEventType.COMPLETE);
				
				for each(var completeObj:Object in vastDocument.trkCompleteEvent)
				{
					var completeURL:VASTUrl = new VASTUrl(completeObj.url);
					completeArray.push(completeURL);
				}	
				
				completeEvent.urls = completeArray;
				trackingEvents.push(completeEvent);
			}
			
				// Check for the Mute trackers.			
			if(vastDocument.trkMuteEvent != null && vastDocument.trkMuteEvent.length > 0)
			{
				var muteArray:Vector.<VASTUrl> = new Vector.<VASTUrl>;
				var muteEvent:VASTTrackingEvent = new VASTTrackingEvent(VASTTrackingEventType.MUTE);
				
				for each(var muteObj:Object in vastDocument.trkMuteEvent)
				{
					var muteURL:VASTUrl = new VASTUrl(muteObj.url);
					muteArray.push(muteURL);
				}
				
				muteEvent.urls = muteArray;
				trackingEvents.push(muteEvent);
			}
			
			if(vastDocument.trkCreativeViewEvent != null && vastDocument.trkCreativeViewEvent.length > 0)
			{
				var creativeViewArray:Vector.<VASTUrl> = new Vector.<VASTUrl>;
				var creativeViewEvent:VASTTrackingEvent = new VASTTrackingEvent(VASTTrackingEventType.CREATIVE_VIEW);
				
				for each(var creativeViewObj:Object in vastDocument.trkCreativeViewEvent)
				{
					var creativeViewURL:VASTUrl = new VASTUrl(creativeViewObj.url);
					creativeViewArray.push(creativeViewURL);
				}
				
				creativeViewEvent.urls = creativeViewArray;
				trackingEvents.push(creativeViewEvent);
			}			
			
				// Check for the Pause trackers.
			if(vastDocument.trkPauseEvent != null && vastDocument.trkPauseEvent.length > 0)
			{
				var pauseArray:Vector.<VASTUrl> = new Vector.<VASTUrl>;
				var pauseEvent:VASTTrackingEvent = new VASTTrackingEvent(VASTTrackingEventType.PAUSE);
				
				for each(var pauseObj:Object in vastDocument.trkPauseEvent)
				{	
					var pauseURL:VASTUrl = new VASTUrl(pauseObj.url);
					pauseArray.push(pauseURL);
				}
				
				pauseEvent.urls = pauseArray;
				trackingEvents.push(pauseEvent);
			}
			
				// Check for the ClickThru trackers.
			if(vastDocument.trkReplayEvent != null && vastDocument.trkReplayEvent.length > 0)
			{
				var replayArray:Vector.<VASTUrl> = new Vector.<VASTUrl>;
				var replayEvent:VASTTrackingEvent = new VASTTrackingEvent(VASTTrackingEventType.REPLAY);
				for each(var replayObj:Object in vastDocument.trkReplayEvent)
				{
					var replayURL:VASTUrl = new VASTUrl(replayObj.url);
					replayArray.push(replayURL);
				}
				
				replayEvent.urls = replayArray;
				trackingEvents.push(replayEvent);
			}
				// Check for the FullScreen trackers.
			if(vastDocument.trkFullScreenEvent != null && vastDocument.trkFullScreenEvent.length > 0)
			{
				var fullscreenArray:Vector.<VASTUrl> = new Vector.<VASTUrl>;
				var fullscreenEvent:VASTTrackingEvent = new VASTTrackingEvent(VASTTrackingEventType.FULLSCREEN);
				
				for each(var fullscreenObj:Object in vastDocument.trkFullScreenEvent)
				{
					var fullscreenURL:VASTUrl = new VASTUrl(fullscreenObj.url);
					fullscreenArray.push(fullscreenURL);
				}
				
				fullscreenEvent.urls = fullscreenArray;
				trackingEvents.push(fullscreenEvent);
			}
				// Check for the Stop trackers.
			if(vastDocument.trkStopEvent != null && vastDocument.trkStopEvent.length > 0)
			{
				var stopArray:Vector.<VASTUrl> = new Vector.<VASTUrl>;
				var stopEvent:VASTTrackingEvent = new VASTTrackingEvent(VASTTrackingEventType.STOP);
				
				for each(var stopObj:Object in vastDocument.trkStopEvent)
				{
					var stopURL:VASTUrl = new VASTUrl(stopObj.url);
					stopArray.push(stopURL);
				}
				stopEvent.urls = stopArray;
				trackingEvents.push(stopEvent);
			}
			
			
			//Clickthru tracking to be enabled when clickthrus are built into the VAST media element.
			if(vastDocument.trkUnmuteEvent != null && vastDocument.trkUnmuteEvent.length > 0)
			{
				var unmuteArray:Vector.<VASTUrl> = new Vector.<VASTUrl>;
				var unmuteEvent:VASTTrackingEvent = new VASTTrackingEvent(VASTTrackingEventType.UNMUTE);
				for each(var unmuteObj:Object in vastDocument.trkUnmuteEvent)
				{
					
					var unmuteURL:VASTUrl = new VASTUrl(unmuteObj.url);					
					unmuteArray.push(unmuteURL);
					
				}
				
				unmuteEvent.urls = unmuteArray;
				trackingEvents.push(unmuteEvent);
			}
			
			// Check for the Start trackers.
			if(vastDocument.trkCloseEvent != null && vastDocument.trkCloseEvent.length > 0)
			{
				var closeEvent:VASTTrackingEvent = new VASTTrackingEvent(VASTTrackingEventType.CLOSE);
				var closeArray:Vector.<VASTUrl> = new Vector.<VASTUrl>;

				for each(var closeObj:Object in vastDocument.trkCloseEvent)
				{
					var closeURL:VASTUrl = new VASTUrl(closeObj.url);
					closeArray.push(closeURL);
				}

				closeEvent.urls = closeArray;
				trackingEvents.push(closeEvent);						
			}
			
						// Check for the Start trackers.
			if(vastDocument.trkRewindEvent != null && vastDocument.trkRewindEvent.length > 0)
			{
				var rewindEvent:VASTTrackingEvent = new VASTTrackingEvent(VASTTrackingEventType.REWIND);
				var rewindArray:Vector.<VASTUrl> = new Vector.<VASTUrl>;

				for each(var rewindObj:Object in vastDocument.trkRewindEvent)
				{
					var rewindURL:VASTUrl = new VASTUrl(rewindObj.url);
					rewindArray.push(rewindURL);
				}

				rewindEvent.urls = rewindArray;
				trackingEvents.push(rewindEvent);						
			}
			
			if(vastDocument.trkResumeEvent != null && vastDocument.trkResumeEvent.length > 0)
			{
				var resumeEvent:VASTTrackingEvent = new VASTTrackingEvent(VASTTrackingEventType.RESUME);
				var resumeArray:Vector.<VASTUrl> = new Vector.<VASTUrl>;

				for each(var resumeObj:Object in vastDocument.trkResumeEvent)
				{
					var resumeURL:VASTUrl = new VASTUrl(resumeObj.url);
					resumeArray.push(resumeURL);
				}

				resumeEvent.urls = resumeArray;
				trackingEvents.push(resumeEvent);						
			}
			
			if(vastDocument.trkExpandEvent != null && vastDocument.trkExpandEvent.length > 0)
			{
				var expandEvent:VASTTrackingEvent = new VASTTrackingEvent(VASTTrackingEventType.EXPAND);
				var expandArray:Vector.<VASTUrl> = new Vector.<VASTUrl>;
				
				for each(var expandObj:Object in vastDocument.trkExpandEvent)
				{
					var expandURL:VASTUrl = new VASTUrl(expandObj.url);
					expandArray.push(expandURL);
				}

				expandEvent.urls = expandArray;
				trackingEvents.push(expandEvent);						
			}

			if(vastDocument.trkCollapseEvent != null && vastDocument.trkCollapseEvent.length > 0)
			{
				var collapseEvent:VASTTrackingEvent = new VASTTrackingEvent(VASTTrackingEventType.COLLAPSE);
				var collapseArray:Vector.<VASTUrl> = new Vector.<VASTUrl>;
				
				for each(var collapseObj:Object in vastDocument.trkCollapseEvent)
				{
					var collapseURL:VASTUrl = new VASTUrl(collapseObj.url);
					collapseArray.push(collapseURL);
				}

				collapseEvent.urls = collapseArray;
				trackingEvents.push(collapseEvent);						
			}
			
			if(vastDocument.trkAcceptInvitationEvent != null && vastDocument.trkAcceptInvitationEvent.length > 0)
			{
				var acceptInvitationEvent:VASTTrackingEvent = new VASTTrackingEvent(VASTTrackingEventType.COLLAPSE);
				var acceptInvitationArray:Vector.<VASTUrl> = new Vector.<VASTUrl>;

				for each(var acceptInvitationObj:Object in vastDocument.trkAcceptInvitationEvent)
				{
					var acceptInvitationURL:VASTUrl = new VASTUrl(acceptInvitationObj.url);
					acceptInvitationArray.push(acceptInvitationURL);
				}

				acceptInvitationEvent.urls = acceptInvitationArray;
				trackingEvents.push(acceptInvitationEvent);						
			}			

			// Check for Video.
			if (vastDocument.mediafileArray != null && vastDocument.mediafileArray.length > 0 && isLinear)
			{
				
				for each(var mediaObj:Object in vastDocument.mediafileArray)
				{
					var mediaFileObj:VAST2MediaFile = new VAST2MediaFile();
					mediaFileObj.url = mediaObj.url;
					mediaFileObj.delivery = mediaObj.delivery;
					mediaFileObj.bitrate = mediaObj.bitrate;
					mediaFileObj.type = mediaObj.type;
					mediaFileObj.width = mediaObj.width;
					mediaFileObj.height = mediaObj.height;
					mediaFileObj.id = mediaObj.id;
					mediaFileObj.scalable = mediaObj.scalable;
					mediaFileObj.maintainAspectRatio = mediaObj.maintainAspectRatio;
					mediaFileObj.apiFramework = mediaObj.apiFramework;

					var mediaFileURL:Vector.<VAST2MediaFile> = new Vector.<VAST2MediaFile>;
					mediaFileURL.push(mediaFileObj);
				}

				// Resolve the correct one.
				var mediaFile:VAST2MediaFile = mediaFileResolver.resolveMediaFiles(mediaFileURL);
				if (mediaFile != null)
				{
					var mediaURL:String = mediaFile.url;
									
					// If streaming, we may need to strip off the extension.
					if (mediaFile.delivery == "streaming" && mediaFile.type != "application/x-shockwave-flash")
					{
						mediaURL = mediaURL.replace(/\.flv$|\.f4v$/i, "");
						
					}

					var rootElement:MediaElement;
					
					if(mediaFile.type == "application/x-shockwave-flash")
					{
					
						rootElement = new VPAIDElement(new URLResource(mediaFile.url), new SWFLoader());
						VPAIDMetadata(rootElement.getMetadata("org.osmf.vpaid.metadata.VPAIDMetadata")).addValue(VPAIDMetadata.NON_LINEAR_CREATIVE, false);
					}
					else 
					{
						if (mediaFactory != null)
						{
							rootElement = mediaFactory.createMediaElement(new URLResource(mediaURL)) as VideoElement;
							//VideoElement(rootElement).smoothing = true;
						}
						else
						{
							rootElement = new VideoElement(new URLResource(mediaURL));
							//VideoElement(rootElement).smoothing = true;
						}
						

					}
					
					
					var impressions:VASTImpressionProxyElement = new VAST2ImpressionProxyElement(impressionArray, null, rootElement, cacheBuster);
					var events:VASTTrackingProxyElement = new VAST2TrackingProxyElement(trackingEvents,null, impressions, cacheBuster,clickThru);
					var vastMediaElement:MediaElement = events;
					
					mediaElements.push(vastMediaElement);


				}
			}
			else if(vastDocument.nonlinearArray != null && vastDocument.nonlinearArray.length > 0 && isNonLinear)
			{
				
				//Non-linear check goes here.  If available create VPAID Element
				for each(var element:Object in vastDocument.nonlinearArray)
				{
					
					if(element.creativeType == "application/x-shockwave-flash")
					{
						
						var vpaidElement:MediaElement = new VPAIDElement(new URLResource(element.URL), new SWFLoader());
						var vpaidMetadata:Metadata = vpaidElement.getMetadata(VPAIDMetadata.NAMESPACE);
						vpaidMetadata.addValue(VPAIDMetadata.NON_LINEAR_CREATIVE, true);
						
						
						var impressionsNonLinear:VASTImpressionProxyElement = new VAST2ImpressionProxyElement(impressionArray, null, vpaidElement, cacheBuster);							
						var eventsNonLinear:VASTTrackingProxyElement = new VAST2TrackingProxyElement(trackingEvents,null, impressionsNonLinear, cacheBuster, clickThru);
						var vastMediaElementNonLinear:MediaElement = eventsNonLinear;
					
						mediaElements.push(vastMediaElementNonLinear);
						
					}
				}
				
			}
			
			if(vastDocument.companionArray != null && vastDocument.companionArray.length > 0)
			{
				for each(var companionAd:VAST2CompanionElement in vastDocument.companionArray)
				{	
					CONFIG::LOGGING
					{
						logger.debug("[VAST] Companion ad detected" + companionAd.staticResource);
					}
					var companionElement:CompanionElement = new CompanionElement(companionAd);
					companionElement.scriptPath = companionAd.staticResource;
					mediaElements.push(companionElement);
				}
			}
			
			return mediaElements;
		}
	
		private function get isLinear() : Boolean
		{
			return (vastDocument.adPlacement == VAST2Translator.PLACEMENT_LINEAR);
		}
		private function get isNonLinear() : Boolean
		{
			return (vastDocument.adPlacement == VAST2Translator.PLACEMENT_NONLINEAR);
		}
		
		private var mediaFactory:MediaFactory;	
		private var clickThru:String;
		private var httpLoader:HTTPLoader;
		private var vastDocument:VAST2Translator;
		private var mediaFileResolver:IVAST2MediaFileResolver;
		private var vastTranslator:VAST2Translator;
		private var cacheBuster:CacheBuster;
		private var _adPlacement:String;
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.vast.media.VAST2MediaGenerator");
		}
	}
}
