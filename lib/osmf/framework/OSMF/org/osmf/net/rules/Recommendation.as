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
package org.osmf.net.rules
{
	/**
	 * Recommendation represents a RuleBase's recommendation.<br />
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class Recommendation
	{
		/**
		 * Constructor.
		 * 
		 * @param bitrate The ideal bitrate to switch to (kbps; 1 kilobit = 1000 bits)
		 * @param confidence The confidence in the bitrate recommendation (between 0 and 1).
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function Recommendation(ruleType:String, bitrate:Number, confidence:Number)
		{
			if (ruleType == null)
			{
				throw new ArgumentError("ruleType cannot be null.");
			}
			
			if (isNaN(confidence) || confidence < 0 || confidence > 1)
			{
				throw new ArgumentError("Invalid confidence!");
			}
			
			if (isNaN(bitrate) || bitrate < 0)
			{
				throw new ArgumentError("Invalid bitrate!");
			}
			
			_ruleType = ruleType;
			_bitrate = bitrate;
			_confidence = confidence;
		}
		
		public function get ruleType():String
		{
			return _ruleType;
		}
		
		/**
		 * The bitrate recommendation
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get bitrate():Number
		{
			return _bitrate;
		}
		
		/**
		 * Confidence in the recommendation
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get confidence():Number
		{
			return _confidence;
		}
		
		private var _ruleType:String;
		private var _bitrate:Number;
		private var _confidence:Number;
	}
}