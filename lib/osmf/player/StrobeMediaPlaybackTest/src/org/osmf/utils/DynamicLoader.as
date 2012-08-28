/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 *  The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 *  (the "License"); you may not use this file except in
 *  compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 * 
 **********************************************************/

package org.osmf.utils
{
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	
	public class DynamicLoader extends LoaderBase
	{
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			var simpleResource:SimpleResource = resource as SimpleResource;
			return simpleResource != null &&
				   simpleResource.type != SimpleResource.UNHANDLED;
		}
		
		override protected function executeLoad(loadTrait:LoadTrait):void
		{
			doUpdateLoadTrait(loadTrait, LoadState.LOADING);
			
			if (SimpleResource(loadTrait.resource).type == SimpleResource.SUCCESSFUL)
			{
				doUpdateLoadTrait(loadTrait, LoadState.READY);
			}
			else
			{
				doUpdateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
				loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR));
			}
		}

		override protected function executeUnload(loadTrait:LoadTrait):void
		{
			doUpdateLoadTrait(loadTrait, LoadState.UNLOADING);
			doUpdateLoadTrait(loadTrait, LoadState.UNINITIALIZED);
		}

		public function doUpdateLoadTrait(loadTrait:LoadTrait, newState:String):void
		{
			super.updateLoadTrait(loadTrait, newState);
		}
	}
}