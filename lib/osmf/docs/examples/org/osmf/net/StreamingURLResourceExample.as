package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.net.StreamType;
	import org.osmf.net.StreamingURLResource;
	
	public class StreamingURLResourceExample extends Sprite
	{
		public function StreamingURLResourceExample()
		{
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var mediaPlayerSprite:MediaPlayerSprite = new MediaPlayerSprite();
			var videoElement:VideoElement = new VideoElement();

			videoElement.resource = new StreamingURLResource("rtmp://cp34973.live.edgefcs.net/live/Flash_Live_Benchmark@632", StreamType.LIVE);
			
			addChild(mediaPlayerSprite);
			mediaPlayerSprite.media = videoElement;	
		}	
	}
} 