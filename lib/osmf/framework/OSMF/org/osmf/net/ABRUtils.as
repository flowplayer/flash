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
 *  Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems 
 *  Incorporated. All Rights Reserved. 
 *  
 *****************************************************/
package org.osmf.net
{
	/**
	 * ABRUtils provides utility functions used in the Adaptive Bitrate components  
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */ 
	public class ABRUtils
	{
		/**
		 * Validates a Vector of weights.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */ 
		public static function validateWeights(weights:Vector.<Number>, desiredLength:int = -1):void
		{
			if (weights == null)
			{
				throw new ArgumentError("The weights vector is null.");
			}
			
			if (desiredLength > -1 && weights.length != desiredLength)
			{
				throw new ArgumentError("Invalid number of weights.");
			}
			
			var atLeastOneWeightIsNonZero:Boolean = false;
			
			for each (var weight:Number in weights)
			{
				if (isNaN(weight) || weight < 0)
				{
					throw new ArgumentError("Invalid weight in weights Vector.");
				}
				
				if (weight > 0)
				{
					atLeastOneWeightIsNonZero = true;
				}
			}
			
			if (!atLeastOneWeightIsNonZero)
			{
				throw new ArgumentError("At least one weight must be greater than 0.");
			}
		}
		
		/**
		 * Rounds a number by trimming its decimals down to three
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public static function roundNumber(value:Number):Number
		{
			if (isNaN(value))
			{
				return value;
			}
			
			return Math.round(value * 1000) / 1000;
		}
	}
}