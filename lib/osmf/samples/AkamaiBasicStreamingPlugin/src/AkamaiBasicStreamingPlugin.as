/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/

package
{
	import com.akamai.osmf.AkamaiBasicStreamingPluginInfo;
	
	import flash.display.Sprite;
	
	import org.osmf.media.PluginInfo;

	/**
	 * The Akamai Basic Streaming Plugin for OSMF supports Akamai-specific 
	 * behavior and functionality for streaming live and ondemand content 
	 * as well as progressive download content over the Akamai network.  
	 * Support for Akamai's connect-level and stream-level token 
	 * authentication is included in this plugin.
	 **/
	public class AkamaiBasicStreamingPlugin extends Sprite
	{	
		/**
		 * Constructor
		 **/
		public function AkamaiBasicStreamingPlugin()
		{
			_akamaiPluginInfo = new AkamaiBasicStreamingPluginInfo();
		}
		
		/**
		 * Gives the player the PluginInfo.
		 **/
		public function get pluginInfo():PluginInfo
		{
			return _akamaiPluginInfo;
		}
		
		private var _akamaiPluginInfo:AkamaiBasicStreamingPluginInfo;				
	}
}
