/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.syndication.loader
{
	import org.osmf.events.LoaderEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.syndication.model.Feed;
	import org.osmf.syndication.parsers.FeedParser;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.utils.HTTPLoadTrait;
	import org.osmf.utils.HTTPLoader;
	
	CONFIG::LOGGING
	{
		import org.osmf.logging.*;
	}

	/**
	 * Loader for a syndication feed document. The load process is complete when 
	 * the request for the document has been fulfilled, and the syndication feed
	 * document has been parsed into a syndication object model.
	 **/
	public class FeedLoader extends LoaderBase
	{
		/**
		 * Constructor.
		 * 
		 * @param The HTTPLoader to be used by this loader class to retrieve
		 * the syndication document. If null, a new one will be created on demand.
		 **/
		public function FeedLoader(httpLoader:HTTPLoader=null)
		{
			super();
			this.httpLoader = httpLoader != null ? httpLoader : new HTTPLoader();
			feedParser = new FeedParser();
		}
		
		/**
		 * Returns true for HTTP resources.
		 **/
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			return httpLoader.canHandleResource(resource);
		}
		
		/**
		 * Loads a syndication feed document.
		 * <p>Updates the LoadTrait's <code>loadState</code> property to LOADING
		 * while loading and to READY upon completing a successful load and parse of the 
		 * syndication document.</p>
		 * 
		 * @param loadTrait LoadTrait to be loaded.
		 **/
		override protected function executeLoad(loadTrait:LoadTrait):void
		{
			updateLoadTrait(loadTrait, LoadState.LOADING);
			
			// We'll use an HTTPLoader to do the loading
			httpLoader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onHTTPLoaderStateChange);
			
			// Create a temporary LoadTrait for this purpose, so that our main
			// LoadTrait doesn't reflect any of the state changes from the 
			// loading of the URL, and so that we can catch any errors.
			var httpLoadTrait:HTTPLoadTrait = new HTTPLoadTrait(httpLoader, loadTrait.resource);
			httpLoadTrait.addEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadTraitError);

			CONFIG::LOGGING
			{
				debug("Downloading syndication document at " + URLResource(loadTrait.resource).url)
			}
			
			httpLoader.load(httpLoadTrait);
			
			function onHTTPLoaderStateChange(event:LoaderEvent):void
			{
				if (event.newState == LoadState.READY)
				{
					// This is a terminal state, so remove all listeners
					httpLoader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE, onHTTPLoaderStateChange);
					httpLoadTrait.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadTraitError);
					
					// Begin parsing the feed, the parse method will return a Feed object when it's finished
					try
					{
						var feed:Feed = feedParser.parse(new XML(httpLoadTrait.urlLoader.data));
					}
					catch(e:Error)
					{
						updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
						throw e;
					}
					
					(loadTrait as FeedLoadTrait).feed = feed;
					updateLoadTrait(loadTrait, LoadState.READY);
				}
				else if (event.newState == LoadState.LOAD_ERROR)
				{
					// This is a terminal state, so remove the listener. But
					// don't remove the http load trait listener, as that will be 
					// removed when the error event for this failure is dispatched.
					httpLoader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE, onHTTPLoaderStateChange);
					
					updateLoadTrait(loadTrait, event.newState);
				}
			}
			
			function onLoadTraitError(event:MediaErrorEvent):void
			{
				// Only remove this listener, as there will be a corresponding
				// event for the load failure.
				httpLoadTrait.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadTraitError);
				
				loadTrait.dispatchEvent(event.clone());
			}
		}
		
		/**
		 * Unloads the document.
		 * <p>Updates the LoadTrait's <code>loadedState</code> property to UNLOADING
		 * while unloading and to UNINITIALIZED upon completing a successful unload.</p>
		 * 
		 * @param LoadTrait LoadTrait to be unloaded.
		 **/
		override protected function executeUnload(loadTrait:LoadTrait):void
		{			
			// Nothing to do
			updateLoadTrait(loadTrait, LoadState.UNLOADING);
			updateLoadTrait(loadTrait, LoadState.UNINITIALIZED);
		}
		
		private function debug(msg:String):void
		{
			CONFIG::LOGGING
			{
				if (logger)
				{
					logger.debug(msg);
				}
			}
		}
		
		CONFIG::LOGGING
		{
			private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.syndication.loader.FeedLoader");
		}
		
		private var httpLoader:HTTPLoader;
		private var feedParser:FeedParser;
	}
}
