package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;
	import org.osmf.net.NetLoader;
	
	public class NetLoaderExample extends Sprite
	{
		public function NetLoaderExample()
		{
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var mediaPlayerSprite:MediaPlayerSprite = new MediaPlayerSprite();
			var netLoader:NetLoader = new NetLoader();
			var urlResource:URLResource = new URLResource("rtmp://cp67126.edgefcs.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short");
			var videoElement:VideoElement = new VideoElement(urlResource, netLoader);
			
			addChild(mediaPlayerSprite);
			mediaPlayerSprite.media = videoElement;	
		}	
	}
} 