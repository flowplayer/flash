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
	import com.akamai.osmf.AkamaiBasicStreamingPluginInfo;
	
	import flash.net.NetConnection;
	
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.NetConnectionFactory;
	import org.osmf.utils.URL;

	/**
	 * The AkamaiNetConnectionFactory class extends NetConnectionFactory to
	 * provide the means to create a unique key for connection sharing and
	 * support token authentication.
	 * 
	 **/
	public class AkamaiNetConnectionFactory extends NetConnectionFactory
	{
		/**
		 * Override so we can get to the resource metadata.
		 **/
		override public function create(resource:URLResource):void
		{
			_resourceMetadata = resource.getMetadataValue(AkamaiBasicStreamingPluginInfo.AKAMAI_METADATA_NAMESPACE) as Metadata;
			super.create(resource);			
		}
		
		/**
		 * @inheritDoc
		 **/
		override protected function createNetConnectionKey(resource:URLResource):String
		{
			var theURL:URL = new URL(resource.url);
			var authToken:String = theURL.getParamValue("auth");
			var aifpToken:String = theURL.getParamValue("aifp");
			var slistToken:String = theURL.getParamValue("slist");
			
			return super.createNetConnectionKey(resource) + authToken + aifpToken + slistToken;
		}
		
		/**
		 * @inheritDoc
		 **/
		override protected function createNetConnection():NetConnection
		{
			return new AkamaiNetConnection(_resourceMetadata);
		}
		
		private var _resourceMetadata:Metadata;
	}
}
