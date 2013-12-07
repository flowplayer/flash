/*****************************************************
*  
*  Copyright 2010 Eyewonder, LLC.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Eyewonder, LLC.
*  Portions created by Eyewonder, LLC. are Copyright (C) 2010 
*  Eyewonder, LLC. A Limelight Networks Business. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.vast.parser.base
{	
	/**
	 * Vast time data
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	 

	public dynamic class VAST2Time
	{
		/* Time in hh:mm:ss format */
		private var _hours:Number;
		private var _minutes:Number;
		private var _seconds:Number;
		
		/** VAST2Time - constructor
		 *
		 * @param hours:Number Hours
		 * @param minutes:Number Minutes
		 * @param seconds:Number Seconds 
		*/ 
		public function VAST2Time(hours:Number = 0, minutes:Number = 0, seconds:Number = 0)	
		{
			_hours = hours;
			_minutes = minutes;
			_seconds = seconds;
		}
		
		public function get hh() : Number { return _hours;} 
		public function set hh(val:Number):void { _hours = val; }		
		public function get mm() : Number { return _minutes;} 
		public function set mm(val:Number):void { _minutes = val; }		
		public function get ss() : Number { return _minutes;} 
		public function set ss(val:Number):void { _minutes = val; }
		public function get totalSeconds():Number { return (_hours*3600 + _minutes*60 + _seconds)}	
		public function get totalMilliseconds():Number { return 1000*totalSeconds}			
	}
}
