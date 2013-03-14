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
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;

	public class Font
	{
		public function get fontFamily():String
		{
			return _fontFamily;
		}
		public function get fontStyle():String
		{
			return _fontStyle;
		}
		public function get fontSize():Number
		{
			return _fontSize;
		}
		public function get emHeight():Number
		{
			return _fontSize;
		}
		public function get fontWeight():String
		{
			return _fontWeight;
		}
		public function get leftToRight():Boolean
		{
			return _leftToRight;
		}
		public function set leftToRight(p_leftToRight:Boolean):void
		{
			_leftToRight = p_leftToRight;
		}
		public function Font(p_fontFamily:String, p_emHeight:Number, p_fontWeight:FontWeightAttributeValue, p_fontStyle:FontStyleAttributeValue)
		{
			leftToRight = true;
			_fontFamily = p_fontFamily;
			_fontSize = p_emHeight;
			switch (p_fontStyle)
			{
				case FontStyleAttributeValue.ITALIC:	
				case FontStyleAttributeValue.OBLIQUE:
				case FontStyleAttributeValue.REVERSE_OBLIQUE:
					_fontStyle = FontPosture.ITALIC;
					break;
				default:
					_fontStyle = FontPosture.NORMAL;
					break;
			}
			switch (p_fontWeight)
			{
				case FontWeightAttributeValue.BOLD: 
					_fontWeight = FontWeight.BOLD;
					break;
				default:
					_fontWeight = FontWeight.NORMAL;
					break;
			}
		}
		private var _fontFamily:String = "_sans";
		private var _fontSize:Number = 14;
		private var _fontStyle:String = FontPosture.ITALIC;
		private var _fontWeight:String = FontWeight.NORMAL;
		private var _leftToRight:Boolean = true;
	}
}