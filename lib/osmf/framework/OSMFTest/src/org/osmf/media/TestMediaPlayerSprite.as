package org.osmf.media
{
	import flexunit.framework.Assert;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.AudioElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.ScaleMode;
	
	public class TestMediaPlayerSprite
	{
		[Test]
		public function testConstructor():void
		{
			var container:MediaContainer = new MediaContainer();
			var player:MediaPlayer = new MediaPlayer();
			var factory:MediaFactory = new MediaFactory();
			
			var mps:MediaPlayerSprite = new MediaPlayerSprite(player, container, factory);
			Assert.assertEquals(mps.mediaPlayer, player);
			Assert.assertEquals(mps.mediaContainer, container);
			Assert.assertEquals(mps.mediaFactory, factory);
			
			mps = new MediaPlayerSprite();
			Assert.assertNotNull(mps.mediaPlayer);
			Assert.assertNotNull(mps.mediaContainer);
			Assert.assertNotNull(mps.mediaFactory);
			
			player.media = new AudioElement();
			
			mps = new MediaPlayerSprite(player);
			Assert.assertTrue(mps.mediaContainer.containsMediaElement(player.media));
			Assert.assertEquals(mps.media, player.media);		
		}
		
		[Test]
		public function testMedia():void
		{			
			var mps:MediaPlayerSprite = new MediaPlayerSprite();
			
			Assert.assertNull(mps.media);
			Assert.assertNull(mps.mediaPlayer.media);
			
			mps.mediaPlayer.media = new AudioElement();
			
			Assert.assertEquals(mps.media, mps.mediaPlayer.media);
			Assert.assertTrue(mps.mediaContainer.containsMediaElement(mps.media));
			
			mps.media = new VideoElement();
			
			Assert.assertEquals(mps.media, mps.mediaPlayer.media);
			Assert.assertTrue(mps.mediaContainer.containsMediaElement(mps.media));
			Assert.assertTrue(mps.media is VideoElement);						
		}
		
		[Test]
		public function testResource():void
		{
			var mps:MediaPlayerSprite = new MediaPlayerSprite();
			
			var resource:URLResource = new URLResource("http://example.com/video.flv");
			
			mps.resource = resource;
			
			Assert.assertEquals(mps.resource, resource);
			Assert.assertNotNull(mps.media);
			Assert.assertEquals(mps.media, mps.mediaPlayer.media);
						
		}
		
		[Test]
		public function testScaleMode():void
		{
			var mps:MediaPlayerSprite = new MediaPlayerSprite();
			
			Assert.assertEquals(mps.scaleMode, ScaleMode.LETTERBOX);
			
			mps.media = new VideoElement();

			Assert.assertEquals(mps.scaleMode, ScaleMode.LETTERBOX);
			
			var layout:LayoutMetadata = mps.media.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
			
			Assert.assertEquals(layout.scaleMode, mps.scaleMode, ScaleMode.LETTERBOX);
			
			mps.scaleMode = ScaleMode.NONE;
			
			Assert.assertEquals(layout.scaleMode, mps.scaleMode, ScaleMode.NONE);
			
			
			//Make sure layout is preserved if already set.
			var element:MediaElement = new VideoElement();
			layout = new LayoutMetadata()
			element.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);
			layout.percentWidth = 50;
			layout.percentHeight = 50;
			layout.percentX = 20;
			layout.percentY = 20;
			layout.scaleMode = ScaleMode.STRETCH;			
			
			mps = new MediaPlayerSprite();
			
			mps.media = element;
			
			Assert.assertEquals(mps.scaleMode, ScaleMode.LETTERBOX);	
			
			Assert.assertEquals(mps.media.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE), layout);	
					
		}
		
		[Test]
		public function testLayout():void
		{
			var mps:MediaPlayerSprite = new MediaPlayerSprite();
			
			mps.media = new VideoElement();
			
			mps.width = 200;
			mps.height = 200;
			
			Assert.assertEquals(mps.mediaContainer.width, mps.width);
			Assert.assertEquals(mps.mediaContainer.height, mps.height);
									
			mps.width = 400;
			mps.height = 400;
			
			Assert.assertEquals(mps.mediaContainer.width, mps.width);
			Assert.assertEquals(mps.mediaContainer.height, mps.height);
		}		
	}
}