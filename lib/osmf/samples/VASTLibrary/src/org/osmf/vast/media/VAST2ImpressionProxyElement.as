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
*  Contributor(s): Eyewonder, LLC
*  
*****************************************************/
package org.osmf.vast.media
{
	import __AS3__.vec.Vector;
	
	import org.osmf.elements.ProxyElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.elements.beaconClasses.Beacon;
	import org.osmf.events.BufferEvent;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MetadataEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.BufferTrait;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.TraitEventDispatcher;
	import org.osmf.utils.HTTPLoader;
	import org.osmf.utils.OSMFStrings;
	import org.osmf.vast.model.VASTUrl;
	import org.osmf.vpaid.elements.VPAIDElement;
	import org.osmf.vpaid.metadata.VPAIDMetadata;
	
	CONFIG::LOGGING
	{
	import org.osmf.logging.Logger;
	import org.osmf.logging.Log;
	}
	
	/**
	 * A VASTImpressionProxyElement is a ProxyElement that wraps up another
	 * MediaElement, and which records one or more impressions according to the
	 * IAB's guidelines for impression tracking.
	 * 
	 * According to the IAB, an impression should only be recorded after
	 * the media has initially exited the buffering state.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class VAST2ImpressionProxyElement extends VASTImpressionProxyElement
	{
		/**
		 * Constructor.
		 * 
		 * @param urls The VASTUrls to request in order to record the impressions.
		 * @param httpLoader The HTTPLoader to use to ping the beacon.  If null,
		 * then a default HTTPLoader will be used.
		 * @param wrappedElement The MediaElement to wrap.
		 * 
		 * @throws ArgumentError If urls is null.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function VAST2ImpressionProxyElement(urls:Vector.<VASTUrl>, httpLoader:HTTPLoader=null, wrappedElement:MediaElement=null, cacheBust:CacheBuster = null)
		{ 
			super(urls);
			//TODO: Combine VASTImpressionProxyElement with VASTTrackingProxyElement
			this.urls = urls;
			this.httpLoader = httpLoader;
				
			if (cacheBust == null) // Cachebuster should be shared across all events for the same ad view due to synchronization/correlation that happens on some ad servers
				cacheBuster = new CacheBuster()
			else
				cacheBuster = cacheBust;
						
			impressionsRecorded = false;
			waitForBufferingExit = false;
			
			proxiedElement = wrappedElement;
			
			dispatcher = new TraitEventDispatcher();
			dispatcher.media = wrappedElement;
			
			dispatcher.addEventListener(LoadEvent.LOAD_STATE_CHANGE, processLoadStateChange);
			dispatcher.addEventListener(PlayEvent.PLAY_STATE_CHANGE, processPlayStateChange);
			dispatcher.addEventListener(BufferEvent.BUFFERING_CHANGE, processBufferingChange);
			dispatcher.media.addEventListener(MediaErrorEvent.MEDIA_ERROR, processMediaError);
			
			var loadTrait:LoadTrait = proxiedElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
			loadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
			
			if(proxiedElement is VPAIDElement)
			{
				var vpaidElement:VPAIDElement = proxiedElement as VPAIDElement;
				var vpaidMetadata:VPAIDMetadata = vpaidElement.getMetadata(vpaidElement.metadataNamespaceURLs[0]) as VPAIDMetadata;
				vpaidMetadata.addEventListener(MetadataEvent.VALUE_ADD, onMetadataValueAdded);	
			}
			
			if (urls == null)
			{
				throw new ArgumentError(OSMFStrings.INVALID_PARAM);
			}
		}
		
		// Overrides
		//
		
		/**
		 * @private
		 */
		 //EyeWonder addition - sometimes the play trait event fires before the load ready event is fired
		//We need check to see if the play trait is playing. If so start tracking.	
		private function processLoadStateChange(event:LoadEvent):void
		{
			
			if (event.loadState == LoadState.READY)
			{
				
				// Reset our internal flags so that we can record a new
				// impression.
				waitForBufferingExit = false;
				var playTrait:PlayTrait = getTrait(MediaTraitType.PLAY) as PlayTrait;
				if(playTrait.playState == PlayState.PLAYING)
				{
					onMediaElementPlay();
				}
			}
		}
		
		/**
		 * @private
		 */
		private function processPlayStateChange(event:PlayEvent):void
		{
			if (event.playState == PlayState.PLAYING && !impressionsRecorded)
			{
				//EW addition see processLoadStateChange function for details.
				onMediaElementPlay();
			}
		}
		
		private function processMediaError(event:MediaErrorEvent):void
		{
			//trace("Don't fire impressions. Media failed to load.");
			fireImpression = false;
		}
		
		private function onMediaElementPlay():void
		{
			// Only record the impressions if we're not buffering.
			var bufferTrait:BufferTrait = getTrait(MediaTraitType.BUFFER) as BufferTrait;
			if (	bufferTrait == null
				||  ( 	bufferTrait.buffering == false 
					&& 	bufferTrait.bufferLength >= bufferTrait.bufferTime
					&& fireImpression
					)
			   )
			{
				VASTImpression();
			}
			else
			{
				// Wait until we exit the buffering state.
				waitForBufferingExit = true;
			}			
		}
		
		/**
		 * @private
		 */
		private function processBufferingChange(event:BufferEvent):void
		{
			if (	event.buffering == false
				&&  impressionsRecorded == false
				&&  waitForBufferingExit 
				&& fireImpression
				)
			{
				VASTImpression();
			}
		}
		
		private function onLoadStateChange(e:LoadEvent):void
		{	
			//trace("Current Bites of data loaded: " + e.bytes);
			//If VAST and load error fire off load tracker      proxiedElement is VideoElement &&
			if( e.loadState == LoadState.LOAD_ERROR)
			{	
				fireImpression = false;
			}
		}
		
		private function onMetadataValueAdded(e:MetadataEvent):void
		{
			//TODO: Combine VASTImpressionProxyElement with VASTTrackingProxyElement
			switch(e.key) 
			{								
				case VPAIDMetadata.AD_IMPRESSION:
					VPAIDImpression();
				break;
			}
		}

		// Internals
		//
		
		private function VPAIDImpression() : void
		{
			if (proxiedElement is VPAIDElement)
				recordImpressionsHelper();
		}
		
		private function VASTImpression(): void
		{
			//trace("Fire off the VAST Impressions!");
			if (proxiedElement is VideoElement)
				recordImpressionsHelper();
		}
		
		private function recordImpressionsHelper():void
		{
			if (impressionsRecorded == true) return;
			impressionsRecorded = true;
			
			for each (var vastUrl:VASTUrl in urls)
			{
				if (vastUrl.url != null)
				{
					var beacon:Beacon = new Beacon(cacheBuster.cacheBustURL(vastUrl.url), httpLoader);
					beacon.ping();
				}
			}
		}

		private var fireImpression:Boolean = true;
		private var dispatcher:TraitEventDispatcher;
		private var urls:Vector.<VASTUrl>;
		private var httpLoader:HTTPLoader;
		private var impressionsRecorded:Boolean;
		private var waitForBufferingExit:Boolean;
		private var cacheBuster:CacheBuster;
	}
}