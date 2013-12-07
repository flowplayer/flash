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
	import org.osmf.net.qos.QoSInfo;
	import org.osmf.net.qos.QoSInfoHistory;
	
	/**
	 * Current status metric
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class CurrentStatusMetric extends MetricBase
	{
		/**
		 * Constructor.
		 * 
		 * @param qosInfoHistory The QoSInfoHistory to be used for computing the metric
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function CurrentStatusMetric(qosInfoHistory:QoSInfoHistory)
		{
			super(qosInfoHistory, MetricType.CURRENT_STATUS);
		}
		
		/**
		 * The value of the current status
		 * 
		 * @return A vector containing the current index and the actual index
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		override protected function getValueForced():MetricValue
		{
			var qosInfo:QoSInfo = qosInfoHistory.getLatestQoSInfo();
			
			var value:Vector.<uint> = new Vector.<uint>();
			value.push(qosInfo.currentIndex);
			value.push(qosInfo.actualIndex);
			
			return new MetricValue(value, true);
		}
	}
}