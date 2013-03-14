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
	
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.SeekTrait;
	
	public class StopButton extends PlayableButton
	{
		// Overrides
		//
		
		override protected function onMouseClick(event:MouseEvent):void
		{
			var playable:PlayTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
			playable.stop();
			
			// On stop being invoked, rewind manually. NOTE: this is a work-around
			// for the PlayTrait currently not doing so automatically. See bug report
			// FM-350.
			var seekable:SeekTrait = media.getTrait(MediaTraitType.SEEK) as SeekTrait;
			if (seekable && seekable.canSeekTo(0))
			{
				seekable.seek(0);
			}
		}
		
		override protected function visibilityDeterminingEventHandler(event:Event = null):void
		{
			visible = playable && playable.playState != PlayState.STOPPED;
		}
	}
}