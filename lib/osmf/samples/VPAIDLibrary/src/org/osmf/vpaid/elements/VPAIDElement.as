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
package org.osmf.vpaid.elements
{
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.system.Security;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.SWFElement;
	import org.osmf.elements.SWFLoader;
	import org.osmf.elements.loaderClasses.LoaderLoadTrait;
	import org.osmf.elements.loaderClasses.LoaderUtils;
	import org.osmf.events.AudioEvent;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MetadataEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.traits.AudioTrait;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.vpaid.events.VPAIDLoadEvent;
	import org.osmf.vpaid.metadata.VPAIDMetadata;
	import org.osmf.vpaid.model.IVPAIDBase;
	import org.osmf.vpaid.model.VPAID_1_1;
	import org.osmf.vpaid.traits.VPAIDLoadTrait;
	import org.osmf.vpaid.traits.VPAIDTimeTrait;
	
	CONFIG::LOGGING
	{
	import org.osmf.logging.Logger;
	import org.osmf.logging.Log;
	}
	
	/**
	 * VPAIDElement is a media element specifically created for presenting IAB compliant VPAID SWFs.
	 * <p>The VPAIDElement uses a standard SWFLoader class to load and unload its media. <p>
	 * 
	 * @see org.osmf.elements.SWFLoader
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	 
	
	public class VPAIDElement extends SWFElement
	{
		public function VPAIDElement(resource:URLResource, loader:SWFLoader = null)
		{
			Security.allowDomain("*");
			super(resource, loader);
			
			_vpaidMetadata = new VPAIDMetadata();
			_vpaidMetadata.addEventListener(MetadataEvent.VALUE_CHANGE, onMetadataValueChanged);
			_vpaidMetadata.addEventListener(MetadataEvent.VALUE_ADD, onMetadataValueAdded);
			_vpaidMetadata.addEventListener(MetadataEvent.VALUE_REMOVE, onMetadataValueRemoved);
			addMetadata(VPAIDMetadata.NAMESPACE, _vpaidMetadata);
			
			_loadTrait = getTrait(MediaTraitType.LOAD) as VPAIDLoadTrait;
			_loadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
			_loadTrait.addEventListener(VPAIDLoadEvent.INITIALIZE_VPAID, onSWFLoad);	

			_playTrait = new PlayTrait();
			addTrait(MediaTraitType.PLAY, _playTrait);
			
			_audioTrait = new AudioTrait();		
			addTrait(MediaTraitType.AUDIO, _audioTrait);
			

		}
		
		//Once the SWF is loaded we need to figure out the VPAID version
		//the creative supports and the load the correct module.
		private function vpaidHandshakeTest():void
		{
			var _testResult:Boolean = false;
			for each (var version:String in _supportedVersion)
			{
				CONFIG::LOGGING
				{
					logger.debug("[VPAID] Testing HandshakeVersion: "+ version);
				}
				if (_testResult == false){
					_testResult = probeVersion(version);
				}else{
					break;
				}
			}
			if (_testResult){
				//found a handshake
				CONFIG::LOGGING
				{
					logger.debug("[VPAID] Matching HandshakeVersion, ad responded: "+ _vpaid.version +" - ok");
				}
				//Module is ready time to initalize the creative.
				initVPAID();
			}else{
				CONFIG::LOGGING
				{
					logger.debug("[VPAID] Unsupported VPAID API version ");
				}
				_vpaidMetadata.addValue(VPAIDMetadata.ERROR, VPAIDMetadata.ERROR); 
				removeListeners();
			}
		}
		
		private function probeVersion(versionToTest:String):Boolean
		{
			var result:Boolean = false;
			var vpaidSWF:Object = _loadTrait.loader.contentLoaderInfo.content;
			
			switch(versionToTest)
			{
				case "1.0":
					//TODO: Add support for VPAID 1.0
					break;
				case "1.1":
					_vpaid = new VPAID_1_1(vpaidSWF, this);
					result = _vpaid.probeVersion();
					handshakePerformed = true;
					break;	
			}
			return result;
		}		
		
		//Need to add listeners to important VPAID events once the creative is initalized
		private function initVPAID():void 
		{
			
			addEventListener("AdStarted", onAdStarted);
			addEventListener("AdLoaded", onAdLoaded);
			addEventListener("AdStopped", onAdStopped);
			
			addEventListener("AdRemainingTimeChange", onAdTimeChange);
			addEventListener("AdLinearChange", onAdLinearChange);
			
			addEventListener("AdExpandedChange", onAdExpandedChange)
			addEventListener("AdClickThru", onClickThruChange);
			addEventListener("AdUserAcceptInvitation", onVPAIDEventReceived);
			addEventListener("AdUserMinimize", onVPAIDEventReceived);
			addEventListener("AdUserClose", onVPAIDEventReceived);
			
			addEventListener("AdCreativeView", onVPAIDEventReceived);
			
			addEventListener("AdPlaying", onAdPlayPause);
			addEventListener("AdPaused", onAdPlayPause);
			addEventListener("AdImpression", onVPAIDEventReceived);
			addEventListener("AdVolumeChange", onVPAIDEventReceived);
			addEventListener("AdVideoStart", onVPAIDEventReceived);
			addEventListener("AdVideoFirstQuartile", onVPAIDEventReceived);
			addEventListener("AdVideoMidpoint", onVPAIDEventReceived);
			addEventListener("AdVideoThirdQuartile", onVPAIDEventReceived);
			addEventListener("AdVideoComplete", onVPAIDEventReceived);
			addEventListener("AdLog", onVPAIDEventReceived);
			addEventListener("AdError", onVPAIDEventReceived);
						
			
			//pre VPAID specifciation diagram, we need to get the linear state of the creative before we call initAd
			_vpaidMetadata.addValue(VPAIDMetadata.AD_LINEAR, _vpaid.linearVPAID); 
			//This stores the inital linear start of the creative so that we can see if it is a linear (preroll) or nonlinear (ticker) creative.
			//It can also be set by the publisher if they know were in the content video this creative is placed.
			_vpaidMetadata.addValue(VPAIDMetadata.NON_LINEAR_CREATIVE, !_vpaid.linearVPAID); 
			
			if(_vpaid.linearVPAID)
			{
				//only add time trait for linear ads
				_timeTrait = new VPAIDTimeTrait();		
				addTrait(MediaTraitType.TIME, _timeTrait);
					
				_timeTrait.addEventListener(TimeEvent.COMPLETE, onTimerChange);
				_timeTrait.addEventListener(TimeEvent.DURATION_CHANGE, onTimerChange);			
			}

			_vpaid.initVPAID(getDimensions().width,getDimensions().height,"normal", 500, "", "");
		}
		
		private function onVPAIDEventReceived(event:Object):void
		{
			CONFIG::LOGGING
			{
				logger.debug("[VPAID] onVPAIDEventReceived: event.type=" + event.type);
			}
			switch(event.type)
			{
				
				case "AdCreativeView":
					_vpaidMetadata.addValue(VPAIDMetadata.AD_CREATIVE_VIEW, event); 
				break;
				
				case "AdImpression":
					_vpaidMetadata.addValue(VPAIDMetadata.AD_IMPRESSION, event); 
				break;
				
				case "AdVideoStart":
					_vpaidMetadata.addValue(VPAIDMetadata.AD_VIDEO_START, event); 
				break;
				
				case "AdVideoFirstQuartile":
					_vpaidMetadata.addValue(VPAIDMetadata.AD_VIDEO_FIRST_QUARTILE, event); 
				break;
				
				case "AdVideoMidpoint":
					_vpaidMetadata.addValue(VPAIDMetadata.AD_VIDEO_MID_POINT, event); 
				break;
				
				case "AdVideoThirdQuartile":
					_vpaidMetadata.addValue(VPAIDMetadata.AD_VIDEO_THIRD_QUARTILE, event); 
				break;
				
				case "AdVideoComplete":
					_vpaidMetadata.addValue(VPAIDMetadata.AD_VIDEO_COMPLETE,event); 
				break;
				
				case"AdUserAcceptInvitation":
					
					_vpaidMetadata.addValue(VPAIDMetadata.AD_USER_ACCEPT_INVITATION, event);
				break;
				
				case"AdUserMinimize":
					
					_vpaidMetadata.addValue(VPAIDMetadata.AD_USER_MINIMIZE, event);
				break;
				
				case"AdUserClose":
					
					_vpaidMetadata.addValue(VPAIDMetadata.AD_USER_CLOSE, event);
		
				break;								
				
				case "AdError":
					if(!handshakePerformed)
						_vpaidMetadata.addValue(VPAIDMetadata.AD_ERROR,event); 
				break;
				
				case "AdLog":
					var success:Boolean = false;
					try
					{
						if (event.hasOwnProperty("data"))
						{
							if (event.data.hasOwnProperty("message"))
							{
								var msg:String = event.data.message.toString();
								if (msg != null)
								{
									CONFIG::LOGGING
									{
										logger.debug("[VPAID creative] " + msg);
									}
									success = true;
								}
							}
						}
					}
					catch(e:Event)
					{
					}
					
					CONFIG::LOGGING
					{
						if (success == false)
						{
							logger.debug("[VPAID] Invalid AdLog event sent from creative. event.data not defined. Check creative.");
						}
					}
				break;
				
			}
			
		}
		
		//The creative needs height and width to scale to.
		private function getDimensions():Rectangle
		{
			var height:int;
			var width:int;
			
			var vpaidContainer:MediaContainer = container as MediaContainer;
			var displayObject:DisplayObjectTrait = this.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
			
			if(vpaidContainer != null){
				width = vpaidContainer.width;
				height = vpaidContainer.height;
			//Sometimes we can't find the container
			}else if(displayObject != null){
				width = displayObject.mediaWidth;
				height = displayObject.mediaHeight;
			//Default to size of the creative coming into the VPAIDElement
			}else if (_MASTWidth > -1)
			{
				// Not sure why this works for MAST (except if you resize the container)
				width = _MASTWidth;
				height = _MASTHeight;
			}
			else{
				width = _loadTrait.loader.contentLoaderInfo.content.width;
				height = _loadTrait.loader.contentLoaderInfo.content.height;
			}
			
			CONFIG::LOGGING
			{
				logger.debug("[VPAID] getDimensions width:" + width + " height: " + height);
			}
			
			return new Rectangle(0,0,width, height);		
		}
		
		//collapses or expands Ad based on the parameter passed to it
		private function collapseAd(value:Boolean):void
		{
			if(value)
			{
				_vpaid.collapseVPAID();
				_vpaidMetadata.addValue(VPAIDMetadata.AD_COLLAPSE, true);
			}				
			else
			{
				_vpaid.expandVPAID();
				_vpaidMetadata.addValue(VPAIDMetadata.AD_EXPAND, true);
			}
				
		}
		
		//removes all event listeners
		private function removeListeners():void
		{
			
			
			removeEventListener("AdStarted", onAdStarted);
			removeEventListener("AdLoaded", onAdLoaded);
			removeEventListener("AdStopped", onAdStopped);
			removeEventListener("AdError", onAdStopped);
			removeEventListener("AdRemainingTimeChange", onAdTimeChange);
			removeEventListener("AdLinearChange", onAdLinearChange);
			
			removeEventListener("AdExpandedChange", onAdExpandedChange)
			removeEventListener("AdClickThru", onClickThruChange);
			removeEventListener("AdUserAcceptInvitation", onVPAIDEventReceived);
			removeEventListener("AdUserMinimize", onVPAIDEventReceived);
			removeEventListener("AdUserClose", onVPAIDEventReceived);
			
			removeEventListener("AdCreativeView", onVPAIDEventReceived);
			
			removeEventListener("AdPlaying", onAdPlayPause);
			removeEventListener("AdPaused", onAdPlayPause);
			removeEventListener("AdImpression", onVPAIDEventReceived);
			removeEventListener("AdVolumeChange", onVPAIDEventReceived);
			removeEventListener("AdVideoStart", onVPAIDEventReceived);
			removeEventListener("AdVideoFirstQuartile", onVPAIDEventReceived);
			removeEventListener("AdVideoMidpoint", onVPAIDEventReceived);
			removeEventListener("AdVideoThridQuartile", onVPAIDEventReceived);
			removeEventListener("AdVideoComplete", onVPAIDEventReceived);	
			
			_audioTrait.removeEventListener(AudioEvent.MUTED_CHANGE, onAudioChange);
			_audioTrait.removeEventListener(AudioEvent.VOLUME_CHANGE, onAudioChange);	
			_playTrait.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);		
			
			_vpaidMetadata.removeEventListener(MetadataEvent.VALUE_CHANGE, onMetadataValueChanged);
			_vpaidMetadata.removeEventListener(MetadataEvent.VALUE_ADD, onMetadataValueAdded);
			_vpaidMetadata.removeEventListener(MetadataEvent.VALUE_REMOVE, onMetadataValueRemoved);
			_loadTrait.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
			if(_timeTrait)
			{
				_timeTrait.removeEventListener(TimeEvent.COMPLETE, onTimerChange);
				_timeTrait.removeEventListener(TimeEvent.DURATION_CHANGE, onTimerChange);	
			}
		}
		
		//The VPAID swf is loaded, time to start up the VPAID before dispatching READY
		private function onSWFLoad(event:VPAIDLoadEvent):void
		{
			CONFIG::LOGGING
			{
				logger.debug("[VPAID] Initalizing VPAID");
			}
			_loadTrait.removeEventListener(VPAIDLoadEvent.INITIALIZE_VPAID, onSWFLoad);
			vpaidHandshakeTest();
		}
		
		private function onLoadStateChange(event:LoadEvent):void
		{			
			CONFIG::LOGGING
			{
				logger.debug("[VPAID] LoadState Change: " + event.loadState);
			}
			if(event.loadState == LoadState.READY)
			{
				_vpaid.resizeVPAID(getDimensions().width,getDimensions().height, "normal");	
			}
							
		}
		
		private function onTimerChange(event:TimeEvent):void
		{
			//trace(event.type +"time: "+ event.time);	
		}
		
		private function onPlayStateChange(event:PlayEvent):void 
		{
			//Do not react to playstate changes for nonlinear creatives because you can't play/pause the creative
			CONFIG::LOGGING
			{
				logger.debug("[VPAID] PlayState Change: " + event.playState);
			}
			var nonlinear:Boolean = _vpaidMetadata.getValue(VPAIDMetadata.NON_LINEAR_CREATIVE);

			
			switch(event.playState)
			{
				case PlayState.PLAYING:
					if(_firstRun){
						_firstRun = false;
						_vpaid.startVPAID();						
					}else if(!nonlinear){
						_vpaid.resumeVPAID();
					}
				break; 
				case PlayState.PAUSED:
					if(!nonlinear)
						_vpaid.pauseVPAID();
				break;
				case PlayState.STOPPED:
					_vpaid.stopVPAID();
					
					if(_vpaidMetadata.getValue(VPAIDMetadata.NON_LINEAR_CREATIVE))
						cleanUp();
				break;
			}
		}

		private function onAudioChange(event:AudioEvent):void {
			if(event.type == AudioEvent.MUTED_CHANGE )
			{
				CONFIG::LOGGING
				{
					logger.debug("[VPAID] Audio Change: event.muted=" + event.muted);
				}
				if(event.muted)
					_vpaid.volumeVPAID = 0;
				else
					_vpaid.volumeVPAID = _audioTrait.volume;
			}else{
				CONFIG::LOGGING
				{
					logger.debug("[VPAID] Audio Change: event.volume=" + event.volume);
				}
				_vpaid.volumeVPAID = event.volume;
				_vpaidMetadata.addValue(VPAIDMetadata.AD_VOLUME_CHANGE, event.volume);
			}	
			
		}	
		
		private function onMetadataValueChanged(e:MetadataEvent):void
		{
			switch(e.key)
			{
				
				case VPAIDMetadata.RESIZE_AD :
					var dataObj:Object = e.value as Object;
					_vpaid.resizeVPAID(dataObj.width, dataObj.height, dataObj.viewMode);
				break;
				
				case VPAIDMetadata.COLLAPSE_AD :
					var collapse:Boolean = e.value as Boolean;
					collapseAd(collapse);
				break;
				
				case VPAIDMetadata.NON_LINEAR_CREATIVE :
				
				break;
			}
		}
		
		private function onMetadataValueAdded(e:MetadataEvent):void
		{

			switch(e.key)
			{
				
				case VPAIDMetadata.RESIZE_AD :
					var dataObj:Object = e.value as Object;
					_vpaid.resizeVPAID(dataObj.width, dataObj.height, dataObj.viewMode);				
				break;
				
				case VPAIDMetadata.COLLAPSE_AD :
					var collapse:Boolean = e.value as Boolean;
					collapseAd(collapse);				
				break;
				
				
				case VPAIDMetadata.AD_LINEAR :
				
				break;
				
				case VPAIDMetadata.NON_LINEAR_CREATIVE :
				
				break;
				
			}
		}
		
		private function onMetadataValueRemoved(e:MetadataEvent):void
		{
			switch(e.key)
			{

				case VPAIDMetadata.RESIZE_AD :
				
				break;
				
				case VPAIDMetadata.COLLAPSE_AD :
				
				break;
				
				case VPAIDMetadata.AD_EXPANDED :
				
				break;
				
				case VPAIDMetadata.AD_LINEAR :
				
				break;
				
				case VPAIDMetadata.NON_LINEAR_CREATIVE :
				
				break;
				
			}
		}	

		//Need to create a customer loaderTrait so we can delay the READY until the VPAID creative sends out AdLoaded Event
		override protected function createLoadTrait(resource:MediaResourceBase, loader:LoaderBase):LoadTrait
		{
			return new VPAIDLoadTrait(loader, resource);
		}
		
		override protected function processUnloadingState():void
		{
			CONFIG::LOGGING
			{
				logger.debug("[VPAID] VPAIDElement.ProcessUnloadingState");
			}
			removeTrait(MediaTraitType.DISPLAY_OBJECT);
		}

		/**
		 * @private 
		 */ 	
		override protected function processReadyState():void
		{
			//Do nothing, because we add the creative swf to the DisplayObjectTrait when the ad calls AdStarted.
		}

		
		//We can now dispatch READY and change the PlayState to Playing if the player wants us to play.
		private function onAdLoaded(event:Event):void
		{
			CONFIG::LOGGING
			{
				logger.debug("[VPAID] VPAIDElement.onAdLoaded() ");
			}
			
			_vpaidMetadata.addValue(VPAIDMetadata.AD_CREATIVE_VIEW, event);  
			removeEventListener("AdLoaded", onAdLoaded);
			_audioTrait.addEventListener(AudioEvent.MUTED_CHANGE, onAudioChange);
			_audioTrait.addEventListener(AudioEvent.VOLUME_CHANGE, onAudioChange);	
			_vpaid.volumeVPAID = _audioTrait.volume;
			_vpaidMetadata.addValue(VPAIDMetadata.AD_EXPANDED, _vpaid.expandedVPAID);
			
			if(_playTrait.playState == PlayState.PLAYING || _vpaidMetadata.getValue(VPAIDMetadata.NON_LINEAR_CREATIVE))
			{
				if(_firstRun){
					_firstRun = false;
					_vpaid.startVPAID();						
				}
			}
			
			_playTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
			
			
			_loadTrait.vpaidReady();

			
		}
		
		private function onAdStopped(event:Event):void
		{
			_vpaidMetadata.addValue(VPAIDMetadata.AD_STOPPED, event); 
			if(_timeTrait)
				_timeTrait.updateRemainingTime(0);
			
			if(!_vpaidMetadata.getValue(VPAIDMetadata.NON_LINEAR_CREATIVE))
				cleanUp();
		}
		
		//Add the SWF to the display list and resize the Ad after it is started to get new values
		private function onAdStarted(event:Event):void
		{
			
			removeEventListener("AdStarted", onAdStarted);
			var loaderLoadTrait:LoaderLoadTrait = getTrait(MediaTraitType.LOAD) as LoaderLoadTrait;
			addTrait(MediaTraitType.DISPLAY_OBJECT, LoaderUtils.createDisplayObjectTrait(loaderLoadTrait.loader, this));
			_vpaid.resizeVPAID(getDimensions().width, getDimensions().height, "normal");
		}
		
		private function onAdTimeChange(event:Event):void
		{
			
			if(_vpaid.remainingTimeVPAID >= 0 && _timeTrait != null)
				_timeTrait.updateRemainingTime(_vpaid.remainingTimeVPAID);
		}
		
		private function onAdLinearChange(event:Event):void
		{
			CONFIG::LOGGING
			{
				logger.debug("[VPAID] onAdLinearChange");
			}
			
			_vpaidMetadata.addValue(VPAIDMetadata.AD_LINEAR, _vpaid.linearVPAID);
			if(_vpaidMetadata.getValue(VPAIDMetadata.NON_LINEAR_CREATIVE))
			{
				if(_vpaid.linearVPAID)
				{
					//Pause content video					
					_playTrait.pause();
				}else{
					//Play content video					
					_playTrait.play();
				}
				return;
			}
			
			if(_timeTrait != null )
			{
				if(_vpaid.linearVPAID){
					_timeTrait.resumeTimer();			
				}else{
					_timeTrait.pauseTimer();
				}
			}
		
		}
		
		private function onAdExpandedChange(event:Event):void
		{
			
			_vpaidMetadata.addValue(VPAIDMetadata.AD_EXPANDED, _vpaid.expandedVPAID);
		}
		
		private function onClickThruChange(event:Event):void
		{
			_vpaidMetadata.addValue(VPAIDMetadata.AD_CLICKTRK, event);
		}

		
		private function onAdPlayPause(event:Event):void
		{
			if(_vpaid.linearVPAID)
			{
				if(_timeTrait)
				{
					if(event.type == "AdPaused")
					{
						_timeTrait.pauseTimer();
						_vpaidMetadata.addValue(VPAIDMetadata.AD_PAUSED, event); 
					}	
						
					if(event.type == "AdPlaying")
					{
						_timeTrait.resumeTimer();
						_vpaidMetadata.addValue(VPAIDMetadata.AD_PLAYING, event); 
					}	
						
				}

			}
		}
	
		private function cleanUp():void
		{
			if(_playTrait.playState != PlayState.STOPPED)
				_playTrait.stop();
			
			_loadTrait.unload();
				
			removeListeners();
			
		}
		
		/**
		 * Prints out the error message and cleans up the current VPAIDElement.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function error(message:String = ""):void
		{
			CONFIG::LOGGING
			{
				logger.debug("[VPAID] Error: " + message);
			}
			cleanUp();
		}
		
		/**
		 * Provides access to the VPAIDMetadata associated with this VPAIDElemnt
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function vpaidMetadata():VPAIDMetadata
		{
			return _vpaidMetadata;
		}
		
		private var handshakePerformed:Boolean = false;
		private var _suppressPlaying:Boolean = true;
		private var _playTrait:PlayTrait;
		private var _loadTrait:VPAIDLoadTrait;
		private var _timeTrait:VPAIDTimeTrait;
		private var _audioTrait:AudioTrait;
		private var _vpaidMetadata:VPAIDMetadata;
		private var _vpaid:IVPAIDBase;
		private var _supportedVersion:Array = ["1.1"];
		private var _firstRun:Boolean = true;
		
		// Just temporary, for MASTProxyElement to make initial size be correct(should use Metadata in the future)
		private var _MASTWidth:Number = -1;
		private var _MASTHeight:Number = -1;	
		public function get MASTWidth():Number
		{
			return _MASTWidth;
		}
		public function get MASTHeight():Number
		{
			return _MASTHeight;
		}
		public function set MASTWidth(val:Number):void
		{
			_MASTWidth = val;
		}
		public function set MASTHeight(val:Number):void
		{
			_MASTHeight = val;
		}
		
		CONFIG::LOGGING
		private static const logger:Logger = Log.getLogger("org.osmf.vpaid.elements.VPAIDElement");
	}
	
}
