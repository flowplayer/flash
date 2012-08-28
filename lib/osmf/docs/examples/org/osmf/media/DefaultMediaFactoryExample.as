/**
 * @exampleText This example demonstrates how to manually use the DefaultMediaFactory
 * class to instantiate a video element.
 */	
package org.osmf.media
{
	import flash.display.Sprite;
	
	import org.osmf.containers.MediaContainer;

	public class DefaultMediaFactoryExample extends Sprite
	{
		public function DefaultMediaFactoryExample()
		{
			// Construct a default media factory:
			var factory:DefaultMediaFactory = new DefaultMediaFactory();
			
			// Request the factory to create a media element that matches the passed URL:
			var media:MediaElement = factory.createMediaElement(new URLResource("http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv"));
			
			// Add a media container, and player to have the constructed VideoElement
			// play back:  
			var mediaContainer:MediaContainer = new MediaContainer();
			addChild(mediaContainer);
			mediaContainer.width = 640;
			mediaContainer.height = 500;
			mediaContainer.addMediaElement(media);
			new MediaPlayer(media);
		}
		
	}
}