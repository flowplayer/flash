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
	
	import flash.events.Event;
	
	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.DynamicStreamTrait;
	import org.osmf.traits.MediaTraitType;

	
	public class QualityLabel extends LabelWidget
	{
		// Overrides
		//
		
		override protected function get requiredTraits():Vector.<String>
		{
			return _requiredTraits;
		}
		
		override protected function processMediaElementChange(oldElement:MediaElement):void
		{
			visibilityDeterminingEventHandler();
		}
		
		override protected function processRequiredTraitsAvailable(element:MediaElement):void
		{
			dynamicStream = element.getTrait(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait;
			dynamicStream.addEventListener(DynamicStreamEvent.SWITCHING_CHANGE, visibilityDeterminingEventHandler);
			dynamicStream.addEventListener(DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE, visibilityDeterminingEventHandler);
			
			visibilityDeterminingEventHandler();
		}
		
		override protected function processRequiredTraitsUnavailable(element:MediaElement):void
		{
			if (dynamicStream)
			{
				dynamicStream.removeEventListener(DynamicStreamEvent.SWITCHING_CHANGE, visibilityDeterminingEventHandler);
				dynamicStream.removeEventListener(DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE, visibilityDeterminingEventHandler);
				dynamicStream = null;
			}
			
			visibilityDeterminingEventHandler();
		}
		
		// Internals
		//
		
		private function visibilityDeterminingEventHandler(event:Event = null):void
		{
			enabled = dynamicStream != null;
			
			visible
				=	media != null 
				&&	enabled == true
				
			text = dynamicStream 
				? dynamicStream.getBitrateForIndex(dynamicStream.currentIndex).toString() + " kbps"
				: "";
		}
		
		private var dynamicStream:DynamicStreamTrait;
		
		/* static */
		private static const _requiredTraits:Vector.<String> = new Vector.<String>;
		_requiredTraits[0] = MediaTraitType.DYNAMIC_STREAM;
	}
}