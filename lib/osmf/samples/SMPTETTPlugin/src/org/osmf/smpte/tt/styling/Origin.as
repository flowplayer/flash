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
package org.osmf.smpte.tt.styling
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import org.osmf.smpte.tt.enums.Unit;

	public class Origin extends NumberPair
	{
		private static var _cache:Dictionary = new Dictionary();
		public static function getOrigin(value:*):Origin
		{
			if (_cache[value] !== undefined)
			{
				return _cache[value];
			}
			else
			{
				var origin:Origin = new Origin(value);
				_cache[value] = origin;
				return origin;
			}
		}
		
		public function get x():Number
		{
			return first;
		}
		public function get y():Number
		{
			return second;
		}
		
		public function Origin(...p_args) {
			switch (p_args.length) {
				case 1: 
					if(p_args[0] is NumberPair || p_args[0] is String) {
						super(p_args[0]);
					}
					if(unitMeasureHorizontal == Unit.PERCENT)
					{
						isRelativeFontHorizontal = false;
						isRelativeHorizontal = true;
					}
					if (unitMeasureVertical == Unit.PERCENT)
					{
						isRelativeFontVertical = false;
						isRelativeVertical = true;
					}
					break;
				case 2:
					if(p_args[0] is Number && p_args[1] is Number)
					{
						horizontalValue = p_args[0];
						verticalValue = p_args[1];
						isRelativeHorizontal = isRelativeVertical = false;
						isRelativeFontHorizontal = isRelativeFontVertical = false;
					}
					break;
			}
		}
		
		override public function toString():String
		{
			var expression:String = "["+( typeof this) +" "+flash.utils.getQualifiedClassName(this)+"] ";
			if(this.isEmpty())
			{
				return expression;
			} else
			{
				return expression+super.toString();
			}
		}
	}
}
