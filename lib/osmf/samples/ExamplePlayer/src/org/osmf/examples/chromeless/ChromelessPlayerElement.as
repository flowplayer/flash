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
	import flash.display.Loader;
	import flash.events.Event;
	
	import org.osmf.elements.SWFElement;
	import org.osmf.elements.SWFLoader;
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.media.URLResource;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitType;
	
	/**
	 * SWFElement which can control the SWF it wraps via a custom SWF API
	 * that maps to the traits API.
	 **/
	public class ChromelessPlayerElement extends SWFElement
	{
		public function ChromelessPlayerElement(resource:URLResource=null, loader:SWFLoader=null)
		{
			super(resource, loader)
		}
		
		override protected function processReadyState():void
		{
			super.processReadyState();
			
			// Flex SWFs load differently from pure AS3 SWFs.  For the former,
			// we need to wait until the applicationComplete event is
			// dispatched before we can access the SWF's API.
			if	(	swfRoot.hasOwnProperty("application")
				&&	Object(swfRoot).application == null
				)
			{
				swfRoot.addEventListener("applicationComplete", finishProcessReadyState, false, 0, true);
			}
			else
			{
				finishProcessReadyState();
			}
		}
		
		private function finishProcessReadyState(event:Event=null):void
		{
			// Flex SWFs expose their API through the root "application"
			// property, whereas pure AS3 SWFs expose their API directly.
			var theSwfRoot:DisplayObject = swfRoot.hasOwnProperty("application") ? Object(swfRoot).application : swfRoot;
			
			// Make sure the SWF has the expected API object.
			var isValidSWF:Boolean = theSwfRoot.hasOwnProperty("videoPlayer");
			if (isValidSWF)
			{
				addTrait(MediaTraitType.PLAY, new SWFPlayTrait(theSwfRoot));
				addTrait(MediaTraitType.AUDIO, new SWFAudioTrait(theSwfRoot));
				addTrait(MediaTraitType.TIME, new SWFTimeTrait(theSwfRoot));
				
				if	(	swfRoot.hasOwnProperty("application")
					&&	Object(swfRoot).application != null
					)
				{
					// Re-dispatch our dimensions:
					var displayObjectTrait:DisplayObjectTrait= getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
					displayObjectTrait.dispatchEvent
						( new DisplayObjectEvent
							( DisplayObjectEvent.MEDIA_SIZE_CHANGE
							, false
							, false
							, null
							, null
							, 0
							, 0
							, displayObjectTrait.mediaWidth
							, displayObjectTrait.mediaHeight
							)
						);
				}
			}
		}
		
		private function get swfRoot():DisplayObject
		{
			var displayObjectTrait:DisplayObjectTrait = getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
			return displayObjectTrait != null ? Loader(displayObjectTrait.displayObject).content : null;
		}
		
		override protected function processUnloadingState():void
		{
			super.processUnloadingState();
			
			removeTrait(MediaTraitType.PLAY);
			removeTrait(MediaTraitType.AUDIO);
			removeTrait(MediaTraitType.TIME);
		}
	}
}