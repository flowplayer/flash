package
{
	import flash.display.Sprite;
	
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;

	public class MediaPlayerSpriteExample extends Sprite
	{
		public function MediaPlayerSpriteExample()
		{
			// Create the container class that displays the media.
			var sprite:MediaPlayerSprite = new MediaPlayerSprite();
			addChild(sprite);

			// Assign the resource to play.  This will generate the
			// appropriate MediaElement and pass it to the MediaPlayer.
			// Because the MediaPlayer is set to auto-play by default,
			// playback begins immediately.
			sprite.resource = new URLResource("http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv");
		}
	}
}
