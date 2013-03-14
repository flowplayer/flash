package org.osmf.smpte.tt.loader
{
	import org.osmf.events.LoaderEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.URLResource;
	import org.osmf.smpte.tt.architecture.creation.SMPTETTFactoryFacade;
	import org.osmf.smpte.tt.captions.CaptioningDocument;
	import org.osmf.smpte.tt.events.ParseEvent;
	import org.osmf.smpte.tt.parsing.ISMPTETTParser;
	import org.osmf.smpte.tt.parsing.SMPTETTParser;
	import org.osmf.smpte.tt.timing.TimeCode;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.utils.HTTPLoadTrait;
	import org.osmf.utils.HTTPLoader;
	
	CONFIG::LOGGING
	{
		import org.osmf.logging.*;		
	}

	/*
	This whole class was represented by a single method before refactoring. 
	The intent is to listen for some events to some short lived variables.
	Eventually, there are a couple of callbacks into the SMPTETTLoader to update the properties
	
	One of the callbacks was a protected final method : updateLoadTrait(), 
	so SMPTETTLoader had to add a public delegate method to access it: updateLoadTraitAccessor()
	*/
	public class SMPTETTLoader_LoadTrait_Helper
	{
		public static var creationType:Class = SMPTETTLoader_LoadTrait_Helper;
		
		//Reference via this static method, so that it can be swapped out if needed
		public static function create(loader:SMPTETTLoader, p_httpLoader:HTTPLoader):SMPTETTLoader_LoadTrait_Helper
		{
			return new creationType(loader, p_httpLoader);
		}
		
		private var _loader:SMPTETTLoader
		private var httpLoadTrait:HTTPLoadTrait;
		private var _httpLoader:HTTPLoader;
		private var _loadTrait:LoadTrait
		private var captioningDocument:CaptioningDocument;
		
		public function SMPTETTLoader_LoadTrait_Helper(loader:SMPTETTLoader, p_httpLoader:HTTPLoader)
		{
			_loader = loader;
			_httpLoader = p_httpLoader
		}
		

		protected function get loadTrait():LoadTrait
		{
			return _loadTrait;
		}

		public function executeLoad(p_loadTrait:LoadTrait):void
		{
			_loadTrait = p_loadTrait;
			updateLoadTrait(loadTrait, LoadState.LOADING);			
			
			httpLoader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onHTTPLoaderStateChange);
			
			// Create a temporary LoadTrait for this purpose, so that our main
			// LoadTrait doesn't reflect any of the state changes from the
			// loading of the URL, and so that we can catch any errors.
			httpLoadTrait = new HTTPLoadTrait(httpLoader, loadTrait.resource);
			
			httpLoadTrait.addEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadError);
			
			CONFIG::LOGGING
			{
				if (logger != null)
				{
					logger.debug("Downloading document at " + URLResource(httpLoadTrait.resource).url);
				}
			}
			
			httpLoader.load(httpLoadTrait);
			
		}
		
		protected function onHTTPLoaderStateChange(event:LoaderEvent):void
		{
			if (event.newState == LoadState.READY)
			{
				prepReadyState();
			}
			else if (event.newState == LoadState.LOAD_ERROR)
			{
				prepLoadErrorState(event);
			}
		}

		private function prepReadyState():void
		{
			// trace(smptettLoader+" onHTTPLoaderStateChange: "+event.newState+" "+(getTimer()-loadTime)/1000+"s");
			// loadTime = getTimer();
		
			// This is a terminal state, so remove all listeners.
			httpLoader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE, onHTTPLoaderStateChange);
			httpLoadTrait.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadError);
		
			var parser:ISMPTETTParser = SMPTETTFactoryFacade.getSMPTETTParser();
		
			try
			{
				var p:SMPTETTParser = parser as SMPTETTParser;
				if (p) 
				{
					p.startTime = startTime;
					p.endTime = endTime;
					p.addEventListener(ParseEvent.BEGIN, onParseEvent);
					p.addEventListener(ParseEvent.PROGRESS, onParseEvent);
					p.addEventListener(ParseEvent.COMPLETE, onParseEvent);
					p.addEventListener(ParseEvent.PARTIAL, onParseEvent);
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
		}

		
		protected function onParseEvent(event:ParseEvent):void
		{
			captioningDocument = event.data as CaptioningDocument;
			SMPTETTLoadTrait(loadTrait).document = captioningDocument;
			switch (event.type)
			{
				case ParseEvent.COMPLETE:
					updateLoadTrait(loadTrait, LoadState.READY);
					break;
			}
			loadTrait.dispatchEvent(event);
		}
		
		private function prepLoadErrorState(event:LoaderEvent):void
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

		
		protected function onLoadError(event:MediaErrorEvent):void
		{
			// Only remove this listener, as there will be a corresponding
			// event for the load failure.
			httpLoadTrait.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadError);
			
			loadTrait.dispatchEvent(event.clone());
		}	
		
		private function get httpLoader(): HTTPLoader
		{
			return _httpLoader;
		}
		
		private function updateLoadTrait(loadTrait:LoadTrait, newState:String):void
		{
			_loader.updateLoadTraitAccessor(loadTrait, newState)
		}
		
		
		private function get startTime():TimeCode {return _loader.startTime;}
		private function get endTime():TimeCode {return _loader.endTime;}
		
		CONFIG::LOGGING
		{	
			private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.captioning.loader.SMPTETTLoader");		
		}	
	}
}