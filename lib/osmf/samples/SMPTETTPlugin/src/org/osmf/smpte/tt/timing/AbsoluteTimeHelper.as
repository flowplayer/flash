/***********************************************************
 * 
 * Copyright 2011 Adobe Systems Incorporated. All Rights Reserved.
 *
 * *********************************************************
 * The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 * (the "License"); you may not use this file except in
 * compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems
 * Incorporated. All Rights Reserved.
 **********************************************************/
package org.osmf.smpte.tt.timing
{
	import org.osmf.smpte.tt.enums.NumberType;
	import org.osmf.smpte.tt.timing.TimeCode;
	
	public class AbsoluteTimeHelper
	{
		public function AbsoluteTimeHelper(value:Number, numberType:NumberType=null)
		{
			switch(numberType){
				case NumberType.ULONG :
					_time27Mhz = value;
					_timeAsFloat = TimeCode.ticks27MhzToAbsoluteTime(value);
					_pcrTime = TimeCode.ticks27MhzToPcrTb(value);
					break;
				default:
					_timeAsFloat = value;
					_time27Mhz = TimeCode.absoluteTimeToTicks27Mhz(this);
					_pcrTime = TimeCode.absoluteTimeToTicksPcrTb(this);
					break;
			}
		}
		
		private var _timeAsFloat:Number;
		public function get timeAsFloat():Number
		{
			return _timeAsFloat;
		}
		public function get timeAsDouble():Number
		{
			return _timeAsFloat;
		}
		private var _pcrTime:Number;
		public function get pcrTime():Number
		{
			return _pcrTime;
		}
		private var _time27Mhz:Number;
		public function get time27Mhz():Number
		{
			return _time27Mhz;
		}
		
		public function toString():String
		{
			return String(_timeAsFloat);
		}
	}
}