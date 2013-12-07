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
	import flash.utils.getTimer;
	
	import org.osmf.events.LoaderEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.smpte.tt.captions.CaptioningDocument;
	import org.osmf.smpte.tt.events.ParseEvent;
	import org.osmf.smpte.tt.model.TtElement;
	import org.osmf.smpte.tt.parsing.ISMPTETTParser;
	import org.osmf.smpte.tt.parsing.SMPTETTParser;
	import org.osmf.smpte.tt.timing.TimeCode;
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
			var helper:SMPTETTLoader_LoadTrait_Helper = SMPTETTLoader_LoadTrait_Helper.create(this,httpLoader);
			helper.executeLoad(loadTrait);
		}
		
		
		
		//Referenced from the LoadTrait_Helper
		public function updateLoadTraitAccessor(loadTrait:LoadTrait, newState:String):void
		{
			updateLoadTrait(loadTrait, newState);
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
		
		private var _startTime:TimeCode = null;
		public function get startTime():TimeCode
		{
			return _startTime;
		}
		
		public function set startTime(value:TimeCode):void
		{
			_startTime = value;
		}
		
		private var _endTime:TimeCode = null;
		public function get endTime():TimeCode
		{
			return _endTime;
		}
		
		public function set endTime(value:TimeCode):void
		{
			_endTime = value;
		}
		
		
		private var httpLoader:HTTPLoader;
		
		CONFIG::LOGGING
		{	
			private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.captioning.loader.SMPTETTLoader");		
		}	
	}
}
