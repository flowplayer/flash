/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.media.pluginClasses
{
	import flash.display.Loader;
	
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	
	[ExcludeClass]
	
	/**
	 * @private
	 */
	internal class PluginLoadTrait extends LoadTrait
	{
		public function PluginLoadTrait(loader:LoaderBase, resource:MediaResourceBase)
		{
			super(loader, resource);
		}

		/**
		 * The <code>PluginInfo</code> reference.
		 */
		public function get pluginInfo():PluginInfo
		{
			return _pluginInfo;
		}
	
		public function set pluginInfo(value:PluginInfo):void
		{
			_pluginInfo = value;
		}

		/**
		 * The <code>Loader</code> used to load the plugin
		 */
		public function get loader():Loader
		{
			return _loader;
		}

		public function set loader(value:Loader):void
		{
			_loader = value;
		}

		private var _pluginInfo:PluginInfo;
		private var _loader:Loader;
	}
}