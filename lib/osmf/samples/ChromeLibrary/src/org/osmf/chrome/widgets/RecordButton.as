/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
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
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/

package org.osmf.chrome.widgets
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.osmf.events.DVREvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.net.NetStreamLoadTrait;
	import org.osmf.traits.DVRTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;
	
	public class RecordButton extends ButtonWidget
	{
		// Overrides
		//
		
		override protected function processRequiredTraitsAvailable(element:MediaElement):void
		{
			dvrTrait = element.getTrait(MediaTraitType.DVR) as DVRTrait;
			dvrTrait.addEventListener(DVREvent.IS_RECORDING_CHANGE, visibilityDeterminingEventHandler);
			
			timeTrait = element.getTrait(MediaTraitType.TIME) as TimeTrait;
			timeTrait.addEventListener(TimeEvent.DURATION_CHANGE, visibilityDeterminingEventHandler);
			
			visibilityDeterminingEventHandler();
		}
		
		override protected function processRequiredTraitsUnavailable(element:MediaElement):void
		{
			if (dvrTrait)
			{
				dvrTrait.removeEventListener(DVREvent.IS_RECORDING_CHANGE, visibilityDeterminingEventHandler);
				dvrTrait = null;
			}
			
			if (timeTrait)
			{
				timeTrait.removeEventListener(TimeEvent.DURATION_CHANGE, visibilityDeterminingEventHandler);
				timeTrait = null;
			}
			
			visibilityDeterminingEventHandler();
		}
		
		override protected function get requiredTraits():Vector.<String>
		{
			return _requiredTraits;
		}
		
		override protected function onMouseClick(event:MouseEvent):void
		{
			var seekable:SeekTrait = media.getTrait(MediaTraitType.SEEK) as SeekTrait;
			if (seekable && dvrTrait)
			{
				var bufferTime:Number = getBufferTime();
				var livePosition:Number = Math.max(0, timeTrait.duration - bufferTime - 2); 
				if (seekable.canSeekTo(livePosition))
				{
					// While seeking, disable the button:
					enabled = false;
					seekable.addEventListener
						( SeekEvent.SEEKING_CHANGE
						, function(event:SeekEvent):void
							{
								if (event.seeking == false)
								{
									// Re-enable the button:
									removeEventListener(event.type, arguments.callee);
									enabled = true;
								}
							}
						);
						
					// Seek to the live position:
					seekable.seek(livePosition);
				}
			}
		}
		
		// Internals
		//
		
		private function visibilityDeterminingEventHandler(event:Event = null):void
		{
			visible
				=	dvrTrait != null
				&&	dvrTrait.isRecording == true
				&&	timeTrait
				&&	timeTrait.currentTime < Math.max(0, timeTrait.duration - getBufferTime() - 5);
			
			enabled = media && media.hasTrait(MediaTraitType.SEEK);
		}
		
		private function getBufferTime():Number
		{
			var result:Number = 0;
			
			var loadable:NetStreamLoadTrait = media.getTrait(MediaTraitType.LOAD) as NetStreamLoadTrait;
			if (loadable)
			{
				result = loadable.netStream.bufferTime;
			}
			
			return result;
		}
		
		private var dvrTrait:DVRTrait;
		private var timeTrait:TimeTrait;
		
		/* static */
		private static const _requiredTraits:Vector.<String> = new Vector.<String>;
		_requiredTraits[0] = MediaTraitType.DVR;
		_requiredTraits[1] = MediaTraitType.TIME;
	}
}