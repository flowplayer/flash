package
{
	import flash.display.Sprite;
	
	import org.osmf.elements.AudioElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.URLResource;
	
	public class AudioElementExample extends Sprite
	{
		public function AudioElementExample()
		{
			super();
			
			var mediaPlayer:MediaPlayer = new MediaPlayer();
			var audioElement:AudioElement = new AudioElement();
			audioElement.resource = new URLResource("http://mediapm.edgesuite.net/osmf/content/test/train_1500.mp3");
			
			mediaPlayer.media = audioElement;		
		}
	}
}