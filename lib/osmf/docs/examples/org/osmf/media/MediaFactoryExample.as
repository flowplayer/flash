/**
 * @exampleText This sample demonstrates how MediaFactory can be used to load a plug-in. Note
 * that the sample uses a mock-up plug-in URL.
 */
package org.osmf.media
{
	import flash.display.Sprite;
	
	import org.osmf.events.MediaFactoryEvent;

	public class MediaFactoryExample extends Sprite
	{
		public function MediaFactoryExample()
		{
			// Construct a media factory, and listen to its plug-in related events:
			var factory:MediaFactory = new MediaFactory();
			factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded);
			factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadError);
			
			// Instruct the factory to load the plug-in at the given url:
			factory.loadPlugin(new URLResource("http://myinvalidurl.com/foo.swf"));		
		}
	
		private function onPluginLoaded(event:MediaFactoryEvent):void
		{
			// Use the factory to create a media-element related to the plugin:
			var factory:MediaFactory = event.target as MediaFactory;
			factory.createMediaElement(new URLResource("http://myinvalidurl.com/content"));
		}
		
		private function onPluginLoadError(event:MediaFactoryEvent):void
		{
			// Handle plug-in loading failure:
			trace("Plugin failed to load.");	
		}	
	}
}