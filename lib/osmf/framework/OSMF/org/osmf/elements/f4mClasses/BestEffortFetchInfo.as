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
package org.osmf.elements.f4mClasses
{
	import mx.states.OverrideBase;

	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Configuration parameters for BestEffortFetch that are embedded in the f4m.
	 */ 
	public class BestEffortFetchInfo
	{	
		/**
		 * @private
		 */
		public static const DEFAULT_MAX_FORWARD_FETCHES:uint = 2;
		
		/**
		 * @private
		 */
		public static const DEFAULT_MAX_BACKWARD_FETCHES:uint = 2;

		/**
		 * @private
		 */
		public var maxForwardFetches:uint = DEFAULT_MAX_FORWARD_FETCHES;
		
		/**
		 * @private
		 */
		public var maxBackwardFetches:uint = DEFAULT_MAX_BACKWARD_FETCHES;
		
		/**
		 * @private
		 * 
		 * The typical duration of a segment (in milliseconds)
		 */
		public var segmentDuration:uint = 0;
		
		/**
		 * @private
		 * 
		 * The typical duration of a fragment (in milliseconds)
		 */
		public var fragmentDuration:uint = 0;
	}
}