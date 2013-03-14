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

	public class FontSize extends NumberPair
	{
		private static var _cache:Dictionary = new Dictionary();
		public static function getFontSize(value:*):FontSize
		{
			if (_cache[value])
			{
				return _cache[value];
			}
			else
			{
				var fontSize:FontSize = new FontSize(value);
				_cache[value] = fontSize;
				return fontSize;
			}
		}
		
		public function get fontWidth():Number
		{
			return first;
		}
		public function get fontHeight():Number
		{
			return second;
		}
		public function FontSize(...p_args)
		{
			switch (p_args.length) {
				case 4: 
					if((p_args[0] is NumberPair || p_args[0] is String)
						&& p_args[2] is Number 
						&& p_args[3] is Number)
					{
						super(p_args[0]);
						if(p_args[1] != null && p_args[1] is FontSize)
						{
							setFontContext(FontSize(p_args[1]).fontWidth, FontSize(p_args[1]).fontHeight);
						}
						setContext(p_args[2],  p_args[3]);
					} 
					break;
				case 2:
					if( p_args[0] is Number 
						&& p_args[1] is Number)
					{
						horizontalValue = p_args[0];
						verticalValue = p_args[1];
						isRelativeHorizontal = isRelativeVertical = false;
						isRelativeFontHorizontal = isRelativeFontVertical = false;
					}
					break;
				case 1:
					if( p_args[0] is Number)
					{
						horizontalValue = verticalValue = p_args[0];
						isRelativeHorizontal = isRelativeVertical = false;
						isRelativeFontHorizontal = isRelativeFontVertical = false;
					} else if(p_args[0] is String)
					{
						parse(p_args[0]);
					}
					break;
			}
		}
		
		/**
		 * Set the number of cells up into which to divide the render canvas
		 *
		 *	@param p_expression
		 *
		 * 	@langversion ActionScript 3.0
		 *	@playerversion Flash 9.0
		 *	@tiptext
		 */
		public static function setCellSize(p_expression:String):void
		{
			NumberPair.setCellSize(p_expression);
		}
		
	}
}