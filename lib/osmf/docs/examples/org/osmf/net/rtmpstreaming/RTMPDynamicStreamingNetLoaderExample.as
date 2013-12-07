package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.rtmpstreaming.RTMPDynamicStreamingNetLoader;
	
	public class RTMPDynamicStreamingNetLoaderExample extends Sprite
	{
		public function RTMPDynamicStreamingNetLoaderExample()
		{
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var mediaPlayerSprite:MediaPlayerSprite = new MediaPlayerSprite();
			var netLoader:RTMPDynamicStreamingNetLoader = new RTMPDynamicStreamingNetLoader();
			var videoElement:VideoElement = new VideoElement(null, netLoader);

			var dynResource:DynamicStreamingResource = new DynamicStreamingResource("rtmp://cp67126.edgefcs.net/ondemand");
			dynResource.streamItems = Vector.<DynamicStreamingItem>(
				[ 	new DynamicStreamingItem("mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_768x428_24.0fps_408kbps.mp4", 408, 768, 428)
					, new DynamicStreamingItem("mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_768x428_24.0fps_608kbps.mp4", 608, 768, 428)
					, new DynamicStreamingItem("mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_1024x522_24.0fps_908kbps.mp4", 908, 1024, 522)
					, new DynamicStreamingItem("mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_1024x522_24.0fps_1308kbps.mp4", 1308, 1024, 522)
					, new DynamicStreamingItem("mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_1280x720_24.0fps_1708kbps.mp4", 1708, 1280, 720)
				]);
			
			videoElement.resource = dynResource;
			
			addChild(mediaPlayerSprite);
			mediaPlayerSprite.media = videoElement;	
		}	
	}
} 