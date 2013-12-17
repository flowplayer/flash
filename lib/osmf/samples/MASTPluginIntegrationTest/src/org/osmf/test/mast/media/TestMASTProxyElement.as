package org.osmf.test.mast.media
{
	import flash.errors.IllegalOperationError;
	
	import flexunit.framework.TestCase;
	
	import org.osmf.elements.VideoElement;
	import org.osmf.events.LoadEvent;
	import org.osmf.mast.MASTPluginInfo;
	import org.osmf.mast.media.MASTProxyElement;
	import org.osmf.media.MediaElement;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayTrait;
	

	public class TestMASTProxyElement extends TestCase
	{
		public function testConstructor():void
		{
			// Should throw an exception because there is no resource
			try
			{
				new MASTProxyElement(new MediaElement());
				fail();
			}
			catch(error:IllegalOperationError)
			{	
			}
		}
		
		public function testSetWrappedElement():void
		{
			var proxyElement:MASTProxyElement = new MASTProxyElement();
			
			
			// Should not throw an exception
			try
			{
				proxyElement.proxiedElement = null;
			}
			catch(error:IllegalOperationError)
			{	
				fail();
			}
		}
	
		public function testWithNoMetadata():void
		{
			var resource:URLResource = new URLResource(REMOTE_STREAM);				
			var mediaElement:MediaElement = new MediaElement();
			mediaElement.resource = resource;
			
			try
			{
				new MASTProxyElement(mediaElement);
				fail();
			}
			catch(error:IllegalOperationError)
			{
				
			}
		}
		
		public function testWithMetadata():void
		{
			var mediaElement:VideoElement = new VideoElement();
			mediaElement.resource = createResourceWithMetadata();

			try
			{
				new MASTProxyElement(mediaElement);
			}
			catch(error:IllegalOperationError)
			{
				fail();
			}
		}
		
		public function testLoad():void
		{
			var mediaElement:MediaElement = new VideoElement();
			mediaElement.resource = createResourceWithMetadata();

			var proxyElement:MASTProxyElement = null;
			
			try
			{
				proxyElement = new MASTProxyElement(mediaElement);
			}
			catch(error:IllegalOperationError)
			{
				fail();
			}
			
			var loadTrait:LoadTrait = proxyElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
			loadTrait.load();
		}
					
		public function testLoadAndPlay():void
		{
			doLoadAndPlay();
			doLoadAndPlay(false);
		}

		public function testLoadFailure():void
		{
			var mediaElement:MediaElement = new VideoElement();
			var resource:URLResource = new URLResource(REMOTE_STREAM);				
			var metadata:Metadata = new Metadata();
			metadata.addValue(MASTPluginInfo.MAST_METADATA_KEY_URI, "http://foo.com/bogus/badfile.xml");
			resource.addMetadataValue(MASTPluginInfo.MAST_METADATA_NAMESPACE, metadata);

			mediaElement.resource = resource

			var proxyElement:MASTProxyElement = null;
			
			try
			{
				proxyElement = new MASTProxyElement(mediaElement);
			}
			catch(error:IllegalOperationError)
			{
				fail();
			}
			
			var loadTrait:LoadTrait = proxyElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
			loadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
			loadTrait.load();
			
			function onLoadStateChange(event:LoadEvent):void
			{
				if (event.loadState == LoadState.READY)
				{
					fail();
				}
				else if (event.loadState == LoadState.LOAD_ERROR)
				{
					// expected
				}
				
			}
			
			
		}
		
		private function doLoadAndPlay(preroll:Boolean=true):void
		{
			var mediaElement:MediaElement = new VideoElement();
			mediaElement.resource = createResourceWithMetadata(preroll);

			var proxyElement:MASTProxyElement = null;
			
			try
			{
				proxyElement = new MASTProxyElement(mediaElement);
			}
			catch(error:IllegalOperationError)
			{
				fail();
			}
			
			var loadTrait:LoadTrait = proxyElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
			loadTrait.load();
			
			var playTrait:PlayTrait = proxyElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
			playTrait.play();
		}

		private function createResourceWithMetadata(preroll:Boolean=true):URLResource
		{
			var resource:URLResource = new URLResource(REMOTE_STREAM);				
			
			var metadata:Metadata = new Metadata();
			metadata.addValue(MASTPluginInfo.MAST_METADATA_KEY_URI, preroll ? MAST_URL_PREROLL : MAST_URL_POSTROLL);
			resource.addMetadataValue(MASTPluginInfo.MAST_METADATA_NAMESPACE, metadata);
			
			return resource;			
		}

		private static const MAST_URL_PREROLL:String = "http://mediapm.edgesuite.net/osmf/content/mast/mast_sample_onitemstart.xml";
		private static const MAST_URL_POSTROLL:String 		= "http://mediapm.edgesuite.net/osmf/content/mast/mast_sample_onitemend.xml";
		
		private static const REMOTE_STREAM:String = "rtmp://cp67126.edgefcs.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short";
	}
}
