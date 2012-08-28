package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import org.osmf.elements.F4MElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;
	
	public class F4MElementExample extends Sprite
	{
		public function F4MElementExample()
		{
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var mediaPlayerSprite:MediaPlayerSprite = new MediaPlayerSprite();
			var manifestElement:F4MElement = new F4MElement();
			manifestElement.resource = new URLResource("http://mediapm.edgesuite.net/osmf/content/test/manifest-files/progressive.f4m");
			
			addChild(mediaPlayerSprite);
			mediaPlayerSprite.media = manifestElement;	
			
		}
	}
}