/***********************************************************
 * 
 * Copyright 2011 Adobe Systems Incorporated. All Rights Reserved.
 *
 * *********************************************************
 * The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 * (the "License"); you may not use this file except in
 * compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems
 * Incorporated. All Rights Reserved.
 **********************************************************/
package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	
	import org.osmf.media.PluginInfo;
	import org.osmf.smpte.tt.SMPTETTPluginInfo;
	
	/**
	 * The root level object of the SMPTE-TT Plugin.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.6
	 */
	public class SMPTETTPlugin extends Sprite
	{
		/**
		 * Constructor.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.6
		 */
		public function SMPTETTPlugin()
		{
			// Allow any SWF that loads this SWF to access objects and
			// variables in this SWF.
			Security.allowDomain("*");
			
			_pluginInfo = new SMPTETTPluginInfo();
		}
		
		/**
		 * Gives the player the PluginInfo.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.6
		 */
		public function get pluginInfo():PluginInfo
		{
			return _pluginInfo;
		}
		
		private var _pluginInfo:SMPTETTPluginInfo;
	}
}