package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import org.osmf.elements.SWFElement;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;
	
	public class SWFElementExample extends Sprite
	{
		private var mediaPlayerSprite:MediaPlayerSprite;
		
		public function SWFElementExample()
		{
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			mediaPlayerSprite = new MediaPlayerSprite();
			var swfElement:SWFElement = new SWFElement();
			swfElement.resource = new URLResource("http://mediapm.edgesuite.net/osmf/content/test/ten.swf");
							
			addChild(mediaPlayerSprite);
			mediaPlayerSprite.media = swfElement;	
		}
		
	}
}