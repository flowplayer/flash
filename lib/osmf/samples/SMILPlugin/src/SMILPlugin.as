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
	import flash.display.Sprite;
	import flash.system.Security;
	
	import org.osmf.media.PluginInfo;
	import org.osmf.smil.SMILPluginInfo;

	/**
	 * The root level object of the SMIL plugin.
	 */
	public class SMILPlugin extends Sprite
	{
		/**
		 * Constructor.
		 */
		public function SMILPlugin()
		{
			// Allow any SWF that loads this SWF to access objects and
			// variables in this SWF.
			Security.allowDomain(this.root.loaderInfo.loaderURL);
			
			_pluginInfo = new SMILPluginInfo();
		}
		
		/**
		 * Gives the player the PluginInfo object.
		 */
		public function get pluginInfo():PluginInfo
		{
			return _pluginInfo;
		}
		
		private var _pluginInfo:SMILPluginInfo;
	}
}
