package {

	import fl.controls.Slider;
	import fl.events.SliderEvent;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.DurationElement;
	import org.osmf.elements.ParallelElement;
	import org.osmf.elements.SerialElement;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MetadataEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.layout.ScaleMode;
	import org.osmf.media.*;
	import org.osmf.metadata.Metadata;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayTrait;
	import org.osmf.vpaid.elements.VPAIDElement;
	import org.osmf.vpaid.metadata.VPAIDMetadata;

	/**
	 * Sample OSMF Player
	 * 
	 * */
	[SWF(width="480",height="360", backgroundColor="0x333333")]
	public class VPAIDAdSequencingUnitTest extends Sprite
	{
		public static const OVERLAY_DELAY:Number = 5;
		public static const OVERLAY_MAX_LENGTH:Number = 10;
		
		private var container:MediaContainer;
		private var contentResource:URLResource;
		private var vpaidLinearResource:URLResource;
		private var vpaidNonLinearResource:URLResource;
		private var videoElement:MediaElement;
		private var mediaPlayer:MediaPlayer;
		private var mediaFactory:MediaFactory;
		private var pluginResource:PluginInfoResource;
		private var serialElement:SerialElement;
		private var parallelElement:ParallelElement;
		private var parallelElement2:ParallelElement;
		private var vpaidPrerollLinear:VPAIDElement;
		private var vpaidPrerollLinear2:VPAIDElement;
		private var vpaidPrerollLinear3:VPAIDElement;
		private var vpaidPostrollLinear:VPAIDElement;
		private var vpaidNonLinear:VPAIDElement;
		private var vpaidNonLinear2:VPAIDElement;
		private var vpaidNonLinear3:VPAIDElement;
		private var errorOccured:Boolean = false;
		private var overlayMaxLengthEnabled:Boolean = true;
		private var runOverlay:Boolean = false;
		private var traitInterval:Number;
		private var contentPlayTraitAdded:Boolean;
		
		private var playBtn:MovieClip;
		private var pauseBtn:MovieClip;
		private var fullscreenBtn:MovieClip;
		private var stopBtn:MovieClip;
		private var volSlider:Slider;
		private var muteBtn:MovieClip;
		private var unmuteBtn:MovieClip;
		
		private var vol:Number;	
		
        public static const NONLINEAR_VPAID:String      = 	"http://cdn1.eyewonder.com/200125/instream/_modules/loaders/Custom/VPAID_as3/loader.swf?adLoaderWidth=320&adLoaderHeight=240&cp=http://cdn1.eyewonder.com/200125/752457/1224933/&loaderCreative=Ticker_Holder_as3.swf%3Fcp%3Dhttp%3A//cdn1.eyewonder.com/200125/752457/1224933/%26ewbase%3Dhttp%3A//cdn1.eyewonder.com/200125/752457/1224933/%26adLoaderWidth%3D320%26adLoaderHeight%3D240%26hAlign%3Dcenter%26vAlign%3Dbottom%26keywordNames%3DenableFriendlyIframe%2Cinflow_iframe_div%26keywordIDs%3D[48]%2C[52]%26ewbust%3D[timestamp]&adInstreamType=ticker&adTagAlignHorizontal=center&adTagAlignVertical=bottom&adMode=prog&qaReportUUID=common";
        public static const LINEAR_VPAID:String         = 	"http://cdn1.eyewonder.com/200125/instream/_modules/loaders/Custom/VPAID_as3/loader.swf?adLoaderWidth=320&adLoaderHeight=240&cp=http://cdn.eyewonder.com/100125/754851/1262098/&loaderCreative=Linear_Interactive_Holder_as3.swf%3Fcp%3Dhttp%3A//cdn.eyewonder.com/100125/754851/1262098/%26ewbase%3Dhttp%3A//cdn.eyewonder.com/100125/754851/1262098/%26adLoaderWidth%3D300%26adLoaderHeight%3D225%26hAlign%3Dcenter%26vAlign%3Dmiddle%26keywordNames%3Dinstream_VAST_2_0_TEST%26keywordIDs%3D%5B103%5D%26ewbust%3D%5Btimestamp%5D&adInstreamType=fixedroll&adTagAlignHorizontal=center&adTagAlignVertical=middle&adMode=prog&qaReportUUID=common";
        //http://cdn1.eyewonder.com/200125/instream/_modules/loaders/Custom/VPAID_as3/loader.swf?adLoaderWidth=320&adLoaderHeight=240&cp=http://cdn.eyewonder.com/100125/754851/1262098/&loaderCreative=Linear_Interactive_Holder_as3.swf%3Fcp%3Dhttp%3A//cdn.eyewonder.com/100125/754851/1262098/%26ewbase%3Dhttp%3A//cdn.eyewonder.com/100125/754851/1262098/%26adLoaderWidth%3D300%26adLoaderHeight%3D225%26hAlign%3Dcenter%26vAlign%3Dmiddle%26keywordNames%3Dinstream_VAST_2_0_TEST%26keywordIDs%3D%5B103%5D%26ewbust%3D%5Btimestamp%5D&adInstreamType=fixedroll&adTagAlignHorizontal=center&adTagAlignVertical=middle&adMode=prog&qaReportUUID=common
        public static const WRONG_VERSION_LOW:String 	= 	"http://cdn1.eyewonder.com/200125/instream/documentation_test_tags/vpaid/as3/VPAID_1_0.swf?adLoaderWidth=320&adLoaderHeight=240&cp=http://cdn.eyewonder.com/100125/754851/1262098/&loaderCreative=Linear_Interactive_Holder_as3.swf%3Fcp%3Dhttp%3A//cdn.eyewonder.com/100125/754851/1262098/%26ewbase%3Dhttp%3A//cdn.eyewonder.com/100125/754851/1262098/%26adLoaderWidth%3D300%26adLoaderHeight%3D225%26hAlign%3Dcenter%26vAlign%3Dmiddle%26keywordNames%3Dinstream_VAST_2_0_TEST%26keywordIDs%3D%5B103%5D%26ewbust%3D%5Btimestamp%5D&adInstreamType=fixedroll&adTagAlignHorizontal=center&adTagAlignVertical=middle&adMode=prog&qaReportUUID=common";
        public static const WRONG_VERSION_HIGH:String 	= 	"http://cdn1.eyewonder.com/200125/instream/documentation_test_tags/vpaid/as3/VPAID_2_0.swf?adLoaderWidth=320&adLoaderHeight=240&cp=http://cdn.eyewonder.com/100125/754851/1262098/&loaderCreative=Linear_Interactive_Holder_as3.swf%3Fcp%3Dhttp%3A//cdn.eyewonder.com/100125/754851/1262098/%26ewbase%3Dhttp%3A//cdn.eyewonder.com/100125/754851/1262098/%26adLoaderWidth%3D300%26adLoaderHeight%3D225%26hAlign%3Dcenter%26vAlign%3Dmiddle%26keywordNames%3Dinstream_VAST_2_0_TEST%26keywordIDs%3D%5B103%5D%26ewbust%3D%5Btimestamp%5D&adInstreamType=fixedroll&adTagAlignHorizontal=center&adTagAlignVertical=middle&adMode=prog&qaReportUUID=common";
        public static const BROKEN:String 				= 	"http://cdn1.eyewonder.com/200125/instream/_modules/loaders/CustomVPAID_as3/loader.swf?adLoaderWidth=320&adLoaderHeight=240&cp=http://cdn.eyewonder.com/100125/754851/1262098/&loaderCreative=Linear_Interactive_Holder_as3.swf%3Fcp%3Dhttp%3A//cdn.eyewonder.com/100125/754851/1262098/%26ewbase%3Dhttp%3A//cdn.eyewonder.com/100125/754851/1262098/%26adLoaderWidth%3D300%26adLoaderHeight%3D225%26hAlign%3Dcenter%26vAlign%3Dmiddle%26keywordNames%3Dinstream_VAST_2_0_TEST%26keywordIDs%3D%5B103%5D%26ewbust%3D%5Btimestamp%5D&adInstreamType=fixedroll&adTagAlignHorizontal=center&adTagAlignVertical=middle&adMode=prog&qaReportUUID=common";
        public static const EMPTY:String 				= 	"http://cdn1.eyewonder.com/200125/instream/documentation_test_tags/vpaid/empty.swf?adLoaderWidth=320&adLoaderHeight=240&cp=http://cdn.eyewonder.com/100125/754851/1262098/&loaderCreative=Linear_Interactive_Holder_as3.swf%3Fcp%3Dhttp%3A//cdn.eyewonder.com/100125/754851/1262098/%26ewbase%3Dhttp%3A//cdn.eyewonder.com/100125/754851/1262098/%26adLoaderWidth%3D300%26adLoaderHeight%3D225%26hAlign%3Dcenter%26vAlign%3Dmiddle%26keywordNames%3Dinstream_VAST_2_0_TEST%26keywordIDs%3D%5B103%5D%26ewbust%3D%5Btimestamp%5D&adInstreamType=fixedroll&adTagAlignHorizontal=center&adTagAlignVertical=middle&adMode=prog&qaReportUUID=common";

		public static const CONTENT_VIDEO:String	= "rtmp://cp67126.edgefcs.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short";
		
		public function VPAIDAdSequencingUnitTest()
		{
			trace("Starting VPAIDTestplayer Video Player");
			//create a new instance of the mediaFactory to create a new video element
			mediaFactory = new DefaultMediaFactory();
			//create serialElement for content video and Ads to run concurrently
			serialElement = new SerialElement();
			
			//create ParallelElement so nonlinear Ads can run alongside the content video
			parallelElement = new ParallelElement();
			parallelElement2 = new ParallelElement();

			//create an instance of the media container for the videoElement
			container = new MediaContainer();
			container.layoutMetadata.width = 480;
			container.layoutMetadata.height = 360;
			container.layoutMetadata.scaleMode = ScaleMode.NONE;
			container.addMediaElement(serialElement);
			addChild(container);						
			
			createPlayerButtons();
			
			mediaPlayer = new MediaPlayer();
			mediaPlayer.autoPlay = false;
			mediaPlayer.volume = vol = (volSlider.value/10);
			mediaPlayer.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);			
			
			//create a new url resource including the path to a video as a parameter.
			contentResource = new URLResource(CONTENT_VIDEO);
			vpaidLinearResource = new URLResource(LINEAR_VPAID);
			vpaidNonLinearResource = new URLResource(NONLINEAR_VPAID);
			
			createVideoElement();
			createVPAIDAds();
			
			updateSerialElement("preroll/overlay");		
			updateMediaPlayer();
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
			addChild(volSlider);
			
			fullscreenBtn = new FullScreenButton();
			fullscreenBtn.y = playBtn.y;
			fullscreenBtn.x = volSlider.x + volSlider.width + 10;
			fullscreenBtn.visible = false; //Removed the full screen button.
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
		
		private function createVideoElement():void
		{
			trace("OSMFPlayer.createVideoElement()");
			//create a new video element passing it the url resource and add the element to the media container.
			videoElement = mediaFactory.createMediaElement(new URLResource(CONTENT_VIDEO));
			
			container.addMediaElement(videoElement);						

			playBtn.visible = true;
			pauseBtn.visible = false;
			playBtn.buttonMode = true;
			pauseBtn.buttonMode = true;
			stopBtn.buttonMode = true;
			
			playBtn.addEventListener(MouseEvent.CLICK, onPlayClicked);
			pauseBtn.addEventListener(MouseEvent.CLICK, onPauseClicked);
			stopBtn.addEventListener(MouseEvent.CLICK, onStopClicked);
			//fullscreenBtn.addEventListener(MouseEvent.CLICK, onFSClicked);
			volSlider.addEventListener(SliderEvent.CHANGE, onVolChanged);
			muteBtn.addEventListener(MouseEvent.CLICK, onMutePressed);
			unmuteBtn.addEventListener(MouseEvent.CLICK, onMutePressed);
		}
		
		private function createVPAIDAds():void
		{
			//create a new VPAIDElement passing it a urlResource for a linear Ad
			vpaidPrerollLinear = new VPAIDElement(vpaidLinearResource);
			container.addMediaElement(vpaidPrerollLinear);
			
			vpaidPrerollLinear2 = new VPAIDElement(vpaidLinearResource);
			container.addMediaElement(vpaidPrerollLinear2);
			
			vpaidPrerollLinear3 = new VPAIDElement(vpaidLinearResource);
			container.addMediaElement(vpaidPrerollLinear3);

			//create a new VPAIDElement passing it a urlResource for a linear Ad
			vpaidPostrollLinear = new VPAIDElement(vpaidLinearResource);
			container.addMediaElement(vpaidPostrollLinear);	
			
			//create a new VPAIDElement passing it a urlResource for a nonlinear Ad			
			vpaidNonLinear = new VPAIDElement(vpaidNonLinearResource);
			container.addMediaElement(vpaidNonLinear);
			
			vpaidNonLinear2 = new VPAIDElement(vpaidNonLinearResource);
			container.addMediaElement(vpaidNonLinear2);
			
			vpaidNonLinear3 = new VPAIDElement(vpaidNonLinearResource);
			container.addMediaElement(vpaidNonLinear3);
			
			/**
			 * 	In situations where publishers want to run both linear and nonlinear VPAIDElements,
				it is possible to attach VPAIDMetadata to the VPAIDElement to determine if its linear or nonlinear.
				One example may be creating a ParallelElement if it's a nonlinear VPAIDElement.
			 * */
			var vpaidOverlayMetadata:Metadata = vpaidNonLinear.getMetadata(VPAIDMetadata.NAMESPACE);
			vpaidOverlayMetadata.addEventListener(MetadataEvent.VALUE_ADD, onMetadataValueAdded);
			vpaidOverlayMetadata.addEventListener(MetadataEvent.VALUE_CHANGE, onMetadataValueChange);
			vpaidOverlayMetadata.addValue(VPAIDMetadata.NON_LINEAR_CREATIVE, true);
			
			var vpaidPrerollMetadata:Metadata = vpaidPrerollLinear.getMetadata(VPAIDMetadata.NAMESPACE);
			vpaidPrerollMetadata.addEventListener(MetadataEvent.VALUE_ADD, onMetadataValueAdded);
			
			var vpaidPrerollMetadata2:Metadata = vpaidPrerollLinear2.getMetadata(VPAIDMetadata.NAMESPACE);
			vpaidPrerollMetadata2.addEventListener(MetadataEvent.VALUE_ADD, onMetadataValueAdded);
			
			var vpaidPrerollMetadata3:Metadata = vpaidPrerollLinear3.getMetadata(VPAIDMetadata.NAMESPACE);
			vpaidPrerollMetadata3.addEventListener(MetadataEvent.VALUE_ADD, onMetadataValueAdded);
			
			var vpaidPostrollMetadata:Metadata = vpaidPostrollLinear.getMetadata(VPAIDMetadata.NAMESPACE);
			vpaidPostrollMetadata.addEventListener(MetadataEvent.VALUE_ADD, onMetadataValueAdded);
			
			getAdTraits();
		}
		
		private function getAdTraits():void
		{
			var prerollLoadTrait:LoadTrait = vpaidPrerollLinear.getTrait(MediaTraitType.LOAD) as LoadTrait;
			prerollLoadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
			
			var prerollLoadTrait2:LoadTrait = vpaidPrerollLinear2.getTrait(MediaTraitType.LOAD) as LoadTrait;
			prerollLoadTrait2.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
			
			var prerollLoadTrait3:LoadTrait = vpaidPrerollLinear3.getTrait(MediaTraitType.LOAD) as LoadTrait;
			prerollLoadTrait3.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
			
			var postrollLoadTrait:LoadTrait = vpaidPostrollLinear.getTrait(MediaTraitType.LOAD) as LoadTrait;
			postrollLoadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
			
			var overlayLoadTrait:LoadTrait = vpaidNonLinear.getTrait(MediaTraitType.LOAD) as LoadTrait;
			overlayLoadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
			
			var overlayPlayTrait:PlayTrait = vpaidNonLinear.getTrait(MediaTraitType.PLAY) as PlayTrait;
			overlayPlayTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
			
			var overlayLoadTrait2:LoadTrait = vpaidNonLinear.getTrait(MediaTraitType.LOAD) as LoadTrait;
			overlayLoadTrait2.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
			
			var overlayPlayTrait2:PlayTrait = vpaidNonLinear.getTrait(MediaTraitType.PLAY) as PlayTrait;
			overlayPlayTrait2.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
			
			var overlayLoadTrait3:LoadTrait = vpaidNonLinear.getTrait(MediaTraitType.LOAD) as LoadTrait;
			overlayLoadTrait3.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
			
			var overlayPlayTrait3:PlayTrait = vpaidNonLinear.getTrait(MediaTraitType.PLAY) as PlayTrait;
			overlayPlayTrait3.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
			
			var prerollPlayTrait:PlayTrait = vpaidPrerollLinear.getTrait(MediaTraitType.PLAY) as PlayTrait;
			prerollPlayTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
			
			var prerollPlayTrait2:PlayTrait = vpaidPrerollLinear2.getTrait(MediaTraitType.PLAY) as PlayTrait;
			prerollPlayTrait2.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
			
			var prerollPlayTrait3:PlayTrait = vpaidPrerollLinear3.getTrait(MediaTraitType.PLAY) as PlayTrait;
			prerollPlayTrait3.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
			
			var postrollPlayTrait:PlayTrait = vpaidPostrollLinear.getTrait(MediaTraitType.PLAY) as PlayTrait;
			postrollPlayTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
		}	
		
		/**
		 * This method accepts values based on the type of Ad sequence you want to run.
		 * @adSequence - String represent the requested Ad sequence.
		 * 
		 * Options: preroll, postroll, preroll/postroll, overlay, preroll/overlay
		 * 
		 * */
		private function updateSerialElement(adSequence:String = "preroll"):void
		{
			
			
			switch(adSequence)
			{
				case "preroll":
				 	serialElement.addChild(vpaidPrerollLinear);
					serialElement.addChild(vpaidPrerollLinear2);
					serialElement.addChild(vpaidPrerollLinear3);
				 	serialElement.addChild(videoElement);
				break;
				
				case "postroll":					
				 	serialElement.addChild(videoElement);
				 	serialElement.addChild(vpaidPostrollLinear);
				break;
				case "preroll/postroll" :
					serialElement.addChild(vpaidPrerollLinear);
					serialElement.addChild(vpaidPrerollLinear2);
				 	serialElement.addChild(videoElement);
					serialElement.addChild(vpaidPrerollLinear3);
				 	serialElement.addChild(vpaidPostrollLinear);
				break;
				
				case "overlay" :
				
					var newSerial1:SerialElement = new SerialElement();
					newSerial1.addChild(new DurationElement(OVERLAY_DELAY));
					newSerial1.addChild(vpaidNonLinear);
					
					var newSerial2:SerialElement = new SerialElement();
					newSerial2.addChild(new DurationElement(OVERLAY_DELAY));
					newSerial2.addChild(vpaidNonLinear);
					
					var newSerial3:SerialElement = new SerialElement();
					newSerial3.addChild(new DurationElement(OVERLAY_DELAY));
					newSerial3.addChild(vpaidNonLinear);
					
					if(vpaidNonLinear.getMetadata(VPAIDMetadata.NAMESPACE).getValue(VPAIDMetadata.NON_LINEAR_CREATIVE))
					{
						parallelElement.addChild(videoElement);
						parallelElement.addChild(newSerial1);
					}
					serialElement.addChild(vpaidPrerollLinear);
					serialElement.addChild(parallelElement);
					serialElement.addChild(new DurationElement(OVERLAY_DELAY));
				break;
				case "preroll/overlay" :
					
					var newSerial:SerialElement = new SerialElement();
					newSerial.addChild(new DurationElement(OVERLAY_DELAY));
					newSerial.addChild(vpaidNonLinear);
				
					if(vpaidNonLinear.getMetadata(VPAIDMetadata.NAMESPACE).getValue(VPAIDMetadata.NON_LINEAR_CREATIVE))
					{
						parallelElement.addChild(videoElement);
						parallelElement.addChild(newSerial);
					}
						
					serialElement.addChild(vpaidPrerollLinear);
					serialElement.addChild(parallelElement);
					serialElement.addChild(new DurationElement(OVERLAY_DELAY));
					serialElement.addChild(vpaidPostrollLinear);

				break;				
				default :
					serialElement.addChild(vpaidPrerollLinear);
				 	serialElement.addChild(videoElement);
				break;
				
			}
		}		
		
		private function updateMediaPlayer():void
		{
						
			//create an instance of the media player attaching the video element to it's media property.
			mediaPlayer.media = serialElement;
			trace("OSMFPlayer.createMediaPlayer("+ mediaPlayer.media +")");
		}
		
		private function onPlayClicked(e:MouseEvent):void
		{
			trace("OSMF_Player.onPlayClicked " );
					
			mediaPlayer.play();			
			playBtn.visible = false;
			pauseBtn.visible = true;
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
		
		private function onTraitAdd(e:MediaElementEvent):void
		{
			trace("OSMF_Player.onTraitAdd -  " + e.traitType);
			if(e.traitType == MediaTraitType.PLAY)
			{
				contentPlayTraitAdded = true;
				trace("OSMF_Player.onTraitAdd -- Content Play Trait Added " );
				playContent();

			}
        }

		
		private function onMediaError(e:MediaErrorEvent):void
		{
			trace("OSMF_Player.onMediaError - There is an error with the player or the specified media cannot be played ");
			mediaPlayer.media = videoElement;
			videoElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
		}
		/*
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
		*/
		private function onLoadStateChange(e:LoadEvent):void
		{
			trace("EWTestplayer.onLoadStateChange " + e.loadState);	
			if(e.loadState == LoadState.UNINITIALIZED)
			{
				vpaidPrerollLinear = null;
				trace("EWTestplayer.onLoadStateChange");	
			}

		}
		
		private function playContent():void
		{
			trace("Playing Content Video");
			mediaPlayer.play();
		}
		
		private function onMetadataValueAdded(e:MetadataEvent):void
		{
			trace("EWTestplayer.onMetadataValueAdded() " + e.key);
			if(e.key == "error")
			{
				mediaPlayer.media = videoElement;
				videoElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
			}	
		}
		
		private function onMetadataValueChange(e:MetadataEvent):void
		{
			trace("EWTestplayer.onMetadataValueChange() " + e.target.getValue(e.key));
		}		
		
		private function onContentLoadChange(e:LoadEvent):void
		{
			trace("EWTestplayer.onContentLoadChange() " + e.loadState);
		}	
		
		private function onPlayStateChange(e:PlayEvent):void
		{
			trace("EWTestplayer.onPlayStateChange " + e.playState);	
		}		
		
		private function onVolChanged(e:SliderEvent):void
		{
			trace("Slider Volume Changed " + (e.target.value/10) );
			var vol:Number = (e.target.value/10);
			mediaPlayer.volume = vol;
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
	}
}
