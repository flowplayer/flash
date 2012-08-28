/***********************************************************
 * 
 * Copyright 2011 Adobe Systems Incorporated. All Rights Reserved.
 *
 * *********************************************************
 * The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 * (the "License"); you may not use this file except in
 * compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems
 * Incorporated. All Rights Reserved.
 **********************************************************/
package org.osmf.smpte.tt.loader
{
	import flash.events.IEventDispatcher;
	
	import org.osmf.events.LoaderEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.smpte.tt.captions.CaptioningDocument;
	import org.osmf.smpte.tt.events.ParseEvent;
	import org.osmf.smpte.tt.model.TtElement;
	import org.osmf.smpte.tt.parsing.ISMPTETTParser;
	import org.osmf.smpte.tt.parsing.SMPTETTParser;
	import org.osmf.smpte.tt.timing.TimeExpression;
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
	 * Loader class for the SMPTETTProxyElement.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.6
	 */
	public class SMPTETTLoader extends LoaderBase
	{
		/**
		 * Constructor.
		 * 
		 * @param httpLoader The HTTPLoader to be used by this TTMLLoader 
		 * to retrieve the Timed Text document. If null, a new one will be 
		 * created.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.6
		 */
		public function SMPTETTLoader(httpLoader:HTTPLoader=null)
		{
			super();
			
			this.httpLoader = httpLoader != null ? httpLoader : new HTTPLoader();
		}
		
		/**
		 * @private
		 */
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			return httpLoader.canHandleResource(resource);
		}

		/**
		 * Loads an SMPTE-TT document.
		 * <p>Updates the LoadTrait's <code>loadState</code> property to LOADING
		 * while loading and to READY upon completing a successful load and parse of the
		 * Timed Text document.</p>
		 * 
		 * @see org.osmf.traits.LoadState
		 * @param loadTrait The LoadTrait to be loaded.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.6
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
			
			CONFIG::LOGGING
			{
				if (logger != null)
				{
					logger.debug("Downloading document at " + URLResource(httpLoadTrait.resource).url);
				}
			}
			
			httpLoader.load(httpLoadTrait);

			function onHTTPLoaderStateChange(event:LoaderEvent):void
			{
				if (event.newState == LoadState.READY)
				{
					// This is a terminal state, so remove all listeners.
					httpLoader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE, onHTTPLoaderStateChange);
					httpLoadTrait.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadError);

					var parser:ISMPTETTParser = createSMPTETTParser();
					var captioningDocument:CaptioningDocument;
					
					try
					{
						TimeExpression.initializeParameters();
						var p:SMPTETTParser = parser as SMPTETTParser;
						if (p) 
						{
							p.addEventListener(ParseEvent.BEGIN, onParseEvent);
							p.addEventListener(ParseEvent.PROGRESS, onParseEvent);
							p.addEventListener(ParseEvent.COMPLETE, onParseEvent);
						}
						parser.parse(httpLoadTrait.urlLoader.data.toString());
					}
					catch(e:Error)
					{
						CONFIG::LOGGING
						{
							if (logger != null)
							{
								logger.debug("Error parsing captioning document: " + e.errorID + "-" + e.message);
							}
						}
						updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
					}
					
					function onParseEvent(event:ParseEvent):void
					{
						// trace(event);
						if(event.type == ParseEvent.COMPLETE){
							captioningDocument = event.data as CaptioningDocument;
							SMPTETTLoadTrait(loadTrait).document = captioningDocument;
							updateLoadTrait(loadTrait, LoadState.READY);
						}
					}
				}
				else if (event.newState == LoadState.LOAD_ERROR)
				{
					// This is a terminal state, so remove the listener.  But
					// don't remove the error event listener, as that will be
					// removed when the error event for this failure is
					// dispatched.
					httpLoader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE, onHTTPLoaderStateChange);
					
					CONFIG::LOGGING
					{
						if (logger != null)
						{
							logger.debug("Error loading SMPTE-TT document");;
						}
					}
					
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
		 * while unloading and to CONSTRUCTED upon completing a successful unload.</p>
		 *
		 * @param LoadTrait LoadTrait to be unloaded.
		 * @see org.osmf.traits.LoadState
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.6
		 */ 
		override protected function executeUnload(loadTrait:LoadTrait):void
		{
			// Nothing to do.
			updateLoadTrait(loadTrait, LoadState.UNLOADING);			
			updateLoadTrait(loadTrait, LoadState.UNINITIALIZED);
		}
		
		/**
		 * Override to create your own parser.
		 */
		protected function createSMPTETTParser():ISMPTETTParser
		{
			return new SMPTETTParser();
		}

		private var httpLoader:HTTPLoader;
		
		CONFIG::LOGGING
		{	
			private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.captioning.loader.SMPTETTLoader");		
		}	
	}
}
