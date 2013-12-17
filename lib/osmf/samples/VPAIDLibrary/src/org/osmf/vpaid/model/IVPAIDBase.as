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
package org.osmf.vpaid.model
{

	import flash.events.IEventDispatcher;

	/*
		Interface: IVPAIDBase
	*/
	public interface IVPAIDBase extends IEventDispatcher
	{
	    // Properties
	    
	    function get api():Object;
	    
	    function get version():Number;
	    
	    /**
	    * Indicates the ad’s current linear vs. non-linear mode of
	    * operation. linearVPAID when true indicates the ad is in a linear playback mode, false
	    * nonlinear.
	    * 
	    * 	@langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
	    */ 
	    function get linearVPAID() : Boolean;
	    
		/** 
		 * Indicates whether the ad is in a state where it
		 * occupies more UI area than its smallest area. If the ad has multiple expanded states,
		 * all expanded states show expandedVPAID being true.
		 * 
		 * 	@langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 	    
	    function get expandedVPAID() : Boolean;
	    
	    /**
	    * The player may use the remainingTimeVPAID property to update player UI during ad
	    * playback. The remainingTimeVPAID property is in seconds and is relative to the time the
	    * property is accessed.
	    * 
	    * 	@langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
	    */ 
	    function get remainingTimeVPAID() : Number;
	    
	    /**
	    * The player uses the volumeVPAID property to attempt to set or get the ad volume. The
	    * volumeVPAID value is between 0 and 1 and is linear.
	    * 
	    * 	@langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
	    */
	    function get volumeVPAID() : Number;
	    function set volumeVPAID(value : Number) : void; 

	    // Methods
	    
	    function probeVersion():Boolean
	    
	    /**
	    * After the ad is loaded and the player calls handshakeVersion, the player calls initVPAID to
	    * initialize the ad experience. The player may pre-load the ad and delay calling initVPAID
	    * until nearing the ad playback time, however, the ad does not load its assets until initVPAID
	    * is called.
	    * 
	    * 	@langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
	    */ 
	    function initVPAID(width : Number, height : Number, viewMode : String, desiredBitrate : Number, creativeData : String, environmentVars : String) : void;
	    
	    /**
	    * Following a resize of the ad UI container, the player calls resizeAd to allow the ad to
	    * scale or reposition itself within its display area. The width and height always matches
	    * the maximum display area allotted for the ad, and resizeVPAID is only called when the
	    * player changes its video content container sizing.
	    * 
	    * 	@langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
	    */
	    function resizeVPAID(width : Number, height : Number, viewMode : String) : void;
	    
	    /**
	    * startVPAID is called by the player and is called when the player wants the ad to start
	    * displaying.
	    * 
	    * 	@langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
	    */ 
	    function startVPAID() : void;
	    
	    /**
	    * stopVPAID is called by the player when it will no longer display the ad. stopVPAID is also
	    * called if the player needs to cancel an ad.
	    * 
	    * 	@langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
	    */
	    function stopVPAID() : void;
	    
	    /**
	    * pauseVPAID is called to pause ad playback. 
	    * 
	    * 	@langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
	    */
	    function pauseVPAID() : void;
	    
	    /**
	    * resumeVPAID is called to continue ad playback following a call to pauseAd.
	    * 
	    * 	@langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
	    */
	    function resumeVPAID() : void;
	    
	    /**
	    * expandVPAID is called by the player to request that the ad switch to its larger UI size.
	    * 
	    * 	@langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
	    */
	    function expandVPAID() : void;
	    
	   /**
	    * collapseVPAID is called by the player to request that the ad switch to its smallest UI size.
	    * 
	    * 	@langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
	    */
	    function collapseVPAID() : void;
	    
	}
}
