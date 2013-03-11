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
	
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	
	internal class SWFPlayTrait extends PlayTrait
	{
		public function SWFPlayTrait(swfRoot:DisplayObject)
		{
			super();
			
			this.swfRoot = swfRoot;
			
			// Keep in sync with the state of the SWF.
			Object(swfRoot).videoPlayer.addEventListener("isPlayingChange", onPlayingChange);
			onPlayingChange(null);
		}

		override protected function playStateChangeStart(playState:String):void
		{
			if (playState == PlayState.PLAYING && Object(swfRoot).videoPlayer.isPlaying == false)
			{
				Object(swfRoot).videoPlayer.playVideo();
			}
			else if (playState == PlayState.PAUSED && Object(swfRoot).videoPlayer.isPlaying)
			{
				Object(swfRoot).videoPlayer.pauseVideo();
			}
		}
		
		private function onPlayingChange(event:Event):void
		{
			// Stay in sync with the state of the SWF.
			if (Object(swfRoot).videoPlayer.isPlaying)
			{
				play();
			}
			else
			{
				pause();
			}
		}
		
		private var swfRoot:DisplayObject;
	}
}