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
	
	public class MetricMocker extends MetricBase
	{
		public function MetricMocker(type:String, qosInfoHistory:QoSInfoHistory, returnValue:MetricValue = null, v:Vector.<MetricValue> = null, ... args)
		{
			super(qosInfoHistory, type);
			_returnValue = returnValue;
			_vector = v;
		}
		
		public function set returnValue(value:MetricValue):void
		{
			_returnValue = value;
		}

		override internal function getValue():MetricValue
		{
			return _returnValue;
		}

		public function get vector():Vector.<MetricValue>
		{
			return _vector;
		}

		
		private var _returnValue:MetricValue;
		private var _vector:Vector.<MetricValue>=null;
	}
}