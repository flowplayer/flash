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
package{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class VPAIDAd extends EventDispatcher implements IVPAID
	{
		//Vars
		private var _adRoot:MovieClip;
		private var _adLinear:Boolean = true;
		private var _adExpanded:Boolean;
		private var _adRemainingTime:Number;
		private var _adVolume:Number;
		private var	_adVPAIDVersion:String = "1.0";
		private var _playerVPAIDVersion:String;
		private var _adWidth:Number;
		private var _adHeight:Number;
		private var _adViewMode:String;
		private var _desiredBitrate:Number;
		private var _creativeData:String;
		private var _environmentVars:String;
		
		//VPAID 1.0 Variables
		private var _linear:Boolean;
		private var _expanded:Boolean;
		private var _hasQuartileEvents:Boolean;
		private var _remainingTime:Number;
		private var _closeTime:Number;
		private var _volume:Number;
		
		
		
		/**
		 * Constructor
		 * @param adRoot A reference to the mainTimeline of the creative swf. 
		 */
		public function VPAIDAd(adRoot:MovieClip)
		{
			trace("[VPAIDAd] VPAIDAd instance created");
			_adRoot = adRoot;
		
		}
		
		//Properties
		
		public function handshakeVersion(playerVPAIDVersion:String):String
		{
			
			return "1.1";
		}
		
		/**
		 * Starts the ad experience.  
		 * 
		 * @param width Indicates the width of the display area for the advertisement
		 * @param height Indicates the height of the display area for the advertisement
		 * @param viewMode Indicates the player current viewing mode as defined by the player.
		 */
		public function initAd(width:Number,height:Number,viewMode:String, desiredBitrate:Number, creativeData:String = null, environmentVars:String = null):void
		{
			
			trace("Init Ad");
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdLoaded));
		}
		
		/**
		 * Called when the player wants the advertisement to start displaying.
		 */
		public function startAd():void
		{
			trace("Start Ad");
			
			
			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdStarted));
			
		}
		
		/**
		 * Called by the player to allow the advertisement to scale or reposition itself within its display area.
		 * @param width
		 * @param height
		 * @param viewMode
		 */
		public function resizeAd(width:Number, height:Number, viewMode:String):void
		{
			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdLinearChange));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdUserAcceptInvitation));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdLinearChange));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdUserMinimize));		
			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdLog, {message:"This is a test Adlog message "}));	
		
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdImpression));		
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdVideoStart));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdVideoFirstQuartile));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdVideoMidpoint));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdVideoThirdQuartile));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdVideoComplete));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdClickThru));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdError));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdExpandedChange));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdPlaying));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdPaused));
			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdCreativeView));		
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdUnmute));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdMute));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdRewind));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdResume));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdFullscreen));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdExpand));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdCollapse));		
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdClose));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdStopped));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdUserClose));
			
		}
		
		/**
		 * Called when the player wants the advertisement to stop displaying.
		 */
		public function stopAd():void
		{
		}
		
		/**
		 * Called when the player wants the advertisement to pause.
		 */
		public function pauseAd():void
		{
			
		}
		
		/**
		 * Called when the player wants the advertisement to resume.
		 */
		public function resumeAd():void
		{
			
		}
		
		
		/**
		 * Called when user rollover or click a call to action.
		 */
		public function expandAd():void
		{
			
		}
		
		/**
		 * Called when user click close on an advertisement.
		 */
		public function collapseAd():void
		{
			
		}
		
		/**
		 * 
		 * @return 
		 */
		public function set adVolume(value:Number)
		{
			
		}		
		
		/**
		 * 
		 * @return 
		 */
		public function get adWidth():Number
		{
			return 320;
		}
		
		/**
		 * 
		 * @return 
		 */
		public function get adHeight():Number
		{
			return 240;
		}
		
		public function get adExpanded():Boolean
		{
			return false;
		}
		
		public function get adLinear():Boolean
		{
			return false;
		}
		
		public function get adVolume():Number
		{
			return 1;
		}
		
		public function get adRemainingTime():Number
		{
			return 30;
		}
		
	}
}
