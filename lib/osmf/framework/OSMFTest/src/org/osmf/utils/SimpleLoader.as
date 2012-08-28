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
package org.osmf.utils
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	
	/**
	 * A SimpleLoader performs loads and unloads synchronously.
	 **/
	public class SimpleLoader extends LoaderBase
	{
		/**
		 * Constructor.
		 **/
		public function SimpleLoader(delayLoadComplete:Boolean = false)
		{
			this.delayLoadComplete = delayLoadComplete;
		}
		
		/**
		 * Indicates that the load operation should be forced to
		 * fail.
		 **/
		public function forceFail(loadTrait:LoadTrait):Boolean
		{
			return loadTrait.resource is SimpleResource &&
				   SimpleResource(loadTrait.resource).type == SimpleResource.FAILED;
		}
		
		/**
		 * @inheritDoc
		 **/
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			var simpleResource:SimpleResource = resource as SimpleResource;
			if (simpleResource != null)
			{
				return simpleResource.type != SimpleResource.UNHANDLED;
			}
			
			return true; 
		}
		
		/**
		 * @inheritDoc
		 **/
		override protected function executeLoad(loadTrait:LoadTrait):void
		{
			updateLoadTrait(loadTrait, LoadState.LOADING);
			
			if (forceFail(loadTrait))
			{
				updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
			}
			else
			{
				if (delayLoadComplete)
				{
					var timer:Timer = new Timer(500, 1);
					timer.addEventListener(TimerEvent.TIMER, onTimer);
					timer.start();
					
					function onTimer(event:TimerEvent):void
					{
						timer.removeEventListener(TimerEvent.TIMER, onTimer);
						
						updateLoadTrait(loadTrait, LoadState.READY);
					}
				}
				else
				{
					updateLoadTrait(loadTrait, LoadState.READY);
				}
			}
		}
		
		/**
		 * @inheritDoc
		 **/
		override protected function executeUnload(loadTrait:LoadTrait):void
		{
			if (loadTrait.loadState == LoadState.LOADING ||
				loadTrait.loadState == LoadState.READY)
			{
				updateLoadTrait(loadTrait, LoadState.UNLOADING);
				updateLoadTrait(loadTrait, LoadState.UNINITIALIZED);
			}
		}
		
		private var delayLoadComplete:Boolean = false;
	}
}