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
package org.osmf.examples.loaderproxy
{
	import org.osmf.elements.ProxyElement;
	import org.osmf.events.LoadEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.URLResource;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	
	/**
	 * VideoProxyElement acts as a proxy for a VideoElement, and changes the
	 * URL of the video (to a hardcoded value) when the video is loaded.  The
	 * point of this example is to demonstrate how to decorate a MediaElement
	 * with a proxy that can do preflight operations.
	 **/
	public class VideoProxyElement extends ProxyElement
	{
		public function VideoProxyElement(wrappedElement:MediaElement)
		{
			super(wrappedElement);
		}

		override protected function setupTraits():void
		{
			super.setupTraits();
			
			// Override the LoadTrait trait with our own custom trait,
			// which simply replaces the URL.
			//
			
			loadTrait = new VideoProxyLoadTrait(new VideoProxyLoader(), resource);
			
			// Use a higher priority so that we can handle the event before
			// clients of the VideoProxyElement. This ensures we can expose
			// a consistent state to clients.
			loadTrait.addEventListener
				( LoadEvent.LOAD_STATE_CHANGE
				, onLoadStateChange
				, false, int.MAX_VALUE
				);
			
			addTrait(MediaTraitType.LOAD, loadTrait); 
		}
		
		private function onLoadStateChange(event:LoadEvent):void
		{
			//event.stopPropagation();
			
			if (event.loadState == LoadState.READY)
			{
				// Replace the resource with the new URL.
				proxiedElement.resource = new URLResource(loadTrait.url);
				
				// Our work is done, remove the custom LoadTrait.  This will
				// expose the base LoadTrait, which we can then use to do
				// the actual load.
				removeTrait(MediaTraitType.LOAD);
				
				// Tell the base trait to load (if it hasn't already).
				var baseLoadTrait:LoadTrait = getTrait(MediaTraitType.LOAD) as LoadTrait;
				if (baseLoadTrait.loadState != LoadState.READY)
				{
					baseLoadTrait.load();
				}
				
				loadTrait = null;
			}
		}
		
		private var loadTrait:VideoProxyLoadTrait;
	}
}