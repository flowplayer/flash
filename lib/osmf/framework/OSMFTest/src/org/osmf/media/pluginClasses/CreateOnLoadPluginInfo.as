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
	import __AS3__.vec.Vector;
	
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	import org.osmf.net.NetLoader;
	import org.osmf.net.NetLoaderForTest;

	public class CreateOnLoadPluginInfo extends PluginInfo
	{
		public function CreateOnLoadPluginInfo()
		{
			var item:MediaFactoryItem = new MediaFactoryItem("org.osmf.plugin.CreateOnLoadPlugin", new NetLoaderForTest(null, false).canHandleResource, createElement);
			var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
			items.push(item);
			
			super(items);
		}
		
		override public function initializePlugin(resource:MediaResourceBase):void
		{
			_pluginResource = resource;
		}
		
		public function get pluginResource():MediaResourceBase
		{
			return _pluginResource;
		}
		
		public function get createCount():Number
		{
			return _createCount;
		}

		private function createElement():MediaElement
		{
			_createCount++;
			return null;
		}
		
		private var _createCount:Number = 0;
		private var _pluginResource:MediaResourceBase;
	}
}