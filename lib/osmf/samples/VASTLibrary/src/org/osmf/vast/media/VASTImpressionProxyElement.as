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
	import org.osmf.elements.beaconClasses.Beacon;
	import org.osmf.events.BufferEvent;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.BufferTrait;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.TraitEventDispatcher;
	import org.osmf.utils.HTTPLoader;
	import org.osmf.utils.OSMFStrings;
	import org.osmf.vast.model.VASTUrl;
	
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
	public class VASTImpressionProxyElement extends ProxyElement
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
		public function VASTImpressionProxyElement(urls:Vector.<VASTUrl>, httpLoader:HTTPLoader=null, wrappedElement:MediaElement=null)
		{
			this.urls = urls;
			this.httpLoader = httpLoader;
			
			impressionsRecorded = false;
			waitForBufferingExit = false;
			
			super(wrappedElement);
			
			if (urls == null)
			{
				throw new ArgumentError(OSMFStrings.INVALID_PARAM);
			}
		}
		
		// Overrides
		//
		
		override public function set proxiedElement(value:MediaElement):void
		{
			if (value != proxiedElement)
			{
				if (dispatcher != null)
				{
					dispatcher.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, processLoadStateChange);
					dispatcher.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, processPlayStateChange);
					dispatcher.removeEventListener(BufferEvent.BUFFERING_CHANGE, processBufferingChange);
					dispatcher.media = null;
					dispatcher = null;
				}
	
				if (value != null)
				{
					dispatcher = new TraitEventDispatcher();
					dispatcher.media = value;
					dispatcher.addEventListener(LoadEvent.LOAD_STATE_CHANGE, processLoadStateChange);
					dispatcher.addEventListener(PlayEvent.PLAY_STATE_CHANGE, processPlayStateChange);
					dispatcher.addEventListener(BufferEvent.BUFFERING_CHANGE, processBufferingChange);
				}
			}

			super.proxiedElement = value;
		}
		
		/**
		 * @private
		 */
		private function processLoadStateChange(event:LoadEvent):void
		{
			if (event.loadState == LoadState.READY)
			{
				// Reset our internal flags so that we can record a new
				// impression.
				impressionsRecorded = false;
				waitForBufferingExit = false;
			}
		}
		
		/**
		 * @private
		 */
		private function processPlayStateChange(event:PlayEvent):void
		{
			if (event.playState == PlayState.PLAYING && !impressionsRecorded)
			{
				// Only record the impressions if we're not buffering.
				var bufferTrait:BufferTrait = getTrait(MediaTraitType.BUFFER) as BufferTrait;
				if (	bufferTrait == null
					||  ( 	bufferTrait.buffering == false 
						&& 	bufferTrait.bufferLength >= bufferTrait.bufferTime
						)
				   )
				{
					recordImpressions();
				}
				else
				{
					// Wait until we exit the buffering state.
					waitForBufferingExit = true;
				}
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
				)
			{
				recordImpressions();
			}
		}

		// Internals
		//
		
		private function recordImpressions():void
		{
			impressionsRecorded = true;
			
			for each (var vastUrl:VASTUrl in urls)
			{
				if (vastUrl.url != null)
				{
					var beacon:Beacon = new Beacon(vastUrl.url, httpLoader);
					beacon.ping();
				}
			}
		}

		private var dispatcher:TraitEventDispatcher;
		private var urls:Vector.<VASTUrl>;
		private var httpLoader:HTTPLoader;
		private var impressionsRecorded:Boolean;
		private var waitForBufferingExit:Boolean;
	}
}