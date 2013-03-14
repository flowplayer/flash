package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import org.osmf.elements.VideoElement;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.TimelineMetadataEvent;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.CuePoint;
	import org.osmf.metadata.TimelineMetadata;
	
	public class TimelineMetadataExample extends Sprite
	{
		public function TimelineMetadataExample()
		{
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var mediaPlayerSprite:MediaPlayerSprite = new MediaPlayerSprite();
			var urlResource:URLResource = new URLResource("rtmp://cp67126.edgefcs.net/ondemand/mp4:mediapm/osmf/content/test/cuepoints/spacealonehd_sounas_640_with_nav.f4v");
			videoElement= new VideoElement();
			videoElement.resource = urlResource;
			videoElement.addEventListener(MediaElementEvent.METADATA_ADD, onMetadataAdd);

			addChild(mediaPlayerSprite);
			mediaPlayerSprite.media = videoElement;	
		}

		private function onMetadataAdd(event:MediaElementEvent):void
		{
			if (event.namespaceURL == CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE)
			{
				var timelineMetadata:TimelineMetadata = videoElement.getMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) as TimelineMetadata;
				timelineMetadata.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onCuePoint);
			}
		}

		private function onCuePoint(event:TimelineMetadataEvent):void
		{
			var cuePoint:CuePoint = event.marker as CuePoint;
			trace("Cue Point at " + cuePoint.time);
		}

		private var videoElement:VideoElement;
	}
}
