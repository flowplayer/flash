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
	public class TimedTextAnimation extends TimedTextElement
	{
		private var _propertyName:String;
		
		/**
		 * The property that will be animated.
		 */
		public function get propertyName():String
		{
			return _propertyName;
		}
		public function set propertyName(value:String):void
		{
			_propertyName = value;
		}
		
		public function TimedTextAnimation(start:Number, end:Number)
		{
			super(start, end);
		}

		public function mergeStyle(s:TimedTextStyle):void
		{
			switch(propertyName){
				case "backgroundColor":
					s.backgroundColor = style.backgroundColor;
					break;
				case "backgroundAlpha":
					s.backgroundAlpha = style.backgroundAlpha;
					break;
				case "color":
					s.color = style.color;
					break;
				case "textAlpha":
					s.textAlpha = style.textAlpha;
					break;
				case "displayAlign":
					s.displayAlign = style.displayAlign;
					break;
				case "display":
					s.display = style.display;
					break;
				case "extent":
					s.extent = style.extent;
					break;
				case "fontFamily":
					s.fontFamily = style.fontFamily;
					break;
				case "fontSize":
				case "ttFontSize":
					s.ttFontSize = style.ttFontSize;
					s.fontSize = style.fontSize;
					break;
				case "fontStyle":
					s.fontStyle = style.fontStyle;
					break;
				case "fontWeight":
					s.fontWeight = style.fontWeight;
					break;
				case "lineHeight":
				case "ttLineHeight":
					s.ttLineHeight = style.ttLineHeight;
					s.lineHeight = style.lineHeight;
					break;
				case "opacity":
					s.opacity = style.opacity;
					break;
				case "origin":
					s.origin = style.origin;
					break;
				case "overflow":
					s.overflow = style.overflow;
					break;
				case "padding":
					s.padding = style.padding;
					break;
				case "showBackground":
					s.showBackground = style.showBackground;
					break;
				case "textAlign":
					s.textAlign = style.textAlign;
					break;
				case "lineThrough":
				case "textDecoration":
					s.textDecoration = style.textDecoration;
					s.lineThrough = style.lineThrough;
					break;
				case "textOutline":
					s.textOutline = style.textOutline;
					break;
				case "visibility":
					s.visibility = style.visibility;
					break;
				case "wrapOption":
					s.wrapOption = style.wrapOption;
					break;
				case "zIndex":
					s.zIndex = style.zIndex;
					break;
			}
		}

		

	}
}