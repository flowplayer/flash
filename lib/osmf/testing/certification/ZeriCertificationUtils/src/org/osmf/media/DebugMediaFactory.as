package org.osmf.media
{
	import org.osmf.elements.AudioElement;
	import org.osmf.elements.F4MElement;
	import org.osmf.elements.F4MLoader;
	import org.osmf.elements.ImageElement;
	import org.osmf.elements.ImageLoader;
	import org.osmf.elements.SWFElement;
	import org.osmf.elements.SWFLoader;
	import org.osmf.elements.SoundLoader;
	import org.osmf.elements.VideoElement;
	import org.osmf.net.NetLoader;
	import org.osmf.net.TraceNetLoader;
	import org.osmf.net.dvr.DVRCastNetLoader;
	import org.osmf.net.httpstreaming.HTTPStreamingNetLoader;
	import org.osmf.net.rtmpstreaming.RTMPDynamicStreamingNetLoader;

	public class DebugMediaFactory extends MediaFactory
	{
		protected var rtmpStreamingNetLoader:RTMPDynamicStreamingNetLoader;
		protected var f4mLoader:F4MLoader;
		protected var dvrCastLoader:DVRCastNetLoader;
		protected var netLoader:NetLoader;
		protected var imageLoader:ImageLoader;
		protected var swfLoader:SWFLoader;
		protected var soundLoader:SoundLoader;
		
		protected var httpStreamingNetLoader:HTTPStreamingNetLoader;
		
		protected function addF4MElement() : void
		{
			addItem 
			( new MediaFactoryItem
				( "org.osmf.elements.f4m"
					, f4mLoader.canHandleResource
					, function():MediaElement
					{
						return new F4MElement(null, f4mLoader);
					}
				)
			);
		}
		
		protected function addDVRCastNetElement() : void
		{
			addItem
			( new MediaFactoryItem
				( "org.osmf.elements.video.dvr.dvrcast"
					, dvrCastLoader.canHandleResource
					, function():MediaElement
					{
						return new VideoElement(null, dvrCastLoader);
					}
				)
			);
		}
		
		protected function addHTTPStreamingNetElement() : void
		{
			addItem
			( new MediaFactoryItem
				( "org.osmf.elements.video.httpstreaming"
					, httpStreamingNetLoader.canHandleResource
					, function():MediaElement
					{
						return new VideoElement(null, httpStreamingNetLoader);
					}
				)
			);
		}
		
		protected function addRTMPDynamicStreamingNetElement() : void
		{
			addItem
			( new MediaFactoryItem
				( "org.osmf.elements.video.rtmpdynamicStreaming"
					, rtmpStreamingNetLoader.canHandleResource
					, function():MediaElement
					{
						return new VideoElement(null, rtmpStreamingNetLoader);
					}
				)
			);
		}
		
		protected function addNetElement() : void
		{
			addItem
			( new MediaFactoryItem
				( "org.osmf.elements.video"
					, netLoader.canHandleResource
					, function():MediaElement
					{
						return new VideoElement(null, netLoader);
					}
				)
			);	
		}
		
		protected function addSoundElement() : void
		{
			addItem
			( new MediaFactoryItem
				( "org.osmf.elements.audio"
					, soundLoader.canHandleResource
					, function():MediaElement
					{
						return new AudioElement(null, soundLoader);
					}
				)
			);
		}
		
		protected function addStreamingSoundElement() : void
		{
			addItem
			( new MediaFactoryItem
				( "org.osmf.elements.audio.streaming"
					, netLoader.canHandleResource
					, function():MediaElement
					{
						return new AudioElement(null, netLoader);
					}
				)
			);
		}
		
		protected function addImageElement() : void
		{
			addItem
			( new MediaFactoryItem
				( "org.osmf.elements.image"
					, imageLoader.canHandleResource
					, function():MediaElement
					{
						return new ImageElement(null, imageLoader);
					}
				)
			);
		}
		
		protected function addSWFElement() : void
		{
			addItem
			( new MediaFactoryItem
				( "org.osmf.elements.swf"
					, swfLoader.canHandleResource
					, function():MediaElement
					{
						return new SWFElement(null, swfLoader);
					}
				)
			);
		}
		
		protected function setLoaders() : void
		{
			f4mLoader = new F4MLoader(this);
			dvrCastLoader = new DVRCastNetLoader();
			httpStreamingNetLoader = new HTTPStreamingNetLoader();
			rtmpStreamingNetLoader = new RTMPDynamicStreamingNetLoader();
			netLoader = new TraceNetLoader();
			soundLoader = new SoundLoader();
			imageLoader = new ImageLoader();
			swfLoader = new SWFLoader();
		}
		
		protected function init():void
		{
			setLoaders();
			
			addF4MElement();
			addDVRCastNetElement();
			addHTTPStreamingNetElement();
			addRTMPDynamicStreamingNetElement();
			addNetElement();
			addSoundElement();
			addStreamingSoundElement();
			addImageElement();
			addSWFElement();
		}
		
		public function DebugMediaFactory()
		{
			super();
			init();
		}
	}
}