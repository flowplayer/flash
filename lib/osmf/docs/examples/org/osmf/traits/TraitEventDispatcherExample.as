package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import org.osmf.elements.VideoElement;
	import org.osmf.events.AudioEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;
	import org.osmf.traits.TraitEventDispatcher;
	
	public class TraitEventDispatcherExample extends Sprite
	{
		public function TraitEventDispatcherExample()
		{
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var mediaPlayerSprite:MediaPlayerSprite = new MediaPlayerSprite();
			var urlResource:URLResource = new URLResource("rtmp://cp67126.edgefcs.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short");
			var videoElement:VideoElement = new VideoElement();
			videoElement.resource = urlResource;

			var dispatcher:TraitEventDispatcher = new TraitEventDispatcher();
			dispatcher.media = videoElement;
						
			dispatcher.addEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange); 
			dispatcher.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange); 			

			addChild(mediaPlayerSprite);
			mediaPlayerSprite.media = videoElement;	
		}

		private function onVolumeChange(event:AudioEvent):void
		{
			trace("onVolumeChange");
		}

		private function onPlayStateChange(event:PlayEvent):void
		{
			trace("onPlayStateChange");
		}
	}
}
