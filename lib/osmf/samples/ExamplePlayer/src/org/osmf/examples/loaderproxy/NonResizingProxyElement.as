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
package org.osmf.examples.loaderproxy
{
	import org.osmf.elements.ProxyElement;
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitType;
	
	/**
	 * ProxyElement which accepts the first mediaSizeChange event, but prevents
	 * any subsequent ones from being propagated up.  Can be useful as a workaround
	 * for media that has improperly-specified metadata.
	 **/
	public class NonResizingProxyElement extends ProxyElement
	{
		/**
		 * Constructor.
		 **/
		public function NonResizingProxyElement(proxiedElement:MediaElement)
		{
			super(proxiedElement);
		}
		
		/**
		 * @private
		 **/
		override public function set proxiedElement(value:MediaElement):void
		{ 
			super.proxiedElement = value;
			
			initialSizeSet = false;
			
			if (value != null)
			{
				value.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
				value.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);

				processDisplayObjectTrait(value);
			}
		}
		
		// Internals
		//
		
		private function onTraitAdd(event:MediaElementEvent):void
		{
			if (event.traitType == MediaTraitType.DISPLAY_OBJECT)
			{
				processDisplayObjectTrait(event.target as MediaElement);
			}
		}

		private function onTraitRemove(event:MediaElementEvent):void
		{
			if (event.traitType == MediaTraitType.DISPLAY_OBJECT)
			{
				processDisplayObjectTrait(event.target as MediaElement, true);
			}
		}
		
		private function processDisplayObjectTrait(media:MediaElement, remove:Boolean=false):void
		{
			var displayObjectTrait:DisplayObjectTrait = media.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
			if (displayObjectTrait != null)
			{
				if (remove)
				{
					displayObjectTrait.removeEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onMediaSizeChange);
				}
				else
				{
					// Add the listener with a high priority, so that we can
					// process the event first.
					displayObjectTrait.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onMediaSizeChange, false, int.MAX_VALUE);
				}
			}
		}
		
		private function onMediaSizeChange(event:DisplayObjectEvent):void
		{
			if (initialSizeSet == false && event.newWidth > 0)
			{
				// This is the initial size, let it propagate.
				initialSizeSet = true;
			}
			else
			{
				// Initial size already set, prevent this event from propagating.
				event.stopImmediatePropagation();
			}
		}
		
		private var initialSizeSet:Boolean;
	}
}