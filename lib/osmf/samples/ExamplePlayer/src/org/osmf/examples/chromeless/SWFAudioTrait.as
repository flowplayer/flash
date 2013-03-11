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
package org.osmf.examples.chromeless
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import org.osmf.traits.AudioTrait;
	
	internal class SWFAudioTrait extends AudioTrait
	{
		public function SWFAudioTrait(swfRoot:DisplayObject)
		{
			this.swfRoot = swfRoot;

			// Keep in sync with the state of the SWF.
			Object(swfRoot).videoPlayer.addEventListener("isMutedChange", onMutedChange);
			Object(swfRoot).videoPlayer.addEventListener("volumeChange", onVolumeChange);
			onMutedChange(null);
			onVolumeChange(null);
		}

		override protected function volumeChangeStart(newVolume:Number):void
		{
			Object(swfRoot).videoPlayer.setVolume(newVolume);
		}

		override protected function mutedChangeStart(newMuted:Boolean):void
		{
			if (Object(swfRoot).videoPlayer.isMuted != newMuted)
			{
				Object(swfRoot).videoPlayer.toggleMute();
			}
		}

		override protected function panChangeStart(newPan:Number):void
		{
			// No op.	
		}
		
		private function onMutedChange(event:Event):void
		{
			// Stay in sync with the state of the SWF.
			if (Object(swfRoot).videoPlayer.isMuted != muted)
			{
				muted = !muted;
			}
		}

		private function onVolumeChange(event:Event):void
		{
			// Stay in sync with the state of the SWF.
			if (Object(swfRoot).videoPlayer.getVolume() != volume)
			{
				volume = Object(swfRoot).videoPlayer.getVolume();
			}
		}

		private var swfRoot:DisplayObject;
	}
}