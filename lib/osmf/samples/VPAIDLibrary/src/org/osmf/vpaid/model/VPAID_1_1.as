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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.osmf.vpaid.events.VPAIDEvent;
	import org.osmf.vpaid.elements.VPAIDElement;
	import org.osmf.vpaid.metadata.VPAIDMetadata;
	
	CONFIG::LOGGING
	{
	import org.osmf.logging.Logger;
	import org.osmf.logging.Log;
	}
	
	/**
		Class: VPAID_1_1
		 
		This class handles communication with v1.1 VPAID ads
	**/
	public class VPAID_1_1 extends EventDispatcher implements IVPAIDBase
	{
		private var _handshakeVersions:Array = ["1.1"];
		private var _vpaidElement:VPAIDElement;

		public var adVersion:String;
		private var _vpaidAPI:*;
		
		/**
			Constructor: VPAID_1_1
			
			Initializes the VPAID_1_1
			
			Parameters:
				VPAIDController - A reference to an instantiated <VPAIDController>
		**/
		
	/** 
	 * Constructor: VPAID_1_1
	 * Initializes the VPAID_1_1
	 * 
	 * Parameters:
	 * 
	 * VPAIDController - A reference to an instantiated <VPAIDController>
	 * 
	 *  
	 **/

		
		public function VPAID_1_1(vpaidSWF:Object, vpaidElement:VPAIDElement):void
		{
			_vpaidElement = vpaidElement;
			try{
				_vpaidAPI = vpaidSWF.getVPAID();
			}catch(e:Error){
				_vpaidElement.error();
			}
			
		}
		/**
       	 * Performs a handshake with the loaded VPAID Ad passing it a VPAID version.
       	 * If the version number passed to handshake is supported than the Ad is ready to start,
       	 * otherwise an error is dispatched.
       	 * 
       	 *  @langversion 3.0
       	 *  @playerversion Flash 10
       	 *  @playerversion AIR 1.5
       	 *  @productversion OSMF 1.0
       	 */    
		public function probeVersion():Boolean
		{
			var result:Boolean = false;

			try
			{
				adVersion = _vpaidAPI.handshakeVersion("1.1");
				var handshakeReturn:Boolean = _checkHandShakeVersion(adVersion);
			}
			catch (e:Error)
			{
				return false;
			}
			
			if (handshakeReturn)
			{
				result = true;
			}
			
			return result;
		}

		private function addVPAIDSWFListeners():void 
		{
			_vpaidAPI.addEventListener("AdLoaded", _vpaidEventHandler);
			_vpaidAPI.addEventListener("AdCreativeView", _vpaidEventHandler);
			_vpaidAPI.addEventListener("AdStarted", _vpaidEventHandler);
			_vpaidAPI.addEventListener("AdStopped", _vpaidEventHandler);
			_vpaidAPI.addEventListener("AdLinearChange", _vpaidEventHandler);
			_vpaidAPI.addEventListener("AdExpandedChange", _vpaidEventHandler);
			_vpaidAPI.addEventListener("AdRemainingTimeChange", _vpaidEventHandler);
			_vpaidAPI.addEventListener("AdVolumeChange", _vpaidEventHandler);
			_vpaidAPI.addEventListener("AdImpression", _vpaidEventHandler);
			_vpaidAPI.addEventListener("AdVideoStart", _vpaidEventHandler);
			_vpaidAPI.addEventListener("AdVideoFirstQuartile", _vpaidEventHandler);
			_vpaidAPI.addEventListener("AdVideoMidpoint", _vpaidEventHandler);
			_vpaidAPI.addEventListener("AdVideoThirdQuartile", _vpaidEventHandler);
			_vpaidAPI.addEventListener("AdVideoComplete", _vpaidEventHandler);
			_vpaidAPI.addEventListener("AdClickThru", _vpaidEventHandler);
			_vpaidAPI.addEventListener("AdUserAcceptInvitation", _vpaidEventHandler);
			_vpaidAPI.addEventListener("AdUserMinimize", _vpaidEventHandler);
			_vpaidAPI.addEventListener("AdUserClose", _vpaidEventHandler);
			_vpaidAPI.addEventListener("AdPaused", _vpaidEventHandler);
			_vpaidAPI.addEventListener("AdPlaying", _vpaidEventHandler);
			_vpaidAPI.addEventListener("AdLog", _vpaidEventHandler);
			_vpaidAPI.addEventListener("AdError", _vpaidEventHandler);
			



		}

		private function removeVPAIDSwfListeners():void
		{
			_vpaidAPI.removeEventListener("AdLoaded", _vpaidEventHandler);
			_vpaidAPI.removeEventListener("AdStarted", _vpaidEventHandler);
			_vpaidAPI.removeEventListener("AdStopped", _vpaidEventHandler);
			_vpaidAPI.removeEventListener("AdLinearChange", _vpaidEventHandler);
			_vpaidAPI.removeEventListener("AdExpandedChange", _vpaidEventHandler);
			_vpaidAPI.removeEventListener("AdRemainingTimeChange", _vpaidEventHandler);
			_vpaidAPI.removeEventListener("AdVolumeChange", _vpaidEventHandler);
			_vpaidAPI.removeEventListener("AdImpression", _vpaidEventHandler);
			_vpaidAPI.removeEventListener("AdVideoStart", _vpaidEventHandler);
			_vpaidAPI.removeEventListener("AdVideoFirstQuartile", _vpaidEventHandler);
			_vpaidAPI.removeEventListener("AdVideoMidpoint", _vpaidEventHandler);
			_vpaidAPI.removeEventListener("AdVideoThirdQuartile", _vpaidEventHandler);
			_vpaidAPI.removeEventListener("AdVideoComplete", _vpaidEventHandler);
			_vpaidAPI.removeEventListener("AdClickThru", _vpaidEventHandler);
			_vpaidAPI.removeEventListener("AdUserAcceptInvitation", _vpaidEventHandler);
			_vpaidAPI.removeEventListener("AdUserMinimize", _vpaidEventHandler);
			_vpaidAPI.removeEventListener("AdUserClose", _vpaidEventHandler);
			_vpaidAPI.removeEventListener("AdPaused", _vpaidEventHandler);
			_vpaidAPI.removeEventListener("AdPlaying", _vpaidEventHandler);
			_vpaidAPI.removeEventListener("AdLog", _vpaidEventHandler);
			_vpaidAPI.removeEventListener("AdError", _vpaidEventHandler);
			_vpaidAPI.removeEventListener("AdCreativeView", _vpaidEventHandler);

		


					
		}
		
		/*
			Function: _checkHandShakeVersion
			
			Compares the version from the VPAID ad with the version-array of this class
			
			Return:
				Boolean - Is true if the version of the ad is found inside the _handshakeVersions array
		*/
		private function _checkHandShakeVersion(_version:String):Boolean
		{
			for (var i:Object in _handshakeVersions)
			{
				if (_version.substring(0,3) == _handshakeVersions[i].substring(0,3))
				return true;
			}
			return false;
		}
		
		/*
			Function: _vpaidEventHandler
			
			Events that come from the ad are handled here event type is
			intentionally set as asterisk, reasoning for this is
			if the event comes from a external swf the type is not predictable.
		
			Events:
				VPAIDEvent.LOADED 				- Loading of ad is done
				VPAIDEvent.STARTED 				- Ad is displaying
				VPAIDEvent.STOPPED 				- Ad has stopped displaying, and ressources have been cleaned up
				VPAIDEvent.LINEAR_CHANGE 			- Ad has changed playback mode
				VPAIDEvent.EXPANDED_CHANGE 		- Ad expanded state has being changed
				VPAIDEvent.REMAINING_TIME_CHANGE	- Remaining time of ad has been changed
				VPAIDEvent.VOLUME_CHANGE 			- Ad has changed it's volume
				VPAIDEvent.IMPRESSION 			- User-visible phase of ad has begun
				VPAIDEvent.VIDEO_START 			- Video has started progress
				VPAIDEvent.VIDEO_FIRST_QUARTILE 	- Ad video has reached first quartile
				VPAIDEvent.VIDEO_MIDPOINT 			- Ad video has reached it's midpoint
				VPAIDEvent.VIDEO_THIRD_QUARTILE 	- Ad video has reached third quartile
				VPAIDEvent.VIDEO_COMPLETE 			- Ad video has been played completely
				VPAIDEvent.CLICK_THRU 				- Click thru occured
				VPAIDEvent.USER_ACCEPT_INVITATION 	- Triggered on user ineraction
				VPAIDEvent.USER_MINIMIZE 			- Triggered on user ineraction
				VPAIDEvent.USER_CLOSE 				- Triggered on user ineraction
				VPAIDEvent.PAUSED 				- Response to method call
				VPAIDEvent.PLAYING 				- Response to method call
				VPAIDEvent.LOG 					- Ad sends debug message to relay
				VPAIDEvent.ERROR 					- Fatal error occured
		
			Parameter:
				event - The event that was sent by the ad.
		*/
		private function _vpaidEventHandler(event:Object):void 
		{	
			//Forward events
			var myVPAIDEvent:VPAIDEvent = new VPAIDEvent(event.type, event.data, event.bubbles,event.cancelable);
			_vpaidElement.dispatchEvent(myVPAIDEvent);
			
			
			
			if (event.type!="AdLog"){
				switch (event.type) {
					
					case "AdCreativeView":
						dispatchEvent(new Event("AdCreativeView"));		
					break;
					
					case "AdLoaded" :
						dispatchEvent(new Event("AdLoaded"));		
					break;

									
					case "AdStarted" :
						dispatchEvent(new Event("AdStarted"));		
					break;
					
					case "AdStopped" :
						dispatchEvent(new Event("AdStopped"));				
					break;
					
					case "AdLinearChange" :
						dispatchEvent(new Event("AdLinearChange"));		
					break;
					
					case "AdExpandedChange" :
						dispatchEvent(new Event("AdExpandedChange"));		
					break;
							
					case "AdRemainingTimeChange" :
						dispatchEvent(new Event("AdRemainingTimeChange"));		
					break;
					
					case "AdVolumeChange" :
						dispatchEvent(new Event("AdVolumeChange"));		
					break;
																										
					case "AdPaused" :
						dispatchEvent(new Event("AdPaused"));							
					break;
					
					case "AdPlaying" :
						dispatchEvent(new Event("AdPlaying"));							
					break;
					
					case"AdVideoStart":
						dispatchEvent(new Event("AdVideoStart"));		
					break;
					
					case"AdVideoFirstQuartile":	
						dispatchEvent(new Event("AdVideoFirstQuartile"));		
					break;
					
					case"AdVideoMidpoint":
						dispatchEvent(new Event("AdVideoMidPoint"));		
					break;
					
					case"AdVideoThirdQuartile":	
						dispatchEvent(new Event("AdVideoThirdQuartile"));		
					break;
					
					case"AdVideoComplete":	
						dispatchEvent(new Event("AdVideoComplete"));		
					break;
					
					case"AdClickThru":
						dispatchEvent(new Event("AdClickThru"));		
	
					break;
					
					case"AdUserAcceptInvitation":
						dispatchEvent(new Event("AdUserAcceptInvitation"));		
				
					break;
					
					case"AdUserMinimize":
						dispatchEvent(new Event("AdUserMinimize"));		
				
					break;
					
					case"AdUserClose":
						dispatchEvent(new Event("AdUserClose"));		
					break;
					
					case"AdImpression":	
						dispatchEvent(new Event("AdImpression"));			
					break;
					
					case "AdLog" :
						dispatchEvent(new Event("AdLog"));		
					break;						
					
					case "AdError" :
						dispatchEvent(new Event("AdError"));		
					break;
				}
			}
		}
		

	    /**
       	 *  Property: linearVPAID
       	 * Indicates the ad’s current linear vs. non-linear mode of operation.
       	 * 
       	 * Returns:	Boolean - Is true when the ad is in linear playback mode, false if it's nonlinear
       	 * 
       	 *  @langversion 3.0
       	 *  @playerversion Flash 10
       	 *  @playerversion AIR 1.5
       	 *  @productversion OSMF 1.0
       	 **/   
		public function get linearVPAID() : Boolean {
			return _vpaidAPI.adLinear;
		}
	    

		 /**
       	 *  Property: expandedVPAID
       	 * 
       	 * Indicates whether the ad is in a state where it
       	 * occupies more UI area than its smallest area. If the ad has multiple expanded states,
       	 * all expanded states show expandedVPAID being true.		
       	 * Returns:
				Boolean - Returns true when ad is in a state where it occupies more UI area than its smallest area
       	 * 
       	 *  @langversion 3.0
       	 *  @playerversion Flash 10
       	 *  @playerversion AIR 1.5
       	 *  @productversion OSMF 1.0
       	 **/  	    
	    public function get expandedVPAID() : Boolean {
			return _vpaidAPI.adExpanded;
		}
	    

	    
	     /**
       	 *  Property: remainingTimeVPAID
       	 * 
			The player may use the remainingTimeVPAID property to update player UI during ad
	    	playback. The remainingTimeVPAID property is in seconds and is relative to the time the
	    	property is accessed.

			Returns:
				Number - Remaining time of the VPAID ad in Seconds
       	 * 
       	 *  @langversion 3.0
       	 *  @playerversion Flash 10
       	 *  @playerversion AIR 1.5
       	 *  @productversion OSMF 1.0
       	 **/ 
	    public function get remainingTimeVPAID() : Number {
			return _vpaidAPI.adRemainingTime;
		}
	    
	    
	    /**
       	 *  Property: volumeVPAID

			The player uses the volumeVPAID property to attempt to set or get the ad volume.
			
			Returns:
				Number - A Number between 0 and 1, where 0 means muted.
				 * 
       	 *  @langversion 3.0
       	 *  @playerversion Flash 10
       	 *  @playerversion AIR 1.5
       	 *  @productversion OSMF 1.0
       	 **/ 
	    public function get volumeVPAID() : Number {
			return _vpaidAPI.adVolume;
		}

	    /**
  			Property: volumeVPAID

			Sets the volume of the VPAID ad.
			
			Parameter:
				Number - A Number between 0 and 1, where 0 means muted.
		 * 
       	 *  @langversion 3.0
       	 *  @playerversion Flash 10
       	 *  @playerversion AIR 1.5
       	 *  @productversion OSMF 1.0
       	 **/ 
	    public function set volumeVPAID(value : Number) : void {
			_vpaidAPI.adVolume = value;
		}

	    // Methods
	    
	    /*

	    */
	    
	    /**
  			Function: handshakeVersion

			The player calls handshakeVersion immediately after loading the ad to indicate to the
			ad that VPAID will be used. The player passes in its latest VPAID version string. The ad
			returns a version string minimally set to “1.0”, and of the form “major.minor.patch”.
			The player must verify that it supports the particular version of VPAID or cancel the ad.

			Parameter: 
				playerVPAIDVersion - The VPAID version string the player is able to speak, given in the form of "major.minor.patch"

			Returns:
				adVPAIDversion - The VPAID version the ad speaks,  given in the form of "major.minor.patch"
		 * 
       	 *  @langversion 3.0
       	 *  @playerversion Flash 10
       	 *  @playerversion AIR 1.5
       	 *  @productversion OSMF 1.0
       	 **/ 
	    public function handshakeVersion(playerVPAIDVersion : String) : String
		{
			CONFIG::LOGGING
			{
				logger.debug("[VPAID] Player is calling handshakeversion on ad: Player version is "+ version);
			}
			try
			{
				adVersion = _vpaidAPI.handshakeVersion(playerVPAIDVersion);
			}
			catch (e:Error)
			{
				_vpaidElement.error();
			}
			
			return adVersion;
		}
	    
	    /**
			Function: initVPAID
	    
			After the ad is loaded and the player calls handshakeVersion, the player calls initVPAID to
			initialize the ad experience. The player may pre-load the ad and delay calling initVPAID
			until nearing the ad playback time, however, the ad does not load its assets until initVPAID
			is called.
			
			Parameters:
				width - Content players width, given as Number
				height - Content players width, given as Number
				viewMode - Content players current view mode, may be one of "normal", "thumbnail" or "fullscreen"
				desiredBitrate - Bitrate in kbps that the ad may use
				creativeData - optional parameter for passing in additional ad initialization data
				environmentVars - optional parameter for passing implementation-specific runtime variables
		 * 
       	 *  @langversion 3.0
       	 *  @playerversion Flash 10
       	 *  @playerversion AIR 1.5
       	 *  @productversion OSMF 1.0
       	 **/  
	    public function initVPAID(width : Number, height : Number, viewMode : String, desiredBitrate : Number, creativeData : String, environmentVars : String) : void {
			CONFIG::LOGGING
			{
				logger.debug("[VPAID] Player is calling initAd on ad. [width="+ width +", height="+height+", viewMode="+viewMode+", desiredBitrate="+desiredBitrate+", creativeData="+creativeData+", environmentVars="+environmentVars+"]");
			}
			addVPAIDSWFListeners();
			try
			{
				_vpaidAPI.initAd(width , height , viewMode , desiredBitrate , creativeData , environmentVars );
			}
			catch (e:Error)
			{
				_vpaidElement.error();
			}
		}

	    /**
			Function: resizeVPAID
			
			Following a resize of the ad UI container, the player calls resizeVPAID to allow the ad to
			scale or reposition itself within its display area. The width and height always matches
			the maximum display area allotted for the ad, and resizeVPAID is only called when the
			player changes its video content container sizing.
			
			Parameters:
				width - Content players width, given as Number
				height - Content players width, given as Number
				viewMode - "normal", "thumbnail" or "fullscreen"
		 * 
       	 *  @langversion 3.0
       	 *  @playerversion Flash 10
       	 *  @playerversion AIR 1.5
       	 *  @productversion OSMF 1.0
       	 **/
	    public function resizeVPAID(width : Number, height : Number, viewMode : String) : void {
			CONFIG::LOGGING
			{
				logger.debug("[VPAID] Player is calling resizeAd on ad: [width="+ width+", height="+height+" ,viewMode=" + viewMode);
			}
			try
			{
				_vpaidAPI.resizeAd(width , height , viewMode );
			}
			catch (e:Error)
			{
			
			}
		}
	    
  
	    /**
			Function: startVPAID
			
			Is called by the player and is called when the player wants the ad to start
			displaying.
		 * 
       	 *  @langversion 3.0
       	 *  @playerversion Flash 10
       	 *  @playerversion AIR 1.5
       	 *  @productversion OSMF 1.0
       	 **/ 
	    public function startVPAID() : void {
				CONFIG::LOGGING
			{
				logger.debug("[VPAID] Player is scalling startAd on ad");
			}
			try
			{
				_vpaidAPI.startAd();
			}
			catch (e:Error)
			{
				_vpaidElement.error();
			}
			
		}
	    
	    /**
			Function: stopVPAID
			
			Is called by the player when it will no longer display the ad. stopVPAID is also
			called if the player needs to cancel an ad.
		 * 
       	 *  @langversion 3.0
       	 *  @playerversion Flash 10
       	 *  @playerversion AIR 1.5
       	 *  @productversion OSMF 1.0
       	 **/
		public function stopVPAID() : void {
			CONFIG::LOGGING
			{
				logger.debug("[VPAID] Player is stopAd on ad");
			}
			try
			{
				_vpaidAPI.stopAd();
			}
			catch (e:Error)
			{
				_vpaidElement.error();
			}
		}   

	    
	   /**
			Function: pauseVPAID
			
			Is called to pause ad playback. 
		 * 
       	 *  @langversion 3.0
       	 *  @playerversion Flash 10
       	 *  @playerversion AIR 1.5
       	 *  @productversion OSMF 1.0
       	 **/
	    public function pauseVPAID() : void {
			try
			{
				_vpaidAPI.pauseAd();
			}
			catch (e:Error)
			{
				
			}
		}
	    

	    /**
			Function: resumeVPAID
			
			Is called to continue ad playback following a call to pauseVPAID.
		 * 
       	 *  @langversion 3.0
       	 *  @playerversion Flash 10
       	 *  @playerversion AIR 1.5
       	 *  @productversion OSMF 1.0
       	 **/
	    public function resumeVPAID() : void {
			try
			{
				_vpaidAPI.resumeAd();
			}
			catch (e:Error)
			{
				
			}
		}
	    
	    
	    /**
			Function: expandVPAID
			
			Is called by the player to request that the ad switch to its larger UI size.
		 * 
       	 *  @langversion 3.0
       	 *  @playerversion Flash 10
       	 *  @playerversion AIR 1.5
       	 *  @productversion OSMF 1.0
       	 **/
	    public function expandVPAID() : void {
			try
			{
				_vpaidAPI.expandAd();
			}
			catch (e:Error)
			{
				
			}
		}
	    
	    /**
			Function collapseVPAID
			
			Is called by the player to request that the ad return to its smallest UI size. 
		 * 
       	 *  @langversion 3.0
       	 *  @playerversion Flash 10
       	 *  @playerversion AIR 1.5
       	 *  @productversion OSMF 1.0
       	 **/
	    public function collapseVPAID() : void {
			try
			{
				_vpaidAPI.collapseAd();
			}
			catch (e:Error)
			{
				
			}
		}
		
		/**
					
			Returns: version - Returns the currently supported VPAID version.
		 * 
       	 *  @langversion 3.0
       	 *  @playerversion Flash 10
       	 *  @playerversion AIR 1.5
       	 *  @productversion OSMF 1.0
       	 **/
		public function get version():Number
		{
			return 1.1;
		}
		
		public function get api():Object
		{
			return _vpaidAPI;
		}
		
		CONFIG::LOGGING
		private static const logger:Logger = Log.getLogger("org.osmf.vpaid.model.VPAID_1_1");
	}
}
