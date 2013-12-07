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
*  Contributor(s): Akamai Technologies
* 
******************************************************/
package org.osmf.mast.loader
{
	import org.osmf.events.LoaderEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.mast.model.*;
	import org.osmf.mast.parser.MASTParser;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.utils.HTTPLoader;
	import org.osmf.utils.HTTPLoadTrait;
	CONFIG::LOGGING
	{
	import org.osmf.logging.*;		
	}
	
	/**
	 * Loader for the MASTProxyElement.
	 **/
	public class MASTLoader extends LoaderBase
	{
		/**
		 * Constructor.
		 * 
		 * @param The HTTPLoader to be used by this MASTLoader to retrieve
		 * the MAST document.  If null, then a new one will be created on
		 * demand.
		 */
		public function MASTLoader(httpLoader:HTTPLoader=null)
		{
			super();
			
			this.httpLoader = httpLoader != null ? httpLoader : new HTTPLoader();			
		}
		
		/**
		 * @private
		 **/
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			return httpLoader.canHandleResource(resource);
		}
		
		/**
		 * Loads a MAST document.
		 * <p>Updates the LoadTrait's <code>loadState</code> property to LOADING
		 * while loading and to READY upon completing a successful load and parse of the
		 * MAST document.</p>
		 * 
		 * @see org.osmf.traits.LoadState
		 * @param LoadTrait The LoadTrait to be loaded.
		 */
		override protected function executeLoad(loadTrait:LoadTrait):void
		{
			updateLoadTrait(loadTrait, LoadState.LOADING);			
						
			httpLoader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onHTTPLoaderStateChange);
			
			// Create a temporary LoadTrait for this purpose, so that our main
			// LoadTrait doesn't reflect any of the state changes from the
			// loading of the URL, and so that we can catch any errors.
			var httpLoadTrait:HTTPLoadTrait = new HTTPLoadTrait(httpLoader, loadTrait.resource);
						
			httpLoadTrait.addEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadError);
			
			httpLoader.load(httpLoadTrait);
			
			function onHTTPLoaderStateChange(event:LoaderEvent):void
			{
				if (event.newState == LoadState.READY)
				{
					// This is a terminal state, so remove all listeners.
					httpLoader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE, onHTTPLoaderStateChange);
					httpLoadTrait.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadError);
	
					var parser:MASTParser = new MASTParser();
					var mastDocument:MASTDocument;
					
					try
					{
						mastDocument = parser.parse(httpLoadTrait.urlLoader.data.toString());
					}
					catch(e:Error)
					{
						updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
						throw e;
					}
					
					MASTLoadTrait(loadTrait).document = mastDocument;
					updateLoadTrait(loadTrait, LoadState.READY);
					
				}
				else if (event.newState == LoadState.LOAD_ERROR)
				{
					// This is a terminal state, so remove the listener.  But
					// don't remove the error event listener, as that will be
					// removed when the error event for this failure is
					// dispatched.
					httpLoader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE, onHTTPLoaderStateChange);
					
					updateLoadTrait(loadTrait, event.newState);
				}
			}
			
			function onLoadError(event:MediaErrorEvent):void
			{
				// Only remove this listener, as there will be a corresponding
				// event for the load failure.
				httpLoadTrait.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadError);
				
				loadTrait.dispatchEvent(event.clone());
			}						
		}
		
		/**
		 * Unloads the document.  
		 * 
		 * <p>Updates the LoadTrait's <code>loadState</code> property to UNLOADING
		 * while unloading and to UNINITIALIZED upon completing a successful unload.</p>
		 *
		 * @param LoadTrait LoadTrait to be unloaded.
		 * @see org.osmf.traits.LoadState
		 */ 
		override protected function executeUnload(loadTrait:LoadTrait):void
		{
			// Nothing to do.
			updateLoadTrait(loadTrait, LoadState.UNLOADING);			
			updateLoadTrait(loadTrait, LoadState.UNINITIALIZED);
		}		

		private var httpLoader:HTTPLoader;		
		
		CONFIG::LOGGING
		{	
			private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.mast.loader.MASTLoader");		
		}	
	}
}
