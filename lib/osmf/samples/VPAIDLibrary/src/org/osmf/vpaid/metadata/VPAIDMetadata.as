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
package org.osmf.vpaid.metadata
{
	import org.osmf.metadata.Metadata;
	
	
	/**
	 * Because some of VPAID's properties, methods, and events
	 * do not fit into OSMF's built in traits, this class is provided 
	 * to allow publishers to access specific information such as 
	 * adLinear, adExpanded, contactAd(), and expandAd() etc.
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */  
	public class VPAIDMetadata extends Metadata
	{	
		
		//VPAID Method and Property calls	
		/**
		 * An event dispatched when publishers want to call the collapseAd() function
		 */
		public static const COLLAPSE_AD:String = "collapseAd";
		
		/**
		 * An event dispatched when publishers want to call the expandAd() function
		 */
		public static const EXPAND_AD:String = "expandAd";
		
		/**
		 * An event dispatched when publishers want to call the resize() function
		 */
		public static const RESIZE_AD:String = "resizeAd";
		
		/**
		 * An event dispatched when the creative's adLinear property is being changed
		 */
		public static const AD_LINEAR:String = "adLinear";
		
		/**
		 * An event dispatched when the creative's adExpanded property is being changed
		 */
		public static const AD_EXPANDED:String = "adExpanded";
		
		/**
		 * An event dispatched when...
		 */
		public static const NON_LINEAR_CREATIVE:String = "NonlinearCreative";
		
		/**
		 * An event dispatched when the creative has finished loading
		 */
		public static const AD_LOADED:String = "adLoaded"; 
		
		/**
		 * An event dispatched when the creative begins playing for the first
		 */
		public static const AD_STARTED:String = "adStarted"; 
		
		/**
		 * An event dispatched in order to stop the ad.
		 * Usually results in the running of the stopAd() function
		 */
		public static const AD_STOPPED:String = "adStopped";
		
		/**
		 * An event disptached with the purpose of stopping the ad and removing related
		 * event listeners and Objects.
		 * Results in the running of the endAd() function
		 */
		public static const END_AD:String = "endAd";
		
		/**
		 * An event dispatched when any error occurs within the creative.
		 */
		public static const ERROR:String = "error";
		
		/**
		 * An event that is dispatched whenever the time remaining in the playback of the creative
		 */
		public static const AD_REMAINING_TIME_CHANGE:String = "adRemainingTimeChange";
		
		/**
		 * An event dispatched when the adLinear property has been changed
		 */
		public static const AD_LINEAR_CHANGE:String = "adLinearChange";
		
		/**
		 * An event dispatched when the volume of the videoplayer running the VPAIDElement changes
		 */
		public static const AD_VOLUME_CHANGE:String = "adVolumeChange";
		
		/**
		 * An event dispatched when the videoplayer running the VPAIDElement is paused
		 */
		public static const AD_PAUSED:String = "adPaused"; 
		
		/**
		 * An event dispatched when the videoplayer running the VPAIDElement plays
		 */
		public static const AD_PLAYING:String = "adPlaying";
		
		//Tracking		
		/**
		 * A tracking event dispatched when expandAd() runs.
		 */
		public static const AD_EXPAND:String = "adExpand";
		
		/**
		 * A tracking event dispatched when collapseAd() runs.
		 */
		public static const AD_COLLAPSE:String = "adCollapse";
		

		/**
		 * A tracking event dispatched when the creative's Impression call is sent from the videoplayer
		 */ 
		public static const AD_IMPRESSION:String = "adImpression"; 
		
		/**
		 * A tracking event dispatched when the video has started playback
		 */
		public static const AD_VIDEO_START:String = "adVideoStart";
		
		/**
		 * A tracking event dispatched when the video has reached 25% completion
		 */
		public static const AD_VIDEO_FIRST_QUARTILE:String = "adVideoFirstQuartile";
		
		/**
		 * A tracking event dispatched when the video has reached 75% completion
		 */
		public static const AD_VIDEO_THIRD_QUARTILE:String = "adVideoThirdQuartile";			
		
		/**
		 * A tracking event dispatched when the video has reached 50% completion
		 */
		public static const AD_VIDEO_MID_POINT:String = "adVideoMidpoint";		
		
		/**
		 * A tracking event dispatched when the video has reached 100% completion
		 */
		public static const AD_VIDEO_COMPLETE:String = "adVideoComplete"; 


		/**
		 * An event dispatched when an error occurs during the load or playback of the ad
		 */
		public static const AD_ERROR:String = "adError";

		/**
		 * An event dispatched....
		 */
		public static const AD_CREATIVE_VIEW:String = "adCreativeView";	


		/**
		 * A tracking event dispatched when the user unmutes the creative
		 */
		public static const AD_UNMUTE:String = "adUnmute"; 
		
		/**
		 * A tracking event dispatched when the user mutes the creative
		 */
		public static const AD_MUTE:String = "adMute"; 
		
		/**
		 * A tracking event dispatched when the user seeks backwards in the creative
		 */
		public static const AD_REWIND:String = "adRewind";

		/**
		 * A tracking event dispatched when the user resumes playing a paused creative
		 */
		public static const AD_RESUME:String = "adResume";

		/**
		 * A tracking event dispatched when the user enters fullscreen
		 */
		public static const AD_FULLSCREEN:String = "adFullscreen";	

		/**
		 * A tracking event dispatched when the user peforms a clickthru on the creative
		 * Usually, this results in the user being taken to a new window where a new website will load.
		 */
		public static const AD_CLICKTRK:String = "adClickThru";

		/**
		 * A tracking event dispatched when the user interacts with a creative. Usually by mousing over, clicking,
		 * or following whatever prompt the creative calls for in order to delve deeper into the advertsement.
		 */
		public static const AD_USER_ACCEPT_INVITATION:String = "adUserAcceptInvitation"; 

		/**
		 * A tracking event dispatched when the user closes the creative.
		 * Only applicable to nonlinear creatives and linear interactive creatives.
		 */
		public static const AD_USER_CLOSE:String = "adUserClose"; 

		/**
		 * A tracking event dispatched when the user minimizes the creative
		 */
		public static const AD_USER_MINIMIZE:String = "adUserMinimize";

		/**
		 * A tracking event dispatched when creative is closed at the end of playback
		 * Only applicable to linear creatives
		 */
		public static const AD_CLOSE:String = "adClose";
		

		/**
		 * The package location of the VPAIDMetadata class
		 */
		public static const NAMESPACE:String = "org.osmf.vpaid.metadata.VPAIDMetadata";	

		/**
		 * Constructor
		 * 
		 * @param
		 */
		public function VPAIDMetadata()		
		{
			super();						
		}
	}
}
