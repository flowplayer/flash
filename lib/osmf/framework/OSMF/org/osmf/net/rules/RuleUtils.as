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
package org.osmf.net.rules
{
	import org.osmf.net.metrics.MetricBase;
	import org.osmf.net.metrics.MetricValue;
	import org.osmf.net.qos.QualityLevel;

	/**
	 * RuleUtils provides utility functions for the rules  
	 * 
	 * @see org.osmf.net.abr.RuleBase
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */ 
	public class RuleUtils
	{
		/**
		 * <p>Computes the actual bitrate (the current value of the bitrate of
		 * the downloading stream). In case such a value cannot be computed,
		 * this function will return the declared value of the stream.</p>
		 * 
		 * In case not even the declared value is available, the function
		 * returns NaN
		 * 
		 * @see org.osmf.net.abr.RuleBase
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */ 
		public static function computeActualBitrate
			( actualBitrateMetric:MetricBase
			, availableQualityLevelsMetric:MetricBase
			, currentStatusMetric:MetricBase
			):Number
		{
			var actualBitrateMetricValue:MetricValue = actualBitrateMetric.value;
			if (actualBitrateMetricValue.valid)
			{
				return actualBitrateMetricValue.value as Number;
			}
			else
			{
				var availableQualityLevelsMetricValue:MetricValue = availableQualityLevelsMetric.value;
				var currentStatusMetricValue:MetricValue = currentStatusMetric.value;
				
				if (!availableQualityLevelsMetricValue.valid || !currentStatusMetricValue.valid)
				{
					return Number.NaN;
				}
				
				var actualIndex:uint = (currentStatusMetricValue.value as Vector.<uint>)[1];
				
				var qualityLevels:Vector.<QualityLevel> = availableQualityLevelsMetricValue.value as Vector.<QualityLevel>;
				
				return qualityLevels[actualIndex].bitrate;
			}
		}
	}
}