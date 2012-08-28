package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import org.osmf.elements.BeaconElement;
	import org.osmf.elements.DurationElement;
	import org.osmf.elements.ImageElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;
	
	public class DurationElementExample extends Sprite
	{
		public function DurationElementExample()
		{				
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var mediaPlayerSprite:MediaPlayerSprite = new MediaPlayerSprite();
			var imageElement:ImageElement = new ImageElement();
			imageElement.resource = new URLResource("http://mediapm.edgesuite.net/strobe/content/test/train.jpg");
			
			// Shows the image for 10 seconds.
			var durationElement:DurationElement = new DurationElement(10, imageElement);
			
			addChild(mediaPlayerSprite);
			mediaPlayerSprite.media = durationElement;	
		}
	}
}