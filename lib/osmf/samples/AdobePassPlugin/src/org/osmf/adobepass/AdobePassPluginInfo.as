package org.osmf.adobepass
{	
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaFactoryItemType;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.NetLoader;
	import org.osmf.adobepass.media.AdobePassProxyElement;
	
	public class AdobePassPluginInfo extends PluginInfo
	{		
		private var mediaInfos:Vector.<MediaFactoryItem>;
		private var pluginMetadata:Object;
		
		public function AdobePassPluginInfo()
		{
			mediaInfos = new Vector.<MediaFactoryItem>;
			var mediaInfo:MediaFactoryItem = new MediaFactoryItem
				( "com.adobe.adobepass.AdobePassPluginInfo"
				, new NetLoader().canHandleResource
				, createTVEProxyElement
				, MediaFactoryItemType.PROXY
				);
			mediaInfos.push(mediaInfo);

			super(mediaInfos);
		}
		
		override public function initializePlugin(resource:MediaResourceBase):void
		{
			pluginMetadata = resource.getMetadataValue(ADOBEPASS_PLUGIN_NAMESPACE);
		}
		
		private function createTVEProxyElement():MediaElement
		{
			return new AdobePassProxyElement(null, pluginMetadata);
		}

		public static var ADOBEPASS_PLUGIN_NAMESPACE:String = "http://www.adobe.com/products/adobepass/";
	}
}
