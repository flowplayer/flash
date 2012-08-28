package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import org.osmf.elements.LightweightVideoElement;
	import org.osmf.elements.SerialElement;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;
	
	public class SerialElementExample extends Sprite
	{
		public function SerialElementExample()
		{
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var mediaPlayerSprite:MediaPlayerSprite = new MediaPlayerSprite();
			var serialElement:SerialElement = new SerialElement();
			
			var videoElement:LightweightVideoElement = new LightweightVideoElement();
			videoElement.resource = new URLResource("http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv");
			
			var videoElement2:LightweightVideoElement = new LightweightVideoElement();
			videoElement2.resource = new URLResource("http://mediapm.edgesuite.net/strobe/content/test/elephants_dream_768x428_24_short.flv");
			
			serialElement.addChild(videoElement);
			serialElement.addChild(videoElement2);
			
			addChild(mediaPlayerSprite);
			mediaPlayerSprite.media = serialElement;	
			
		}
	}
}