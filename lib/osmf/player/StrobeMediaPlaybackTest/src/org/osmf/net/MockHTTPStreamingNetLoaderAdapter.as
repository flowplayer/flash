/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 *  The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 *  (the "License"); you may not use this file except in
 *  compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 **********************************************************/

package org.osmf.net
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.osmf.media.URLResource;

	public class MockHTTPStreamingNetLoaderAdapter extends HTTPStreamingNetLoaderAdapter
	{
		/**
		 * Constructor.
		 */ 
		public function MockHTTPStreamingNetLoaderAdapter(playbackOptimizationManager:PlaybackOptimizationManager)
		{
			super(playbackOptimizationManager);
		}
		
		/**
		 *
		 * The factory function for creating a NetStream.
		 * 
		 * @param connection The NetConnection to associate with the new NetStream.
		 * @param resource The resource whose content will be played in the NetStream.
		 * 
		 * @return A new NetStream associated with the NetConnection.
		 **/
		override protected function createNetStream(connection:NetConnection, resource:URLResource):NetStream
		{
			return new MockHTTPNetStream(connection, 0);
		}
	}
}