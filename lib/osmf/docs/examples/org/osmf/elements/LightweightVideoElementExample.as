package asdoc.org.osmf.elements
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import org.osmf.elements.LightweightVideoElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;
	
	public class LightweightVideoElementExample extends Sprite
	{
		public function LightweightVideoElementExample()
		{
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var mediaPlayerSprite:MediaPlayerSprite = new MediaPlayerSprite();
			var videoElement:LightweightVideoElement = new LightweightVideoElement();
			videoElement.resource = new URLResource("http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv");
			
			addChild(mediaPlayerSprite);
			mediaPlayerSprite.media = videoElement;	
		}
	}
}