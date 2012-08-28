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
package org.osmf.net.httpstreaming
{
	import flash.events.NetStatusEvent;
	
	import org.osmf.net.*;
	
	public class HTTPStreamingNetLoaderWithBufferControl extends HTTPStreamingNetLoader
	{
		public function HTTPStreamingNetLoaderWithBufferControl()
		{
			super();
		}
		
		/**
		 * @private
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		override protected function processFinishLoading(loadTrait:NetStreamLoadTrait):void
		{
			netStream = loadTrait.netStream as HTTPNetStream;
			var resource:StreamingURLResource = loadTrait.resource as StreamingURLResource;
			if (resource != null)
			{
				if (resource.streamType == "live")
				{
					netStream.bufferTime = 4;
				}
			}
			netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);			
			super.processFinishLoading(loadTrait);			
		}
		
		private function onNetStatus(event:NetStatusEvent):void
		{
			if (event.info.code == NetStreamCodes.NETSTREAM_BUFFER_EMPTY)
			{
				if (netStream.bufferTime >= 2.0)
				{
					netStream.bufferTime += 1.0;
				}
				else
				{
					netStream.bufferTime = 2.0;
				}	
			}
		}
		
		private var netStream:HTTPNetStream;
	}
}