/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*
*  Contributor(s): Eyewonder, LLC
*  
*****************************************************/

package
{
	import fl.controls.Slider;
	import fl.events.SliderEvent;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.SerialElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.events.*;
	import org.osmf.layout.ScaleMode;
	import org.osmf.mast.MASTPluginInfo;
	import org.osmf.mast.media.MASTProxyElement;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfoResource;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.*;
	import org.osmf.net.NetLoader;
	import org.osmf.traits.AudioTrait;
	import org.osmf.traits.MediaTraitType;

	[SWF(width="480",height="360", backgroundColor="0x333333")]
	public class MASTSample extends Sprite
	{
		public function MASTSample()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			mediaFactory = new DefaultMediaFactory();
            
  			// Create the Sprite class that holds our MediaPlayer.
  			// Set the Sprite's size to match that of the stage, and
			// prevent the content from being scaled.
 			sprite = new MediaContainer();		
			sprite.layoutMetadata.width = 480;
			sprite.layoutMetadata.height = 360;
			sprite.layoutMetadata.scaleMode = ScaleMode.NONE;	
			addChild(sprite);
			
			createPlayerButtons();
			
			mediaPlayer.volume = vol = volSlider.value/10;
			mediaPlayer.autoPlay = true;
			
			// Make sure we resize the Sprite when the stage dimensions
			// change.
			stage.addEventListener(Event.RESIZE, onStageResize);
			stage.addEventListener(Event.ADDED, onStageResize);
			
			playBtn.visible = false;
			pauseBtn.visible = true;
			playBtn.buttonMode = true;
			pauseBtn.buttonMode = true;
			stopBtn.buttonMode = true;
			
			playBtn.addEventListener(MouseEvent.CLICK, onPlayClicked);
			pauseBtn.addEventListener(MouseEvent.CLICK, onPauseClicked);
			stopBtn.addEventListener(MouseEvent.CLICK, onStopClicked);
			fullscreenBtn.addEventListener(MouseEvent.CLICK, onFSClicked);
			volSlider.addEventListener(SliderEvent.CHANGE, onVolChanged);
			muteBtn.addEventListener(MouseEvent.CLICK, onMutePressed);
			unmuteBtn.addEventListener(MouseEvent.CLICK, onMutePressed);
			
			loadPlugin(MAST_PLUGIN_INFOCLASS);
		}

		private function createPlayerButtons():void
		{
			playBtn = new PlayButton();
			playBtn.y = stage.stageHeight - (playBtn.height + 5);
			playBtn.x = 10;
			addChild(playBtn);
			
			stopBtn = new StopButton();
			stopBtn.y = playBtn.y;
			stopBtn.x = playBtn.x + playBtn.width + 5;
			addChild(stopBtn);
			
			pauseBtn = new PauseButton();
			pauseBtn.y = playBtn.y;
			pauseBtn.x = 10;
			pauseBtn.visible = false;
			addChild(pauseBtn);
			
			volSlider = new Slider();
			volSlider.y = playBtn.y + 20;
			volSlider.x = stopBtn.x + stopBtn.width + 10;
			volSlider.value = 7.5;
			vol = volSlider.value/10;
			addChild(volSlider);
			
			fullscreenBtn = new FullScreenButton();
			fullscreenBtn.y = playBtn.y;
			fullscreenBtn.x = volSlider.x + volSlider.width + 10;
			fullscreenBtn.visible = false;
			addChild(fullscreenBtn);
			
			muteBtn = new MuteButton();
			muteBtn.y = playBtn.y;
			muteBtn.x = fullscreenBtn.x + fullscreenBtn.width + 5;
			addChild(muteBtn);
			
			unmuteBtn = new UnmuteButton();
			unmuteBtn.y = muteBtn.y;
			unmuteBtn.x = muteBtn.x;
			unmuteBtn.visible = false;
			addChild(unmuteBtn);
		}
		
		private function loadPlugin(source:String):void
		{
			var pluginResource:MediaResourceBase;
			if (source.substr(0, 4) == "http" || source.substr(0, 4) == "file")
			{
				// This is a URL, create a URLResource
				pluginResource = new URLResource(source);
			}
			else
			{
				// Assume this is a class
				var pluginInfoRef:Class = getDefinitionByName(source) as Class;
				pluginResource = new PluginInfoResource(new pluginInfoRef);
			}
			
			loadPluginFromResource(pluginResource);			
		}
		
		private function loadPluginFromResource(pluginResource:MediaResourceBase):void
		{
			mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded);
			mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadFailed);
			mediaFactory.loadPlugin(pluginResource);
		}
		
		private function onPluginLoaded(event:MediaFactoryEvent):void
		{
			trace(">>> Plugin successfully loaded.");
			loadMainVideo(REMOTE_STREAM);
		}
		
		private function onPluginLoadFailed(event:MediaFactoryEvent):void
		{
			trace(">>> Plugin failed to load.");
		}
					
		private function loadMainVideo(url:String):void
		{	
			var resource:URLResource = new URLResource(url);

			// Assign to the resource the metadata that indicates that it should have a MAST
			// document applied (and include the URL of that MAST document).
			var metadata:Metadata = new Metadata();
			metadata.addValue(MASTPluginInfo.MAST_METADATA_KEY_URI, MAST_VAST_2_LINEAR_FLV);
			
			resource.addMetadataValue(MASTPluginInfo.MAST_METADATA_NAMESPACE, metadata);
			
			videoElement = mediaFactory.createMediaElement(resource);
			
			
			if (videoElement == null)
			{
				var netLoader:NetLoader = new NetLoader();
				// Add a default VideoElement
				mediaFactory.addItem(new MediaFactoryItem("org.osmf.elements.video", netLoader.canHandleResource, createVideoElement));
				videoElement = mediaFactory.createMediaElement(resource) as VideoElement;
			}
			
			sprite.addMediaElement(videoElement);
			mediaPlayer.media = videoElement;
			onStageResize();
			videoElement.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError, false, 0, true);
			

		}
		
		private function onTraitAdd(e:MediaElementEvent):void
		{
			trace("OSMF_Player.onTraitAdd -  " + e.traitType);
			if(e.traitType == MediaTraitType.PLAY)
			{
				
				trace("OSMF_Player.onTraitAdd -- Content Play Trait Added " );
				playContent();
			}
        }
        
        private function playContent():void
		{
			trace("Playing Content Video");
			mediaPlayer.play();
		}
		
		
		private function createVideoElement():MediaElement
		{
			return new VideoElement();
		}
		
   		private function onMediaError(event:MediaErrorEvent):void
   		{
   			var errMsg:String = "Media error : code="+event.error.errorID+" description="+event.error.message;
   			trace(errMsg);
   			
			
			var mediaElement:VideoElement = SerialElement(MASTProxyElement(videoElement).proxiedElement).getChildAt(1) as VideoElement;
			sprite.addMediaElement(mediaElement);
   			mediaPlayer.media = mediaElement;
   			
   			videoElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
   		}
		
		private function onStageResize(event:Event = null):void
		{
			sprite.layoutMetadata.width = stage.stageWidth;
			sprite.layoutMetadata.height = stage.stageHeight;
		}
		
		private function onMutePressed(event:MouseEvent):void
		{
			if(muteBtn.visible){
				muteBtn.visible = false;
				unmuteBtn.visible = true;
			}else{
				muteBtn.visible = true;
				unmuteBtn.visible = false;				
			}
			
			if(vol != 0)
			{
				if(mediaPlayer.muted){
					mediaPlayer.muted = false;		
				}else{
					mediaPlayer.muted = true;
				}
			}
			/*
			//This is the second use case for muting the VAST/VPAID creative
			if(mediaPlayer.volume != 0)
				mediaPlayer.volume	= 0;
			else
				mediaPlayer.volume = vol;
			*/
		}

		private function onPauseClicked(e:MouseEvent):void
		{
			mediaPlayer.pause();			
			pauseBtn.visible = false;
			playBtn.visible = true;
		}
		
		private function onStopClicked(e:MouseEvent):void
		{
			mediaPlayer.stop();
		}
		
		private function onPlayClicked(e:MouseEvent):void
		{
			trace("OSMF_Player.onPlayClicked " );		
			mediaPlayer.play();			
			playBtn.visible = false;
			pauseBtn.visible = true;
		}
		
		private function onFSClicked(e:MouseEvent):void
		{
			switch(stage.displayState) 
			{
                case "normal":
                    stage.displayState = "fullScreen";
                    break;
                case "fullScreen":
                default:
                    stage.displayState = "normal";
                    break;
            }
		}
		
		private function onVolChanged(e:SliderEvent):void
		{
			trace("In onVolChanged()");
			vol = (e.currentTarget.value/10);
			mediaPlayer.volume = vol;
			trace("Slider Volume Changed " + vol );
		}
		
		private var mediaFactory:MediaFactory;	
		private var sprite:MediaContainer;
		private var mediaPlayer:MediaPlayer = new MediaPlayer();
		private var vol:Number;
		private var playInMediaPlayer:MediaElement;
		private var mediaElementAudio:AudioTrait;
		private var videoElement:MediaElement;
		private var playBtn:MovieClip;
		private var pauseBtn:MovieClip;
		private var fullscreenBtn:MovieClip;
		private var stopBtn:MovieClip;
		private var volSlider:Slider;
		private var muteBtn:MovieClip;
		private var unmuteBtn:MovieClip;

		private static const MAST_PLUGIN_INFOCLASS:String = "org.osmf.mast.MASTPluginInfo";		
		private static const loadTestRef:MASTPluginInfo = null;
		
		// MAST documents
		// MAST documents
        private static const AKAMAI_MAST_URL_POSTROLL:String 		= "http://mediapm.edgesuite.net/osmf/content/mast/mast_sample_onitemend.xml";
        private static const AKAMAI_MAST_URL_PREROLL:String 		= "http://mediapm.edgesuite.net/osmf/content/mast/mast_sample_onitemstart.xml";
		private static const MAST_VAST_1_BROKEN_FLV:String					= "http://cdn1.eyewonder.com/200125/instream/osmf/mast_vast_1_linear_flv_broken.xml";
		private static const MAST_INVALID_VAST:String 				= "http://cdn1.eyewonder.com/200125/instream/osmf/mast_invalid_vast.xml";
		private static const MAST_VAST_1_LINEAR_FLV:String 			= "http://cdn1.eyewonder.com/200125/instream/osmf/mast_vast_1_linear_flv.xml";
		private static const MAST_VAST_1_WRAPPER:String 			= "http://cdn1.eyewonder.com/200125/instream/osmf/mast_vast_1_wrapper.xml";
		private static const MAST_VAST_2_BROKEN_FLV:String 			= "http://cdn1.eyewonder.com/200125/instream/osmf/mast_vast_2_broken_flv.xml";
		private static const MAST_VAST_2_BROKEN_VPAID:String 		= "http://cdn1.eyewonder.com/200125/instream/osmf/mast_vast_2_broken_vpaid.xml";
		private static const MAST_VAST_2_ENDLESS_WRAPPER:String 	= "http://cdn1.eyewonder.com/200125/instream/osmf/mast_vast_2_endless_wrapper.xml";
		private static const MAST_VAST_2_LINEAR_FLV:String 			= "http://cdn1.eyewonder.com/200125/instream/osmf/mast_vast_2_linear_flv_nonlinear_vpaid.xml";
		private static const MAST_VAST_2_LINEAR_VPAID:String 		= "http://cdn1.eyewonder.com/200125/instream/osmf/mast_vast_2_linear_vpaid.xml";
		private static const MAST_VAST_2_VPAID_TRACKING_TEST:String = "http://cdn1.eyewonder.com/200125/instream/osmf/mast_vast_2_linear_vpaid_tracking_test.xml";
		private static const MAST_VAST_2_NONLINEAR_VPAID:String 	= "http://cdn1.eyewonder.com/200125/instream/osmf/mast_vast_2_nonlinear_vpaid.xml?ewbust=12341234";
		private static const MAST_VAST_2_WRAPPER:String 			= "http://cdn1.eyewonder.com/200125/instream/osmf/mast_vast_2_wrapper.xml";
		
		private static const REMOTE_STREAM:String
			= "rtmp://cp67126.edgefcs.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short";
	}
}
