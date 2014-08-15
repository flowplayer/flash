/*****************************************************
 *  
 *  Copyright 2012 Adobe Systems Incorporated.  All Rights Reserved.
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
 *  Portions created by Adobe Systems Incorporated are Copyright (C) 2012 Adobe Systems 
 *  Incorporated. All Rights Reserved. 
 *  
 *****************************************************/
package org.osmf.net.httpstreaming
{
	/**
	 * @private
	 *
	 * This class holds a set of valid values for HttpStreamRequest.kind
	 * 
	 */ 
	public class HTTPStreamRequestKind
	{
		/**
		 * @private
		 *
		 * RETRY indicates that the caller should try again later after a specified interval.
		 */ 
		public static const RETRY:String = "retry";
		
		/**
		 * @private
		 *
		 * DOWNLOAD indicates that the request will be a normal download.
		 */ 
		public static const DOWNLOAD:String = "download";
		
		/**
		 * @private
		 *
		 * BEST_EFFORT_DOWNLOAD indicates that the request will be a best-effort download.
		 */ 
		public static const BEST_EFFORT_DOWNLOAD:String = "bestEffortDownload";
		
		/**
		 * @private
		 *
		 * LIVE_STALL indicates there are no additional valid fragments available but
		 * the event is not done.
		 */ 
		public static const LIVE_STALL:String = "liveStall";		
		
		/**
		 * @private
		 *
		 * DONE indicates there are no additional valid fragments available because
		 * there is actually no more content.
		 */ 
		public static const DONE:String = "done";		
	}
}