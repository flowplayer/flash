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
package org.osmf.net.metrics
{
	import org.osmf.net.qos.QoSInfoHistoryGenerator;

	public class MetricRepositoryMocker extends MetricRepository
	{
		public function MetricRepositoryMocker(metricFactory:MetricFactory)
		{
			super(metricFactory);
		}
		
		/**
		 * Second parameter should be the desired return value of the metric (a MetricValue object)
		 */
		override public function getMetric(type:String, ...parameters):MetricBase
		{
			var returnValue:MetricValue = parameters[0];
			return new MetricMocker(type, QoSInfoHistoryGenerator.generateSampleQoSInfoHistory(), returnValue);
		}
	}
}