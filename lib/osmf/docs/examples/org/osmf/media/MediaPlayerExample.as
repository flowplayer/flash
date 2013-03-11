package org.osmf.media
{
	import flash.display.Sprite;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.AudioElement;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.URLResource;
	
	public class MediaPlayerExample extends Sprite
	{
		private var mediaPlayer:MediaPlayer;
		
		public function MediaPlayerExample()
		{			
			super();
						
			mediaPlayer = new MediaPlayer();
			var audioElement:AudioElement = new AudioElement();
			audioElement.resource = new URLResource("http://mediapm.edgesuite.net/osmf/content/test/train_1500.mp3");
									
			mediaPlayer.volume = .5;
			mediaPlayer.loop = true;
			mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onTimeUpdated);		
			mediaPlayer.addEventListener(TimeEvent.DURATION_CHANGE, onTimeUpdated);
			mediaPlayer.autoPlay = true;
			mediaPlayer.media = audioElement;	
		}
		
		private function onTimeUpdated(event:TimeEvent):void
		{
			trace('time: ' + mediaPlayer.currentTime + ' duration: ' + mediaPlayer.duration);
		}
	}
}