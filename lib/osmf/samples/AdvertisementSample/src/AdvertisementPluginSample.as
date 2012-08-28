package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.events.Event;
	
	import org.osmf.advertisementplugin.AdvertisementPluginInfo;
	import org.osmf.containers.MediaContainer;
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.layout.ScaleMode;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfoResource;
	import org.osmf.media.URLResource;
	
	/**
	 * This is a sample project that loads the Ad Plugin.
	 */ 
	[SWF(frameRate="25", backgroundColor="#000000", width="640", height="480")]
	public class AdvertisementPluginSample extends Sprite
	{
		public function AdvertisementPluginSample()
		{
			// This is a normal video player setup.
			var mediaFactory:MediaFactory = new DefaultMediaFactory();
			var mediaPlayer:MediaPlayer = new MediaPlayer();
			var mediaContainer:MediaContainer = new MediaContainer();			
			var resource:URLResource = new URLResource("http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv");
			var mediaElement:MediaElement = mediaFactory.createMediaElement(resource);	
			mediaContainer.addMediaElement(mediaElement);			
			this.addChild(mediaContainer);			
			
			// Load the plugin statically
			var pluginResource:MediaResourceBase = new PluginInfoResource(new AdvertisementPluginInfo());
			
			// You can load it as a dynamic plugin as well 
			// var pluginResource:MediaResourceBase = new URLResource("http://localhost/AdvertisementPlugin/bin/AdvertisementPlugin.swf");
			
			// Pass the references to the MediaPlayer and the MediaContainer instances to the plug-in.
			pluginResource.addMetadataValue("MediaPlayer", mediaPlayer);
			pluginResource.addMetadataValue("MediaContainer", mediaContainer);
			
			// Configure the plugin with the advertisement information
			// The following configuration will instruct the plugin to play a mid-roll ad after 10 seconds
			pluginResource.addMetadataValue("midroll", "http://gcdn.2mdn.net/MotifFiles/html/1379578/PID_938961_1237818260000_women.flv");
			pluginResource.addMetadataValue("midrollTime", 10);
			
			// Uncomment the following lines to see a pre-roll, overlay and post-roll ad.  
			// pluginResource.addMetadataValue("preroll", "http://gcdn.2mdn.net/MotifFiles/html/1379578/PID_938961_1237818260000_women.flv");
			// pluginResource.addMetadataValue("postroll", "http://gcdn.2mdn.net/MotifFiles/html/1379578/PID_938961_1237818260000_women.flv");
			// pluginResource.addMetadataValue("overlay", "http://gcdn.2mdn.net/MotifFiles/html/1379578/PID_938961_1237818260000_women.flv");
			// pluginResource.addMetadataValue("overlayTime", 20);		
			
			// Once the plugin is loaded, play the media.
			// The event handler is not needed if you use the statically linked plugin, but is here in case you load the plugin dynamically.
			// For readability, we don’t provide error handling here, but you should.
			mediaFactory.addEventListener(
				MediaFactoryEvent.PLUGIN_LOAD, 
				function(event:MediaFactoryEvent):void
				{
					// Now let's play the video - mediaPlayer has the autoPlay set to true by default,
					// so the playback will start as soon as the media is ready to be played.
					mediaPlayer.media = mediaElement;
				}
			);
			
			// Load the plugin. 
			mediaFactory.loadPlugin(pluginResource);			
		}
	}
}