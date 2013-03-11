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
 *  Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems 
 *  Incorporated. All Rights Reserved. 
 *  
 *****************************************************/
package org.osmf.events
{
	import org.osmf.utils.OSMFStrings;

	/**
	 * The MetricErrorCodes class provides static constants for error IDs.
	 * Error IDs zero through 999 are reserved for use by the
	 * framework.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */ 
	public final class MetricErrorCodes
	{
		/**
		 * Error constant for when a request for a metric was made with an inexistent metric type
		 */
		public static const INVALID_METRIC_TYPE:int	=		1;
		
		/**
		 * @private
		 * 
		 * Returns a message for the error of the specified ID.  If the error ID
		 * is unknown, returns the empty string.
		 * 
		 * @param errorID The ID for the error.
		 * 
		 * @return The message for the error with the specified ID.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		internal static function getMessageForErrorID(errorID:int):String
		{
			var message:String = "";
			
			for (var i:int = 0; i < errorMap.length; i++)
			{
				if (errorMap[i].errorID == errorID)
				{
					message = OSMFStrings.getString(errorMap[i].message);
					break;
				}
			}
			
			return message;
		}
		
		private static const errorMap:Array =
			[
				{errorID:INVALID_METRIC_TYPE,			message:OSMFStrings.METRIC_NOT_FOUND}
			];
	}
}