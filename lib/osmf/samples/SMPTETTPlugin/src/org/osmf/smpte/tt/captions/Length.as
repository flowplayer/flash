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
package org.osmf.smpte.tt.captions
{
	import org.osmf.smpte.tt.enums.Unit;

	public class Length
	{
		
		private var _value:Number;
		private var _unit:Unit;

		/**
		 * The numeric value of this length.
		 */
		public function get value():Number
		{
			return _value;
		}

		public function set value(value:Number):void
		{
			_value = value;
		}
		
		/**
		 * The unit of this length.
		 */
		public function get unit():Unit
		{
			return _unit;
		}

		public function set unit(value:Unit):void
		{
			_unit = value;
		}
		
		public function Length(lengthUnit:Unit=null, val:Number=0)
		{
			if(lengthUnit) _unit = lengthUnit;
			if(!isNaN(val)) _value = val;
		}
		
		public function toPixelLength(containerLength:Number=0):Number
		{
			switch (_unit)
			{
				case Unit.PERCENT:
				case Unit.CELL:
					return _value * containerLength;
				default:
					return _value;
			}
		}
		
		public function equals(length:Length):Boolean
		{
			return (_unit == length.unit && _value == length.value);
		}
		
		public function isEmpty():Boolean
		{
			return !_unit && !_value;
		}
	}
}