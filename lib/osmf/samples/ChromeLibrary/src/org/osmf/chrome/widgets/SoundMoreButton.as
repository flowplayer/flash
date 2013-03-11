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
	import __AS3__.vec.Vector;
	
	import flash.events.MouseEvent;
	
	import org.osmf.chrome.widgets.ButtonWidget;
	import org.osmf.events.AudioEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.AudioTrait;
	import org.osmf.traits.MediaTraitType;
	
	public class SoundMoreButton extends ButtonWidget
	{
		// Overrides
		//
		
		override protected function get requiredTraits():Vector.<String>
		{
			return _requiredTraits;
		}
		
		override protected function processRequiredTraitsAvailable(element:MediaElement):void
		{
			visible = true;
			audible = element.getTrait(MediaTraitType.AUDIO) as AudioTrait;
			if (audible)
			{
				audible.addEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
			}
			onVolumeChange();
		}
		
		override protected function processRequiredTraitsUnavailable(element:MediaElement):void
		{
			visible = false;
			if (audible)
			{
				audible.removeEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
				audible = null;
			}
		}
		
		override protected function onMouseClick(event:MouseEvent):void
		{
			if (audible)
			{
				audible.volume = Math.min(1, audible.volume + 0.2);
			} 
		}
		
		// Internals
		//
		
		protected var audible:AudioTrait;
		
		protected function onVolumeChange(event:AudioEvent = null):void
		{
			enabled = audible ? audible.volume != 1 : false;
		}
		
		/* static */
		private static const _requiredTraits:Vector.<String> = new Vector.<String>;
		_requiredTraits[0] = MediaTraitType.AUDIO;
	}
}
