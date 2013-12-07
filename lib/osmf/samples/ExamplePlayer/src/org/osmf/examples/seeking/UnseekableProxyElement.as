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
	import __AS3__.vec.Vector;
	
	import org.osmf.elements.ProxyElement;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.TraitEventDispatcher;
	
	/**
	 * A ProxyElement which can non-invasively prevent another
	 * MediaElement from being seekable.
	 **/
	public class UnseekableProxyElement extends ProxyElement
	{
		public function UnseekableProxyElement(proxiedElement:MediaElement)
		{
			super(proxiedElement);

			// Prevent seeking.
			enableSeeking(false);
			
			// We need to know when playback completes and when the media
			// is rewound.
			var traitEventDispatcher:TraitEventDispatcher = new TraitEventDispatcher();
			traitEventDispatcher.media = proxiedElement;
			traitEventDispatcher.addEventListener(TimeEvent.COMPLETE, onComplete);
			traitEventDispatcher.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
		}
		
		private function onComplete(event:TimeEvent):void
		{
			// When playback completes, unblock seeking (i.e. so that we
			// can be rewound).
			blockedTraits = new Vector.<String>();
		}
		
		private function onSeekingChange(event:SeekEvent):void
		{
			if (event.seeking == false && event.time == 0)
			{
				// Prevent seeking.
				enableSeeking(false);
			}
		}
		
		private function enableSeeking(enable:Boolean):void
		{
			var traitsToBlock:Vector.<String> = new Vector.<String>();
			
			if (enable == false)
			{
				traitsToBlock.push(MediaTraitType.SEEK);
			}
			
			blockedTraits = traitsToBlock;
		}
	}
}