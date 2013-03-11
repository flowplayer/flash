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
	
	public class FragmentCountMetricMocker extends FragmentCountMetric
	{
		public function FragmentCountMetricMocker(qosInfoHistory:QoSInfoHistory)
		{
			super(qosInfoHistory);
			_internalValue=undefined;
			_returnValid=false;
		}
		
		override protected function getValueForced():MetricValue
		{
			//returns the internal value for testing reasons
			//sets the validity to valid on invalid
			return(new MetricValue(_internalValue, _returnValid));			
			
		}
		
		override internal function getValue():MetricValue
		{
			return getValueForced();
		}
		
		public function get returnValid():Boolean
		{
			return _returnValid;
		}

		public function set returnValid(value:Boolean):void
		{
			_returnValid = value;
		}
		
		public function get internalValue():int
		{
			return _internalValue;
		}
		
		public function set internalValue(value:int):void
		{
			_internalValue = value;
		}

		private var _internalValue:int=0;
		private var _returnValid:Boolean;
	}
}