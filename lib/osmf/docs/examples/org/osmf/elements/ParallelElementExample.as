package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import org.osmf.elements.LightweightVideoElement;
	import org.osmf.elements.ParallelElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.LayoutMode;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;
	
	public class ParallelElementExample extends Sprite
	{
		public function ParallelElementExample()
		{
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var mediaPlayerSprite:MediaPlayerSprite = new MediaPlayerSprite();
			var parallelElement:ParallelElement = new ParallelElement();
						
			var videoElement:LightweightVideoElement = new LightweightVideoElement();
			videoElement.resource = new URLResource("http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv");
			
			var videoElement2:LightweightVideoElement = new LightweightVideoElement();
			videoElement2.resource = new URLResource("http://mediapm.edgesuite.net/strobe/content/test/elephants_dream_768x428_24_short.flv");
						
			parallelElement.addChild(videoElement);
			parallelElement.addChild(videoElement2);
			
			// Add a vertical layout
			var layout:LayoutMetadata = new LayoutMetadata();
			layout.layoutMode = LayoutMode.VERTICAL;
			parallelElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);			
			
			addChild(mediaPlayerSprite);
			mediaPlayerSprite.media = parallelElement;	
			
		}
	}
}