/*****************************************************
 *  
 *  Copyright 2011 Adobe Systems Incorporated.  All Rights Reserved.
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
package org.osmf.events
{
	import flash.events.Event;
	
	[ExcludeClass]
	
	/**
	 * @private
	 *
	 * This class holds a set of valid values for HttpStreamingEvent.reason
	 * 
	 */ 
	public class HTTPStreamingEventReason
	{
		/**
		 * The default reason.
		 **/
		public static const NORMAL:String = "normal";
		
		/**
		 * When the event type is DOWNLOAD_COMPLETE or DOWNLOAD_SKIP indicates
		 * that the download was triggered as a result of best effort.
		 **/
		public static const BEST_EFFORT:String = "bestEffort";
		
		/**
		 * When the event type is DOWNLOAD_ERROR, the download failed because it timed out (after the maximum number of retry attempts).  
		 **/
		public static const TIMEOUT:String = "timeout";
	}
}