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
package org.osmf.examples.posterframe
{
	import org.osmf.elements.ProxyElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.net.NetLoader;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayTrait;

	/**
	 * An RTMPPosterFrameElement is a proxy that wraps up a VideoElement that only
	 * shows a single frame.
	 **/
	public class RTMPPosterFrameElement extends ProxyElement
	{
		public function RTMPPosterFrameElement(resource:StreamingURLResource, posterFrameTime:Number, netLoader:NetLoader)
		{
			super();

			// Treat this as a zero-length subclip.
			resource.clipStartTime = posterFrameTime;
			resource.clipEndTime = posterFrameTime;
			
			proxiedElement = new VideoElement(resource, netLoader);
		}
		
		/**
		 * @private
		 **/
		override protected function setupTraits():void
		{
			super.setupTraits();
			
			// Block all traits other than LOAD (so we can load the base
			// VideoElement), DISPLAY_OBJECT (so we can display its view),
			// and PLAY (which we'll override).  This makes this element
			// the functional equivalent of a playable ImageElement.
			var traitsToBlock:Vector.<String> = new Vector.<String>();
			traitsToBlock.push(MediaTraitType.AUDIO);
			traitsToBlock.push(MediaTraitType.BUFFER);
			traitsToBlock.push(MediaTraitType.DRM);
			traitsToBlock.push(MediaTraitType.DVR);
			traitsToBlock.push(MediaTraitType.DYNAMIC_STREAM);
			traitsToBlock.push(MediaTraitType.SEEK);
			traitsToBlock.push(MediaTraitType.TIME);
			super.blockedTraits = traitsToBlock;
			
			// To ensure that the user can complete playback of this item
			// (and can't interact with the VideoElement), we add a dummy
			// PlayTrait trait.
			addTrait(MediaTraitType.PLAY, new PosterFramePlayTrait());
		}
		
		/**
		 * @private
		 **/
		override public function set proxiedElement(value:MediaElement):void
		{
			super.proxiedElement = value;
			
			if (value != null)
			{
				if (value.hasTrait(MediaTraitType.PLAY))
				{
					processPlayTrait();
				}
				else
				{
					// Wait for the PlayTrait to be added.
					value.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
				}
			}
		}
		
		private function onTraitAdd(event:MediaElementEvent):void
		{
			if (event.traitType == MediaTraitType.PLAY)
			{
				proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
				
				processPlayTrait();
			}
		}
		
		private function processPlayTrait():void
		{
			// Calling play() on the proxied VideoElement's trait will
			// cause the poster frame to be displayed.  But because the
			// base play trait is overridden, no events are dispatched
			// to the client.
			var playTrait:PlayTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
			playTrait.play();
		}
	}
}