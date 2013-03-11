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

package com.akamai.osmf.net
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Dictionary;
	
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.NetConnectionFactoryBase;
	import org.osmf.net.rtmpstreaming.RTMPDynamicStreamingNetLoader;
	import org.osmf.traits.LoadTrait;

	/**
	 * The AkamaiNetLoader class provides the means for
	 * creating a custom <code>NetStream</code> class, 
	 * in this case, an <code>AkamaiNetStream</code>.
	 * 
	 * @see AkamaiNetStream
	 **/ 
	public class AkamaiNetLoader extends RTMPDynamicStreamingNetLoader
	{
		/**
		 * @inheritDoc
		 **/
		public function AkamaiNetLoader(factory:NetConnectionFactoryBase)
		{
			super(factory);
		}
		
		/**
		 * @private
		 **/ 
		public function get pluginMetadata():Metadata
		{
			return _pluginMetadata;
		}
		
		public function set pluginMetadata(value:Metadata):void
		{
			_pluginMetadata = value;
		}
		
		/**
		 * @inheritDoc
		**/
		override protected function createNetStream(connection:NetConnection, resource:URLResource):NetStream
		{
			var ns:AkamaiNetStream =  new AkamaiNetStream(connection, resource, this);
			
			return ns;
		}
		
		CONFIG::FLASH_10_1	
		{							
			/**
			 * @inheritDoc
			 **/
			override protected function createReconnectNetConnection():NetConnection
			{
				return new AkamaiNetConnection();
			}
		}
				
		/**
		 * @inheritDoc
		 **/
		override protected function executeLoad(loadTrait:LoadTrait):void
		{			
			super.executeLoad(loadTrait);
			
			if (loadTraitMap == null)
			{
				loadTraitMap = new Dictionary();
			}
			
			var resource:URLResource = (loadTrait.resource as URLResource);
			if (resource != null)
			{
				loadTraitMap[resource] = loadTrait;
			}
		}
		
		/**
		 * Internal function to return the LoadTrait associated with
		 * the supplied resource.
		 **/
		internal function getLoadTrait(resource:URLResource):LoadTrait
		{
			return loadTraitMap[resource] as LoadTrait;
		} 
		
		private var loadTraitMap:Dictionary;
		private var _pluginMetadata:Metadata;
	}
}
