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
package org.osmf.smil
{
	import __AS3__.vec.Vector;
	
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	import org.osmf.smil.elements.SMILElement;
	import org.osmf.smil.loader.SMILLoader;

	/**
	 * Encapsulation of the SMIL plugin.
	 */
	public class SMILPluginInfo extends PluginInfo
	{
		/**
		 * Constructor.
		 */
		public function SMILPluginInfo()
		{
			var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
			
			var item:MediaFactoryItem = new MediaFactoryItem("org.osmf.smil.SMILPluginInfo", new SMILLoader().canHandleResource, createSMILProxyElement);
			items.push(item);
			
			super(items);
		}
		
		private function createSMILProxyElement():MediaElement
		{
			return new SMILElement(null, new SMILLoader(mediaFactory));
		}
		
		override public function initializePlugin(resource:MediaResourceBase):void
		{
			// We'll use the player-supplied MediaFactory for creating all MediaElements.
			mediaFactory = resource.getMetadataValue(PluginInfo.PLUGIN_MEDIAFACTORY_NAMESPACE) as MediaFactory;
		}
		
		private var mediaFactory:MediaFactory;
	}
}
