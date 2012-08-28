package {
	import fl.controls.Slider;
	import fl.events.SliderEvent;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.containers.MediaContainer;
	import org.osmf.events.ContainerChangeEvent;
	import org.osmf.elements.ProxyElement;
	import org.osmf.elements.SerialElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.events.LoaderEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.layout.ScaleMode;
	import org.osmf.media.*;
	import org.osmf.traits.AudioTrait;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.vast.loader.VASTLoadTrait;
	import org.osmf.vast.loader.VASTLoader;
	import org.osmf.vast.media.CompanionElement;
	import org.osmf.vast.media.VASTMediaGenerator;
	import org.osmf.events.TimeEvent;
	import org.osmf.traits.TimeTrait;
	
	/**
	 * Sample OSMF Player
	 * 
	 */
	[SWF(width="480",height="360", backgroundColor="0x333333")]
	public class VASTSample extends Sprite
	{
		public static const OVERLAY_DELAY:Number = 2;
		
		private var container:MediaContainer;
		private var contentResource:URLResource;
		private var videoElement:MediaElement;
		private var mediaPlayer:MediaPlayer;
		private var mediaFactory:MediaFactory;
		private var vastLoader:VASTLoader;
		private var vastLoadTrait:VASTLoadTrait;
		private var vastMediaGenerator:VASTMediaGenerator;
		private var playInMediaPlayer:MediaElement;
		private var mediaElementAudio:AudioTrait;
		private var serialElement:SerialElement;
		
		public static const CONTENT_VIDEO:String	= "rtmp://cp67126.edgefcs.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short";
		public static const MAX_NUMBER_REDIRECTS:int 		= 5;
		
		public static const INVALID_VAST:String 						= "http://cdn1.eyewonder.com/200125/instream/osmf/invalid_vast.xml";
		public static const VAST_1_LINEAR_FLV:String 					= "http://cdn1.eyewonder.com/200125/instream/osmf/vast_1_linear_flv.xml";
		public static const VAST_1_WRAPPER:String 						= "http://cdn1.eyewonder.com/200125/instream/osmf/vast_1_wrapper.xml";
		public static const VAST_2_BROKEN_FLV:String 					= "http://cdn1.eyewonder.com/200125/instream/osmf/vast_2_broken_flv.xml";
		public static const VAST_2_BROKEN_VPAID:String 					= "http://cdn1.eyewonder.com/200125/instream/osmf/vast_2_broken_vpaid.xml";
		public static const VAST_2_ENDLESS_WRAPPER:String 				= "http://cdn1.eyewonder.com/200125/instream/osmf/vast_2_endless_wrapper.xml";
		public static const VAST_2_LINEAR_FLV_NONLINEAR_VPAID:String 	= "http://cdn1.eyewonder.com/200125/instream/osmf/vast_2_linear_flv_nonlinear_vpaid.xml";
		public static const VAST_2_LINEAR_VPAID:String 					= "http://cdn1.eyewonder.com/200125/instream/osmf/vast_2_linear_vpaid.xml";
		public static const VAST_2_LINEAR_VPAID_TRACKING_TEST:String 	= "http://cdn1.eyewonder.com/200125/instream/osmf/vast_2_linear_vpaid_tracking_test.xml";
		public static const VAST_2_NONLINEAR_VPAID:String 				= "http://cdn1.eyewonder.com/200125/instream/osmf/vast_2_nonlinear_vpaid.xml";
		public static const VAST_2_WRAPPER:String 						= "http://cdn1.eyewonder.com/200125/instream/osmf/vast_2_wrapper.xml";
		
		public static const chosenFile:String =  VAST_1_LINEAR_FLV;	// Change me
		public static const chosenPlacement:String = VASTMediaGenerator.PLACEMENT_LINEAR;	// Change me
		
		private var vol:Number;
		
		private var playBtn:MovieClip;
		private var pauseBtn:MovieClip;
		private var fullscreenBtn:MovieClip;
		private var stopBtn:MovieClip;
		private var volSlider:Slider;
		private var muteBtn:MovieClip;
		private var unmuteBtn:MovieClip;
		
		public function VASTSample()
		{
			trace("Starting VAST2Sample Player");
			mediaPlayer = new MediaPlayer();
		
			//create an instance of the media container for the videoElement
			container = new MediaContainer();
			container.layoutMetadata.width = 480;
			container.layoutMetadata.height = 360;
			container.layoutMetadata.scaleMode = ScaleMode.NONE;
			addChild(container);			

			createPlayerButtons();
			
			playBtn.visible = true;
			pauseBtn.visible = false;
			playBtn.buttonMode = true;
			pauseBtn.buttonMode = true;
			stopBtn.buttonMode = true;
			fullscreenBtn.visible = false; //VAST2Sample doesn't support fullscreen.
			
			playBtn.addEventListener(MouseEvent.CLICK, onPlayClicked);
			pauseBtn.addEventListener(MouseEvent.CLICK, onPauseClicked);
			stopBtn.addEventListener(MouseEvent.CLICK, onStopClicked);
			//fullscreenBtn.addEventListener(MouseEvent.CLICK, onFSClicked);
			volSlider.addEventListener(SliderEvent.CHANGE, onVolChanged);	
			muteBtn.addEventListener(MouseEvent.CLICK, onMutePressed);
			unmuteBtn.addEventListener(MouseEvent.CLICK, onMutePressed);
			
			mediaFactory = new DefaultMediaFactory();
			serialElement = new SerialElement();
			
			mediaPlayer.volume = vol = volSlider.value/10;
			container.addMediaElement(serialElement);	
			
			//create a new url resource including the path to a video as a parameter.
			var vastResource:URLResource = new URLResource(chosenFile);
			vastLoader = new VASTLoader(MAX_NUMBER_REDIRECTS);
			vastLoadTrait = new VASTLoadTrait(vastLoader, vastResource);
			vastLoader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onVASTLoadStateChange);
			vastLoader.load(vastLoadTrait);
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
				
		private function onVASTLoadStateChange(event:LoaderEvent):void
		{
			trace("onVASTLoadStateChange " + event.newState);
			
			videoElement = mediaFactory.createMediaElement(new URLResource(CONTENT_VIDEO));
			container.addMediaElement(videoElement);
			
			if(event.newState == LoadState.READY)
			{
							
				vastMediaGenerator = new VASTMediaGenerator(null, mediaFactory);
				
				var vastElements:Vector.<MediaElement> = vastMediaGenerator.createMediaElements(vastLoadTrait.vastDocument, chosenPlacement);
				
				
				for each(var mediaElement:MediaElement in vastElements)
				{
					if(mediaElement is ProxyElement)
					{
						
						playInMediaPlayer = mediaElement;					
						serialElement.addChild(playInMediaPlayer);
						serialElement.addChild(videoElement);
						
					}
					if(mediaElement is CompanionElement)
						trace("Found Companion Element: " + mediaElement);
				}
				
				if (playInMediaPlayer != null)
				{
					container.addMediaElement(playInMediaPlayer);
					
					mediaPlayer = new MediaPlayer();
					mediaPlayer.autoPlay = false;
					mediaPlayer.volume = (volSlider.value/10);
					mediaPlayer.media = serialElement;
					mediaPlayer.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
				}
				else{
					trace("MediaElement not found! Check tag and placement for errors!");
					mediaPlayer.media = videoElement;
				}
			}
			else if(event.newState == LoadState.LOAD_ERROR)
			{
				mediaPlayer.media = videoElement;
				
				videoElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
			}

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
		
		private function loadDocument():void
		{
			
		}        
		
		private function onContainerChange(e:ContainerChangeEvent):void
		{
			trace("VAST2Sample.onContainerChange ");	
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
			
			if(vol != 0){
				if(mediaPlayer.muted){
					mediaPlayer.muted = false;	
				}else{
					mediaPlayer.muted = true;
				}
			}
		}
		
		private function onTimeComplete(e:TimeEvent):void
		{
			
			
		
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
			
			if(playInMediaPlayer != null)
			{
				var videoElement:MediaElement = MediaElement(ProxyElement(ProxyElement(playInMediaPlayer).proxiedElement).proxiedElement);
				var timeTrait:TimeTrait = videoElement.getTrait(MediaTraitType.TIME) as TimeTrait;
				timeTrait.addEventListener(TimeEvent.COMPLETE, onTimeComplete);
			}

					
			playBtn.visible = false;
			pauseBtn.visible = true;
		}
		
		private function onMediaError(e:MediaErrorEvent):void
		{
			trace("OSMF_Player.onMediaError - There is an error with the player or the specified media cannot be played ");
			mediaPlayer.media = videoElement;	
			videoElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
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
			vol = (e.currentTarget.value/10);
			mediaPlayer.volume = vol;
		}
	}
}
