package org.osmf.layout
{
	import flash.display.Sprite;
	
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;

	public class LayoutMetadataExample extends Sprite
	{
		public function LayoutMetadataExample()
		{
			var sprite:MediaPlayerSprite = new MediaPlayerSprite();
			addChild(sprite);
			
			sprite.resource = new URLResource("http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv");
			
			// Construct a metadata instance, and set an absolute width and height of 
			// 100 pixels:
			var layoutMetadata:LayoutMetadata = new LayoutMetadata();
			layoutMetadata.width = 100;
			layoutMetadata.height = 100;
			
			// Apply the layout metadata to the media element at hand, resulting
			// in the video to be shown at 100x100 pixels:
			sprite.media.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layoutMetadata);
		}
		
	}
}