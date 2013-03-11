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
*                  Eyewonder, LLC
*  
*****************************************************/
package org.osmf.vast.loader
{
	import org.osmf.events.LoaderEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.utils.HTTPLoadTrait;
	import org.osmf.utils.HTTPLoader;
	import org.osmf.vast.model.VASTDataObject;
	import org.osmf.vast.parser.VAST2Parser;
	import org.osmf.vast.parser.base.VAST2TrackingData;

	CONFIG::LOGGING
	{
	import org.osmf.logging.Logger;
	import org.osmf.logging.Log;
	}
	
	/**
	 * Loader for a VAST Document.  The load process is complete when
	 * the request for the document has been fulfilled, and the VAST
	 * document has been parsed into a VAST document object model.
	 * 
	 * @see http://www.iab.net/vast
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class VASTLoader extends LoaderBase
	{
		/**
		 * Constructor.
		 * 
		 * @param maxNumWrapperRedirects The maximum number of redirects
		 * allowed when retrieving wrapper documents.  The default is 10.
		 * -1 means no limit
		 * @param The HTTPLoader to be used by this VASTLoader to retrieve
		 * the VAST document.  If null, then a new one will be created on
		 * demand.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function VASTLoader(maxNumWrapperRedirects:Number=10, httpLoader:HTTPLoader=null, trackingData:VAST2TrackingData = null)
		{
			super();
			
			this.maxNumWrapperRedirects = maxNumWrapperRedirects;
			this.httpLoader = httpLoader != null ? httpLoader : new HTTPLoader();
			this.trackingData = trackingData;		
		}
		
		/**
		 * Returns true for HTTP(s) resource.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			return httpLoader.canHandleResource(resource);
		}
		
		/**
		 * Loads a VAST document. 
		 * <p>Updates the LoadTrait's <code>loadState</code> property to LOADING
		 * while loading and to READY upon completing a successful load and parse of the 
		 * VAST document.</p> 
		 * 
		 * @see org.osmf.traits.LoadState
		 * @see flash.display.Loader#load()
		 * @param LoadTrait LoadTrait to be loaded.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		override protected function executeLoad(loadTrait:LoadTrait):void
		{
			updateLoadTrait(loadTrait, LoadState.LOADING);
			
			// We'll use an HTTPLoader to do the loading.
			httpLoader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onHTTPLoaderStateChange);
			
			// Create a temporary LoadTrait for this purpose, so that our main
			// LoadTrait doesn't reflect any of the state changes from the
			// loading of the URL, and so that we can catch any errors.
			var httpLoadTrait:HTTPLoadTrait = new HTTPLoadTrait(httpLoader, loadTrait.resource);
			httpLoadTrait.addEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadTraitError);

			CONFIG::LOGGING
			{
				logger.debug("[VAST] Loading document from: " + URLResource(loadTrait.resource).url.toString() + ", " + maxNumWrapperRedirects + " wrapper redirects left");
			}
			httpLoader.load(httpLoadTrait);
			
			function onHTTPLoaderStateChange(event:LoaderEvent):void
			{
				if (httpLoadTrait == event.loadTrait)
				{
					if (event.newState == LoadState.READY)
					{
						// This is a terminal state, so remove all listeners.
						httpLoader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE, onHTTPLoaderStateChange);
						httpLoadTrait.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadTraitError);
		
						// Use a separate processor class to parse the document.
						var processor:VASTDocumentProcessor = new VASTDocumentProcessor(maxNumWrapperRedirects, httpLoader);
						toggleProcessorListeners(processor, true);
						
						processor.processVASTDocument(httpLoadTrait.urlLoader.data, trackingData);
	
						function toggleProcessorListeners(processor:VASTDocumentProcessor, add:Boolean):void
						{
							if (add)
							{
								processor.addEventListener(VASTDocumentProcessedEvent.PROCESSED, onDocumentProcessed);
								processor.addEventListener(VASTDocumentProcessedEvent.PROCESSING_FAILED, onDocumentProcessFailed);
							}
							else
							{
								processor.removeEventListener(VASTDocumentProcessedEvent.PROCESSED, onDocumentProcessed);
								processor.removeEventListener(VASTDocumentProcessedEvent.PROCESSING_FAILED, onDocumentProcessFailed);
							}
						}
	
						function onDocumentProcessed(event:VASTDocumentProcessedEvent):void
						{
							toggleProcessorListeners(processor, false);
						
							var vastLoadTrait:VASTLoadTrait = loadTrait as VASTLoadTrait;
							vastLoadTrait.vastDocument = event.vastDocument as VASTDataObject;
							updateLoadTrait(loadTrait, LoadState.READY);
						}
						
						function onDocumentProcessFailed(event:VASTDocumentProcessedEvent):void
						{
							toggleProcessorListeners(processor, false);
	
							updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
						}
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
		 * 
		 * <p>Updates the LoadTrait's <code>loadedState</code> property to UNLOADING
		 * while unloading and to UNINITIALIZED upon completing a successful unload.</p>
		 *
		 * @param LoadTrait LoadTrait to be unloaded.
		 * @see org.osmf.traits.LoadState
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		override protected function executeUnload(loadTrait:LoadTrait):void
		{
			// Nothing to do.
			updateLoadTrait(loadTrait, LoadState.UNLOADING);			
			updateLoadTrait(loadTrait, LoadState.UNINITIALIZED);
		}
		

		CONFIG::LOGGING
		private static const logger:Logger = Log.getLogger("org.osmf.vast.loader.VASTLoader");

		private var maxNumWrapperRedirects:int;
		private var httpLoader:HTTPLoader;
		private var trackingData:VAST2TrackingData;
	}
}
