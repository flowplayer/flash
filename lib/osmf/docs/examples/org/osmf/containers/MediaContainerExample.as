package
{
	import flash.display.Sprite;
	
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.URLResource;

	public class MediaContainerExample extends Sprite
	{
		public function MediaContainerExample()
		{
			super();
			
			// Construct a video element:
			var resource:URLResource = new URLResource("http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv"); 
			var video:VideoElement = new VideoElement(resource);
			
			// Construct a media container, and add it to the stage.
			var mediaContainer:MediaContainer = new MediaContainer();
			mediaContainer.width = 640;
			mediaContainer.height = 500;
			addChild(mediaContainer);
			
			// Add the video as a child of the media container:
			mediaContainer.addMediaElement(video);
			
			// Play back the video:
			var player:MediaPlayer = new MediaPlayer();
			player.media = video;
		}
	}
}