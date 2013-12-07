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
	import org.osmf.net.qos.QoSInfoHistory;
	import org.osmf.net.qos.QoSInfoHistoryGenerator;

	public class MetricFactoryMocker extends MetricFactory
	{
		public function MetricFactoryMocker(qosInfoHistory:QoSInfoHistory = null)
		{
			super(qosInfoHistory);
		}
		
		/**
		 * qosInfoHistory is ignored (so it can safely be null)
		 * the parameters should only contain one MetricValue object (the desired return value of the metric)
		 */
		override public function buildMetric(type:String, ...args):MetricBase
		{
			var returnValue:MetricValue = args[0];
			
			return new MetricMocker(type, QoSInfoHistoryGenerator.generateSampleQoSInfoHistory(), returnValue);
		}
	}
}