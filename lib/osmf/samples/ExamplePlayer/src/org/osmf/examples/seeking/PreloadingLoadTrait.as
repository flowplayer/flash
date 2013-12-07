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
package org.osmf.examples.seeking
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.examples.loaderproxy.AsynchLoadingProxyLoadTrait;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.AudioTrait;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.SeekTrait;
	
	/**
	 * A LoadTrait which maps the "load" operation to the preloading of
	 * a different MediaElement.
	 * 
	 * The preload operation is defined as the load of the MediaElement,
	 * followed by a play and pause in succession.  (The play/pause was
	 * added because RTMP streams need to be played before they're seekable.)
	 **/
	public class PreloadingLoadTrait extends AsynchLoadingProxyLoadTrait
	{
		/**
		 * Constructor.
		 **/
		public function PreloadingLoadTrait(proxiedElement:MediaElement)
		{
			super(proxiedElement.getTrait(MediaTraitType.LOAD) as LoadTrait);
			
			this.proxiedElement = proxiedElement;
			
			load();
		}
		
		/**
		 * @private
		 **/
		override protected function doCustomLoadLogic(eventToDispatch:Event):void
		{
			var playTrait:PlayTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
			if (playTrait != null)
			{
				var audioTrait:AudioTrait = proxiedElement.getTrait(MediaTraitType.AUDIO) as AudioTrait;

				// Mute the video, but remember the mute state.
				var previousMuted:Boolean = audioTrait.muted;
				audioTrait.muted = true;
				
				// Begin playback.  But don't pause immediately, as doing so for MBR
				// streams seems to put them in a bad state.
				playTrait.play();
				
				var timer:Timer = new Timer(500, 1);
				timer.addEventListener(TimerEvent.TIMER, onTimer);
				timer.start();
				
				function onTimer(event:TimerEvent):void
				{
					timer.removeEventListener(TimerEvent.TIMER, onTimer);

					// Now pause the stream and seek back to the start.
					playTrait.pause();
					
					// It's possible that the media isn't seekable yet, in which
					// case we must wait until it is.
					var seekTrait:SeekTrait = proxiedElement.getTrait(MediaTraitType.SEEK) as SeekTrait;
					if (seekTrait != null)
					{
						// Seek back to the start.
						seekTrait.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
						seekTrait.seek(0);
						
						function onSeekingChange(event:SeekEvent):void
						{
							if (event.seeking == false)
							{
								seekTrait.removeEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
								
								// Restore the original muted state, and signal we're loaded.
								audioTrait.muted = previousMuted;
	
								calculatedLoadState = LoadState.READY;
								dispatchEvent(eventToDispatch);
							}
						}
					}
					else
					{
						proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
						
						function onTraitAdd(event:MediaElementEvent):void
						{
							if (event.traitType == MediaTraitType.SEEK)
							{
								proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);

								// Now we can seek back to the start.
								seekTrait = proxiedElement.getTrait(MediaTraitType.SEEK) as SeekTrait;
								seekTrait.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
								seekTrait.seek(0);
							}
						}
					}
				}
			}
			else
			{
				dispatchEvent(eventToDispatch);
			}
		}
		
		private var proxiedElement:MediaElement;
	}
}