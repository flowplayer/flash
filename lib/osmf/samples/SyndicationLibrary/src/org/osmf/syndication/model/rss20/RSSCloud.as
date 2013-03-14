/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1_the "License"); you may not use this file except in
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
*  Portions created by Akamai Technologies, Inc. are Copyright_C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.syndication.model.rss20
{
	/**
	 * Represents a cloud element in the feed.
	 */
	public class RSSCloud
	{
		/**
		 * the domain name or IP address of the cloud.
		 */
		public function get domain():String
		{
			return _domain;
		}
		
		public function set domain(value:String):void
		{
			_domain = value;
		}
		
		/**
		 * The TCP port that the cloud is running on.
		 */
		public function get port():String
		{
			return _port;	
		}
		
		public function set port(value:String):void
		{
			_port = value;
		}
		
		/**
		 * Path is the location of the cloud's responder.
		 */
		public function get path():String
		{
			return _path;
		}
		
		public function set path(value:String):void
		{
			_path = value;
		}
		
		/**
		 * The name of the procedure to call to request notification.
		 */
		public function get registerProcedure():String
		{
			return _registerProcedure;
		}
		
		public function set registerProcedure(value:String):void
		{
			_registerProcedure = value;
		}
		
		/**
		 * protocol is xml-rpc, soap or http-post (case-sensitive), 
		 * indicating which protocol is to be used.
		 */
		public function get protocol():String
		{
			return _protocol;
		}
		
		public function set protocol(value:String):void
		{
			_protocol = value;
		}
		
		private var _domain:String;
		private var _port:String;
		private var _path:String;
		private var _registerProcedure:String;
		private var _protocol:String;
		
	}
}
