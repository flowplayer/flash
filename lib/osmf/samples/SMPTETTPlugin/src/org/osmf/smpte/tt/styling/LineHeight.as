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

	public class LineHeight extends NumberPair
	{
		private static var _cache:Dictionary = new Dictionary();
		public static function getLineHeight(value:*):LineHeight
		{
			if (_cache[value] !== undefined)
			{
				return _cache[value];
			}
			else
			{
				var lineHeight:LineHeight = new LineHeight(value);
				_cache[value] = lineHeight;
				return lineHeight;
			}
		}
		
		public function get width():Number
		{
			return first;
		}
		public function get height():Number
		{
			return second;
		}
		public function LineHeight(p_expression:*)
		{
			if(p_expression is String){
				super(p_expression);
			} else if(p_expression is Number){
				horizontalValue = verticalValue = p_expression;
				isRelativeHorizontal = isRelativeVertical = false;
				isRelativeFontHorizontal = isRelativeFontVertical = false;
			}
		}
	}
}