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
package org.osmf.net.httpstreaming
{
	import org.osmf.net.qos.FragmentDetails;
	import org.osmf.net.qos.QualityLevel;
	
	/**
	 * @private
	 * 
	 * This class holds Quality of Service information for a specific HDS stream.
	 * 
	 * @langversion 3.0
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @productversion OSMF 2.0
	 */
	public class HTTPStreamHandlerQoSInfo
	{
		/**
		 * Constructor
		 * 
		 * @param availableQualityLevels An array of the quality levels available
		 * @param actualIndex The index of the currently downloading quality level
		 * @param lastFragmentDetails The details of the last downloaded fragment
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 2.0
		 */
		public function HTTPStreamHandlerQoSInfo(availableQualityLevels:Vector.<QualityLevel>, actualIndex:uint, lastFragmentDetails:FragmentDetails = null)
		{
			_availableQualityLevels = availableQualityLevels;
			_actualIndex = actualIndex;
			_lastFragmentDetails = lastFragmentDetails;
		}
		
		/**
		 * An array of the quality levels available
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 2.0
		 */
		public function get availableQualityLevels():Vector.<QualityLevel>
		{
			return _availableQualityLevels;
		}
		
		/**
		 * The index of the currently downloading quality level
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 2.0
		 */
		public function get actualIndex():uint
		{
			return _actualIndex;
		}
		
		/**
		 * The details of the last downloaded fragment
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 2.0
		 */
		public function get lastFragmentDetails():FragmentDetails
		{
			return _lastFragmentDetails;
		}
		
		private var _availableQualityLevels:Vector.<QualityLevel>;
		private var _actualIndex:uint;
		private var _lastFragmentDetails:FragmentDetails;
	}
}