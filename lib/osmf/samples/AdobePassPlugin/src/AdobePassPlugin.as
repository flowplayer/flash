package
{
	import org.osmf.adobepass.AdobePassPluginInfo;
	
	import flash.display.Sprite;
	import flash.system.Security;
	
	import org.osmf.media.PluginInfo;
	
	/**
	 * The root level object of the AdobePassPlugin.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 */	
	public class AdobePassPlugin extends Sprite
	{		
		/**
		 * Constructor.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 */		
		public function AdobePassPlugin()
		{  			
			_pluginInfo = new AdobePassPluginInfo();
		}
		
		/**
		 * Gives the player the object which implements the OSMF IPluginInfo interface.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 */
		public function get pluginInfo():PluginInfo
		{
			return _pluginInfo;
		}
		
		private var _pluginInfo:PluginInfo;
	}
}
