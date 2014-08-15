/*****************************************************
*  
*  Copyright 2010 Eyewonder, LLC.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Eyewonder, LLC.
*  Portions created by Eyewonder, LLC. are Copyright (C) 2010 
*  Eyewonder, LLC. A Limelight Networks Business. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.vpaid.traits
{
	import flash.events.Event;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.traits.LoaderBase;
	import org.osmf.utils.HTTPLoadTrait;
	import org.osmf.events.LoadEvent;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoadState;
	import org.osmf.elements.loaderClasses.LoaderLoadTrait;
	import org.osmf.vpaid.events.VPAIDLoadEvent;
	

	/**
	 * An VPAIDLoadEvent is dispatched when the properties of a VPAIDLoadTrait change.
	 * 
	 * @eventType org.osmf.vpaid.events.LoadEvent.VPAID_READY
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	[Event(name="VPAIDReady",type="org.osmf.vpaid.events.VPAIDLoadEvent")]

	
	/**
	 * Delays the Ready event until VPAID is loaded and initialized
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */

	public class VPAIDLoadTrait extends LoaderLoadTrait
	{
		public function VPAIDLoadTrait(loader:LoaderBase, resource:MediaResourceBase)
		{
			super(loader, resource);
		}
		
		/**
		 * Called once the VPAID Ad has finished loading
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */

		public function vpaidReady():void
		{
			if(loadState == LoadState.READY)
				dispatchEvent(new LoadEvent(LoadEvent.LOAD_STATE_CHANGE, false, false, loadState));
		}
		
		override protected function loadStateChangeEnd():void
		{
			if(loadState != LoadState.READY){
				dispatchEvent(new LoadEvent(LoadEvent.LOAD_STATE_CHANGE, false, false, loadState));
			}else{
				dispatchEvent(new VPAIDLoadEvent(VPAIDLoadEvent.INITIALIZE_VPAID, false, false));
			}
		}		
	}
}
