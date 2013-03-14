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
	import flash.events.IEventDispatcher;
	import flash.net.URLRequest;
	
	[ExcludeClass]
	
	/**
	 * @private
	 */
	public class HTTPStreamRequest
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function HTTPStreamRequest(
			kind:String,
			url:String = null,
			retryAfter:Number = -1,
			bestEffortDownloaderMonitor:IEventDispatcher = null)
		{
			super();
			
			_kind = kind;
			
			if (url)
			{
				_urlRequest = new URLRequest(HTTPStreamingUtils.normalizeURL(url));
			}
			else
			{
				_urlRequest = null;
			}
			
			_retryAfter = retryAfter;
			_bestEffortDownloaderMonitor = bestEffortDownloaderMonitor;
		}
		
		/**
		 * @private
		 * 
		 * The type of event. Must be one of the values in HTTPStreamRequestKind
		 **/ 
		public function get kind():String
		{
			return _kind;
		}
		
		/**
		 * @private
		 * 
		 * Valid when kind is HTTPStreamRequestKind.RETRY or HTTPStreamRequestKind.LIVE_STALL
		 * The amount of time to wait before trying again.
		 * 
		 **/ 
		public function get retryAfter():int
		{
			return _retryAfter;
		}
		
		/**
		 * @private
		 * 
		 * Valid when kind is HTTPStreamRequestKind.BEST_EFFORT_DOWNLOAD
		 * 
		 * HTTPStreamDownloader events will be dispatched to bestEffortDownloaderMonitor instead of the
		 * normal dispatcher. The index handler should be monitored for DOWNLOAD_CONTINUE and DOWNLOAD
		 * SKIP events.
		 * 
		 **/ 
		public function get bestEffortDownloaderMonitor():IEventDispatcher
		{
			return _bestEffortDownloaderMonitor;
		}
		
		/**
		 * @private
		 * 
		 * Valid when kind is HTTPStreamRequestKind.DOWNLOAD or 
		 * HTTPStreamRequestKind.BEST_EFFORT_DOWNLOAD 
		 * 
		 * The urlRequest for the url to download
		 **/ 
		public function get urlRequest():URLRequest
		{
			return _urlRequest;
		}
		
		
		/**
		 * @private
		 * 
		 * Valid when kind is HTTPStreamRequestKind.DOWNLOAD or 
		 * HTTPStreamRequestKind.BEST_EFFORT_DOWNLOAD 
		 * 
		 * The url to download
		 **/
		public function get url():String
		{
			if(_urlRequest == null)
			{
				return null;
			}
			else
			{
				return _urlRequest.url;
			}
		}
		
		/**
		 * @private
		 * 
		 * returns a string version of this.
		 **/
		public function toString():String
		{
			var s:String = "[HTTPStreamRequest kind="+kind;
			switch(kind)
			{
				case HTTPStreamRequestKind.BEST_EFFORT_DOWNLOAD:
				case HTTPStreamRequestKind.DOWNLOAD:
					s += ", url="+url;
					break;
				case HTTPStreamRequestKind.LIVE_STALL:
				case HTTPStreamRequestKind.RETRY:
					s += ", retryAfter="+retryAfter;
					break;
				case HTTPStreamRequestKind.DONE:
				default:
					break;
			}
			s += "]";
			return s;
		}
		
		private var _kind:String = null;
		private var _retryAfter:int = -1;
		private var _bestEffortDownloaderMonitor:IEventDispatcher = null;
		private var _urlRequest:URLRequest = null;
	}
}