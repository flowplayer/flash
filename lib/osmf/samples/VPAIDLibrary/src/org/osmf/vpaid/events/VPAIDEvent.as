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
package org.osmf.vpaid.events
{
	import flash.events.Event;
	
	/**
	 * An VPAIDEvent is the type of event that should be passed by the VPAID creative.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	 
	public class VPAIDEvent extends Event
	{
		public static const AdLoaded : String = "AdLoaded";
		public static const AdStarted : String = "AdStarted";
		public static const AdStopped : String = "AdStopped";
		public static const AdLinearChange : String = "AdLinearChange";
		public static const AdExpandedChange : String = "AdExpandedChange";
		public static const AdRemainingTimeChange : String= "AdRemainingTimeChange";
		public static const AdVolumeChange : String = "AdVolumeChange";
		public static const AdImpression : String = "AdImpression";
		public static const AdVideoStart : String = "AdVideoStart";
		public static const AdVideoFirstQuartile : String= "AdVideoFirstQuartile";
		public static const AdVideoMidpoint : String = "AdVideoMidpoint";
		public static const AdVideoThirdQuartile : String= "AdVideoThirdQuartile";
		public static const AdVideoComplete : String = "AdVideoComplete";
		public static const AdClickThru : String = "AdClickThru";
		public static const AdUserAcceptInvitation : String= "AdUserAcceptInvitation";
		public static const AdUserMinimize : String = "AdUserMinimize";
		public static const AdUserClose : String = "AdUserClose";
		public static const AdPaused : String = "AdPaused";
		public static const AdPlaying : String = "AdPlaying";
		public static const AdLog : String = "AdLog";
		public static const AdError : String = "AdError";
		private var _data:Object;
		public function VPAIDEvent(type:String, data:Object=null, bubbles:Boolean=false,cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			_data = data;
		}
		public function get data():Object 
		{
			return _data;
		}
	}
}
