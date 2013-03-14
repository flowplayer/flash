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
*  The Initial Developer of the   Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*
*  Contributor(s): Eyewonder, LLC
*  
*****************************************************/
package org.osmf.vast.loader
{
	import __AS3__.vec.Vector;
	
	import flash.events.EventDispatcher;
	
	import org.osmf.events.LoadEvent;
	import org.osmf.media.URLResource;
	import org.osmf.traits.LoadState;
	import org.osmf.utils.HTTPLoader;
	import org.osmf.vast.model.VASTAd;
	import org.osmf.vast.model.VASTDocument;
	import org.osmf.vast.model.VASTInlineAd;
	import org.osmf.vast.model.VASTTrackingEvent;
	import org.osmf.vast.model.VASTUrl;
	import org.osmf.vast.model.VASTWrapperAd;
	import org.osmf.vast.parser.VAST1Parser;

	CONFIG::LOGGING
	{
	import org.osmf.logging.Logger;
	import org.osmf.logging.Log;
	}

	[Event("processed")]
	[Event("processingFailed")]
	
	internal class VAST1DocumentProcessor extends EventDispatcher
	{
		public function VAST1DocumentProcessor(maxNumWrapperRedirects:Number, httpLoader:HTTPLoader)
		{
			super();
			
			this.maxNumWrapperRedirects = maxNumWrapperRedirects;
			this.httpLoader = httpLoader;
		}

		public function processVASTDocument(documentContents:String):void
		{
			var processingFailed:Boolean = false;
			
			var vastDocument:VASTDocument = null;
			
			var documentXML:XML = null;
			try
			{
				documentXML = new XML(documentContents);
			}
			catch (error:TypeError)
			{
				processingFailed = true;
			}
			
			if (documentXML != null)
			{
				var parser:VAST1Parser = new VAST1Parser();
				vastDocument = parser.parse(documentXML);
				if (vastDocument != null)
				{
					// If the VAST document has a wrapper, we may need to load it.
					var numWrappers:int = getNumVASTWrappers(vastDocument); 
	
					CONFIG::LOGGING
					{
						logger.debug("[VAST] Document has " + numWrappers + " wrappers");
					}
	
					if (numWrappers > 0)
					{
						loadVASTWrappers(vastDocument);
					}
					else
					{
						dispatchEvent(new VASTDocumentProcessedEvent(VASTDocumentProcessedEvent.PROCESSED, vastDocument));
					}
				}
				else
				{
					processingFailed = true;
				}
			}
			
			if (processingFailed)
			{
				CONFIG::LOGGING
				{
					logger.debug("[VAST] Processing failed for document with contents: " + documentContents);
				}
					
				dispatchEvent(new VASTDocumentProcessedEvent(VASTDocumentProcessedEvent.PROCESSING_FAILED));
			}
		}
		
		private function getNumVASTWrappers(vastDocument:VASTDocument):int
		{
			var count:int = 0;
			
			var ads:Vector.<VASTAd> = vastDocument.ads;
			for each (var ad:VASTAd in ads)
			{
				if (needLoadVASTWrapper(ad))
				{
					count++;
				}
			}
			
			return count;
		}

		private function needLoadVASTWrapper(ad:VASTAd):Boolean
		{
			return ad.wrapperAd != null
				&&	(  maxNumWrapperRedirects == -1
					|| maxNumWrapperRedirects > 0
					);
		}
		
		private function loadVASTWrappers(vastDocument:VASTDocument):void
		{
			var numLoadsToComplete:int = getNumVASTWrappers(vastDocument);
			var noFailedLoads:Boolean = true;
			
			var ads:Vector.<VASTAd> = vastDocument.ads;
			for (var i:int = 0; i < ads.length; i++)
			{
				var ad:VASTAd = ads[i];
				
				CONFIG::LOGGING
				{
					logger.debug("[VAST] Inspecting ad " + ad.id);
				}
				
				if (needLoadVASTWrapper(ad))
				{
					loadVASTWrapper(ad, completionCallback);
				}
			}
			
			function completionCallback(success:Boolean):void
			{
				numLoadsToComplete--;
				
				if (noFailedLoads)
				{
					if (success == false)
					{
						noFailedLoads = false;

						// Signal that the processing failed on our first failure.
						dispatchEvent(new VASTDocumentProcessedEvent(VASTDocumentProcessedEvent.PROCESSING_FAILED));						
					}
					else
					{
						CONFIG::LOGGING
						{
							logger.debug("[VAST] " + numLoadsToComplete + " more wrapper ads to load");
						}

						// Wait until the last load completes before signaling
						// success.
						if (numLoadsToComplete == 0)
						{
							dispatchEvent(new VASTDocumentProcessedEvent(VASTDocumentProcessedEvent.PROCESSED, vastDocument));
						}
					}
				}
			}
		}
		
		private function loadVASTWrapper(ad:VASTAd, completionCallback:Function):void
		{
			CONFIG::LOGGING
			{
				logger.debug("[VAST] Ad " + ad.id + " is a wrapper, loading...");
			}
			
			// Use another VASTLoader to load the wrapper, decrementing
			// our redirect count so that we don't redirect too many times.
			var wrapperLoader:VASTLoader
				= new VASTLoader
					( Math.max(-1, maxNumWrapperRedirects-1)
					, httpLoader
					)
				;
			
			var wrapperResource:URLResource
				= new URLResource(ad.wrapperAd.vastAdTagURL);
					
			var wrapperLoadTrait:VASTLoadTrait = new VASTLoadTrait(wrapperLoader, wrapperResource);
			wrapperLoadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onWrapperLoadStateChange);
			wrapperLoadTrait.load();
			
			function onWrapperLoadStateChange(event:LoadEvent):void
			{
				if (event.loadState == LoadState.READY)
				{
					wrapperLoadTrait.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onWrapperLoadStateChange);
					
					// Merge the wrapper's ad with the original ad.
 					var success:Boolean = mergeAds(ad, wrapperLoadTrait.vastDocument as VASTDocument);
						
					CONFIG::LOGGING
					{
						logger.debug("[VAST] Wrapper ad " + ad.id + " loaded");
						logger.debug("[VAST] Merging wrapper ad " + ad.id + " with nested document at " + URLResource(wrapperResource).url);
						logger.debug("[VAST] Merge " + (success ? "succeeded" : "failed"));
					} 

					completionCallback(success);
				}
				else if (event.loadState == LoadState.LOAD_ERROR)
				{
					wrapperLoadTrait.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onWrapperLoadStateChange);

					CONFIG::LOGGING
					{
						logger.debug("[VAST] Wrapper ad " + ad.id + " load failed");
					}
					
					completionCallback(false);
				}
			}
		}
		
		private function mergeAds(rootAd:VASTAd, nestedDocument:VASTDocument):Boolean
		{
			var success:Boolean = false;
			
			// The goal here is to have the rootAd expose the inlineAd from the
			// nested document, rather than its own wrappedAd.  Doing so is
			// straightforward, in that we can just copy the inline ad from
			// the nested document to the rootAd.  Note that it's possible
			// that the nested document has more than one inlineAd.  If that
			// happens, we just take the first one.
			for each (var nestedAd:VASTAd in nestedDocument.ads)
			{ 
				// Not finding an inline ad is cause for failure.
				if (nestedAd.inlineAd != null)
				{
					rootAd.inlineAd = nestedAd.inlineAd;
					success = true;
					break;
				}
			}
			
			// Now that we've merged, we need to copy the relevant properties
			// from the rootAd's wrapperAd into its new inlineAd.
			//
			
			var wrapperAd:VASTWrapperAd = rootAd.wrapperAd;
			var inlineAd:VASTInlineAd = rootAd.inlineAd;
			
			// Copy the impressions over.
			for each (var impression:VASTUrl in wrapperAd.impressions)
			{
				inlineAd.addImpression(impression);
			}
			
			// Copy the tracking events over.
			for each (var trackingEvent:VASTTrackingEvent in wrapperAd.trackingEvents)
			{
				var inlineAdTrackingEvent:VASTTrackingEvent = inlineAd.getTrackingEventByType(trackingEvent.type);
				if (inlineAdTrackingEvent != null)
				{
					inlineAdTrackingEvent.urls = inlineAdTrackingEvent.urls.concat(trackingEvent.urls);
				}
				else
				{
					inlineAd.addTrackingEvent(trackingEvent);
				}
			}
			
			// TODO: Merge companion ads, nonlinear ads, and video clicks.
			// Note that the spec is ambiguous about merging impressions from
			// companion and non-linear ads.  Should the impression be matched
			// by ID?  Should each impression be copied to each ad?  Not sure.
			 
			// Now, we can remove the rootAd's wrapperAd, since the inlineAd
			// now contains the merged details of both the original wrapperAd
			// and the nested inlineAd.
			rootAd.wrapperAd = null;
			
			return success;
		}
		
		private var maxNumWrapperRedirects:Number;
		private var httpLoader:HTTPLoader;

		CONFIG::LOGGING
		private static const logger:Logger = Log.getLogger("org.osmf.vast.loader.VASTDocumentProcessor");
	}
}
