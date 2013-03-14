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
	
	public class MetricComplexMocker extends MetricBase
	{
		public function MetricComplexMocker(type:String, qosInfoHistory:QoSInfoHistory, returnValid:Boolean = true)
		{
			super(qosInfoHistory, type);
			_returnValid = returnValid;
		}
		
		override protected function getValueForced():MetricValue
		{
			//returns the last playhead time for testing reasons
			//sets the validity to valid on invalid
			return(new MetricValue(++internalValue, _returnValid));			
			
		}

		public function get returnValid():Boolean
		{
			return _returnValid;
		}

		public function set returnValid(value:Boolean):void
		{
			_returnValid = value;
		}

		private var internalValue:int=0;
		private var _returnValid:Boolean;
	}
}