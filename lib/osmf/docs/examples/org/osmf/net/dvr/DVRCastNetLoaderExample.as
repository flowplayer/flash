package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.net.StreamType;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.net.dvr.DVRCastNetLoader;

	public class DVRCastNetLoaderExample extends Sprite
	{
		public function DVRCastNetLoaderExample()
		{
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var mediaPlayerSprite:MediaPlayerSprite = new MediaPlayerSprite();
			var netLoader:DVRCastNetLoader = new DVRCastNetLoader();
			var videoElement:VideoElement = new VideoElement(null, netLoader);

			var urlResource:StreamingURLResource = new StreamingURLResource("rtmp://example.com/dvrcast_origin/mystream", StreamType.DVR);
			
			videoElement.resource = urlResource;
			
			addChild(mediaPlayerSprite);
			mediaPlayerSprite.media = videoElement;	
		}	
	}
} 