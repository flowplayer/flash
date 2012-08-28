package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import org.osmf.elements.ImageElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;
	
	public class ImageElementExample extends Sprite
	{
		public function ImageElementExample()
		{
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var mediaPlayerSprite:MediaPlayerSprite = new MediaPlayerSprite();
			var imageElement:ImageElement = new ImageElement();
			imageElement.resource = new URLResource("http://mediapm.edgesuite.net/strobe/content/test/train.jpg");
			
			addChild(mediaPlayerSprite);
			mediaPlayerSprite.media = imageElement;	
		}
	}
}