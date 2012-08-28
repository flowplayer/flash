package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import org.osmf.elements.VideoElement;
	import org.osmf.logging.Logger;
	import org.osmf.logging.Log;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;

	public class LoggerSample extends Sprite
	{
		public function LoggerSample()
		{
			super();
			
			Log.loggerFactory = new ExampleLoggerFactory(); 
			logger = Log.getLogger("LoggerSample");
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var mediaPlayerSprite:MediaPlayerSprite = new MediaPlayerSprite();
			var urlResource:URLResource = new URLResource("rtmp://cp67126.edgefcs.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short");
			var videoElement:VideoElement = new VideoElement(urlResource);
			
			addChild(mediaPlayerSprite);
			
			logger.debug("Ready to play video at " + urlResource.url.toString());
			mediaPlayerSprite.media = videoElement;	
		}
		
		private var logger:Logger;
	}
}
