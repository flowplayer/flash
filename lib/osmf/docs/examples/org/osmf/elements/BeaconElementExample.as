package
{
	import flash.display.Sprite;
	
	import org.osmf.elements.BeaconElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.URLResource;
	
	public class BeaconElementExample extends Sprite
	{
		public function BeaconElementExample()
		{
			super();
			
			var mediaPlayer:MediaPlayer = new MediaPlayer();
			var beaconElement:BeaconElement = new BeaconElement("http://www.example.com/testBeacon");
			
			mediaPlayer.media = beaconElement;	
		}
	}
}