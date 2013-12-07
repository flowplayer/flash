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
	public class TimeCodeComponents
	{
		private var _days:uint = 0;
		public function get days():uint
		{
			return _days;
		}
		public function set days(value:uint):void
		{
			_days = value;
		}
		
		private var _hours:int = 0;
		public function get hours():uint
		{
			return _hours;
		}

		public function set hours(value:uint):void
		{
			if(value>23) throw new Error("hours cannot be greater than 23");
			_hours = value;
		}
		
		private var _minutes:uint = 0;
		public function get minutes():uint
		{
			return _minutes;
		}
		public function set minutes(value:uint):void
		{
			if(value>59) throw new Error("minutes cannot not be greater than 59");
			_minutes = value;
		}
		
		private var _seconds:uint = 0;
		public function get seconds():uint
		{
			return _seconds;
		}
		public function set seconds(value:uint):void
		{
			if(value>59) throw new Error("seconds cannot not be greater than 59");
			_seconds = value;
		}
		
		private var _frames:uint = 0;
		public function get frames():uint
		{
			return _frames;
		}
		public function set frames(value:uint):void
		{
			_frames = value;
		}

		public function TimeCodeComponents(p_days:uint=0,p_hours:uint=0,p_minutes:uint=0,p_seconds:uint=0,p_frames:uint=0)
		{
			_days = p_days;
			_hours = p_hours;
			_minutes = p_minutes;
			_seconds = p_seconds;
			_frames = p_frames;
		}
		
		

	}
}