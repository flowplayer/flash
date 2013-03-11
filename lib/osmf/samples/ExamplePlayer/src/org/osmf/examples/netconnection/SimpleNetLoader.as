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
package org.osmf.examples.netconnection
{
	import flash.errors.IllegalOperationError;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.osmf.media.URLResource;
	import org.osmf.net.NetLoader;

	/**
	 * A NetLoader subclass that allows you to pass in an active NetConnection
	 * and/or NetStream.  Useful for integrating with existing connection
	 * frameworks or logic.  This example is somewhat over-simplified, in that
	 * it always uses the same NetConnection or NetStream.
	 **/
	public class SimpleNetLoader extends NetLoader
	{
		/**
		 * Constructor.
		 * 
		 * @param netConnection The NetConnection to use for any request.
		 * @param netStream The NetStream to use for any request.
		 **/
		public function SimpleNetLoader(netConnection:NetConnection, netStream:NetStream)
		{
			super(new SimpleNetConnectionFactory(netConnection));
			
			this.netStream = netStream;
		}
		
		/**
		 * @private
		 **/
		override protected function createNetStream(connection:NetConnection, resource:URLResource):NetStream
		{
			return netStream != null ? netStream : new NetStream(connection);;
		}
		
		private var netStream:NetStream;
	}
}