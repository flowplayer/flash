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
package org.osmf.utils
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.osmf.net.NetClient;
	import org.osmf.net.NetConnectionFactoryBase;
	import org.osmf.net.NetLoader;
	import org.osmf.net.rtmpstreaming.RTMPDynamicStreamingNetLoader;
	import org.osmf.netmocker.MockNetConnection;
	import org.osmf.netmocker.MockNetLoader;
	import org.osmf.netmocker.MockNetStream;
	import org.osmf.netmocker.MockRTMPDynamicStreamingNetLoader;
	
	/**
	 * Factory class for creating NetConnections and NetStreams.
	 * 
	 * By default, the class creates MockNetConnections and MockNetStreams.
	 * But a client can cause it to create true NetConnections and NetStreams
	 * simply by changing the constructor's useMockObjects parameter.
	 * 
	 * Note that useMockObjects is also exposed as a static getter/setter
	 * pair, so that it can be overridden for all tests with one call.
	 **/
	public class NetFactory
	{
		/**
		 * Constructor.
		 **/
		public function NetFactory(useMockObjects:Boolean=true)
		{
			_useMockObjects = useMockObjects;
		}
		
		/**
		 * Overrides the default behavior of using mock objects, so
		 * that mock objects are never used.
		 * 
		 * The default is false (use mock objects).
		 **/
		public static function set neverUseMockObjects(value:Boolean):void
		{
			_neverUseMockObjects = value;
		}
		
		public static function get neverUseMockObjects():Boolean
		{
			return _neverUseMockObjects;
		}
		
		/**
		 * Create and return a new NetLoader.
		 **/
		public function createNetLoader(factory:NetConnectionFactoryBase=null, reconnectStreams:Boolean=false):NetLoader
		{
			return useMockObjects
						? new MockNetLoader(factory, reconnectStreams)
						: new NetLoader(factory);
		}

		/**
		 * Create and return a new RTMPDynamicStreamingNetLoader.
		 **/
		public function createRTMPDynamicStreamingNetLoader():RTMPDynamicStreamingNetLoader
		{
			return useMockObjects
						? new MockRTMPDynamicStreamingNetLoader(null, false)
						: new RTMPDynamicStreamingNetLoader(null);
		}
		
		/**
		 * Create and return a new NetConnection.
		 **/
		public function createNetConnection():NetConnection
		{
			return useMockObjects
						? new MockNetConnection()
						: new NetConnection();
		}
		
		/**
		 * Create and return a new NetStream.
		 **/
		public function createNetStream(netConnection:NetConnection):NetStream
		{
			var netStream:NetStream = 
					useMockObjects
						? new org.osmf.netmocker.MockNetStream(netConnection)
						: new NetStream(netConnection);
			netStream.client = new NetClient();
			return netStream;
		}
		
		internal function get useMockObjects():Boolean
		{
			return _useMockObjects && !_neverUseMockObjects;
		}
		
		private static var _neverUseMockObjects:Boolean = false;
		
		private var _useMockObjects:Boolean = true;
	}
}
