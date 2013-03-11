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
	
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	
	import org.osmf.metadata.Metadata;
	import org.osmf.net.FMSURL;
	
	CONFIG::LOGGING
	{
	import org.osmf.logging.*;		
	}
	
	/**
	 * The AkamaiNetConnection class extends NetConnection to provide 
	 * Akamai CDN-specifc connection behavior.
	 **/
	public class AkamaiNetConnection extends NetConnection
	{	
		/**
		 * Constructor.
		 **/
		public function AkamaiNetConnection(resourceMetadata:Metadata=null)
		{
			super();
			
			if (resourceMetadata != null)
			{
				processResourceMetadata(resourceMetadata);
			}
			
			_isLive = false;
			this.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
		}
		
		private function processResourceMetadata(metadata:Metadata):void
		{
			authParams = metadata.getValue(AkamaiBasicStreamingPluginInfo.AKAMAI_METADATA_KEY_CONNECT_AUTH_PARAMS) as String;
		}
		
		private function onNetStatus(event:NetStatusEvent):void
		{
			debug("onNetStatus() - event.info.code="+event.info.code);
			switch(event.info.code)
			{
				case "NetConnection.Call.Failed":
					debug("onNetStatus() - event.info.description="+event.info.description);
					break;
			}
		}
		
		/**
		 * Allows package level access to determine whether or not the
		 * connection requested is to a live stream.
		 **/
		internal function get isLive():Boolean
		{
			return _isLive;
		} 
		
		/**
		 * @inheritDoc
		 **/
		override public function connect(command:String, ...parameters):void
		{
			if (command != null)
			{
				var theURL:FMSURL = new FMSURL(command);
				_isLive = (theURL.appName.toLowerCase() == "live") ? true : false;
				
				// If we have auth params, append them if they are not already there
				if (authParams && authParams.length > 0)
				{
					var authToken:String = theURL.getParamValue("auth");
					if (authToken == "")
					{
						command = command.indexOf("?") != -1 ? command + "&" + authParams : command + "?" + authParams;
					}
				}
			}
			super.connect(command, parameters);
		}
		
		/**
		 * @inheritDoc
		 **/
		override public function close():void
		{
			super.close();
			removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
		}
		
		private function debug(msg:String):void
		{
			CONFIG::LOGGING
			{
				if (logger != null)
				{
					logger.debug(msg);
				}
			}
		}

		private var _isLive:Boolean;
		private var authParams:String;
		
		CONFIG::LOGGING
		{	
			private static const logger:org.osmf.logging.Logger = 
									org.osmf.logging.Log.getLogger("com.akamai.osmf.net.AkamaiNetConnection");		
		}	
		
	}
}
