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
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osmf.events.LoadEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	
	/**
	 * A proxy for a LoadTrait.  Delays exposing the READY state for 2 seconds
	 * after the proxied LoadTrait is READY.
	 **/
	public class AsynchLoadingProxyLoadTrait extends LoadTrait
	{
		/**
		 * Constructor.
		 * 
		 * @param proxiedLoadTrait The LoadTrait to proxy.
		 **/
		public function AsynchLoadingProxyLoadTrait(proxiedLoadTrait:LoadTrait)
		{
			super(null, null);
			
			this.proxiedLoadTrait = proxiedLoadTrait;
			proxiedLoadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
			proxiedLoadTrait.addEventListener(LoadEvent.BYTES_TOTAL_CHANGE, onBytesTotalChange);
			
			calculatedLoadState = proxiedLoadTrait.loadState;
		}
		
		/**
		 * @private
		 **/
		override public function get resource():MediaResourceBase
		{
			return proxiedLoadTrait.resource;
		}
		
		/**
		 * @private
		 **/
		override public function get loadState():String
		{
			// Return our own calculated load state, not the base load state. 
			return calculatedLoadState;
		}
				
		/**
		 * @private
		 **/
		override public function load():void
		{
			proxiedLoadTrait.load();
		}
		
		/**
		 * @private
		 **/
		override public function unload():void
		{
			proxiedLoadTrait.unload();
		}
		
		/**
		 * @private
		 **/
		override public function get bytesLoaded():Number
		{
			return proxiedLoadTrait.bytesLoaded;
		}
		
		/**
		 * @private
		 **/
		override public function get bytesTotal():Number
		{
			return proxiedLoadTrait.bytesTotal;
		}
		
		/**
		 * Calculated version of the LoadState for this LoadTrait.  Distinct
		 * from the proxied loadState property, which is not exposed to the
		 * client.
		 **/
		protected var calculatedLoadState:String;
		
		/**
		 * Override this method to define custom load logic that should occur
		 * during the load operation, but before the READY state is signaled
		 * to clients.  When the custom load logic has finished, set the
		 * calculatedLoadState to LoadState.READY and dispatch the
		 * eventToDispatch event.
		 **/
		protected function doCustomLoadLogic(eventToDispatch:Event):void
		{
			// For demonstration purposes, we just let a Timer run for a
			// few seconds, then signal that we're done.  In a more realistic
			// scenario, there might be some number of asynchronous calls
			// going on.
			var timer:Timer = new Timer(2000, 1);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
			
			function onTimer(timerEvent:TimerEvent):void
			{
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				
				// When all of the custom load logic is complete, we update
				// our load state and inform the outside world.
				calculatedLoadState = LoadState.READY;
				dispatchEvent(eventToDispatch);
			}
		}
		
		// Internals
		//
		
		private function onLoadStateChange(event:LoadEvent):void
		{
			if (event.loadState == LoadState.READY)
			{
				// Although the proxied element is now ready, we don't want
				// to expose the READY state to the outside world because we
				// want to be able to perform our own custom load logic first.
				doCustomLoadLogic(event.clone());
			}
			else
			{
				// Expose the proxied element's state to the outside world.
				calculatedLoadState = event.loadState;
				dispatchEvent(event.clone());
			}
		}

		private function onBytesTotalChange(event:LoadEvent):void
		{
			dispatchEvent(event.clone());
		}
		
		private var proxiedLoadTrait:LoadTrait;
	}
}