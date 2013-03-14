/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.captioning.model
{
	/**
	 * This class represents a caption style.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.0
	 *  @productversion OSMF 1.0
	 */
	public class CaptionStyle
	{
		/**
		 * Creates a Style object.
		 * 
		 * @param id The ID is usually provided in the captioning document.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function CaptionStyle(id:String)
		{
			_id = id;
		}
		
		/**
		 * Get the CaptionStyle ID.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function get id():String 
		{
			return _id;
		}
		
		/**
		 * The background color for the control rendering 
		 * the captioning text in a hexadecimal format;
		 * for example, 0xff0000 is red.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function get backgroundColor():Object 
		{
			return _backgroundColor;
		}
		
		public function set backgroundColor(value:Object):void 
		{
			_backgroundColor = value;
		}
		
		/**
		 * The alpha transparency of the background color as
		 * a Number between 0 and 1.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function get backgroundColorAlpha():Object
		{
			return _backgroundColorAlpha;
		}
		
		public function set backgroundColorAlpha(value:Object):void
		{
			_backgroundColorAlpha = value;
		}
		
		/**
		 * The text color of the caption in a hexadecimal format;
		 * for example, 0xff0000 is red.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function get textColor():Object 
		{
			return _textColor;
		}
		
		public function set textColor(value:Object):void 
		{
			_textColor = value;
		}
		
		/**
		 * The alpha transparency of the text color as 
		 * a Number between 0 and 1.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		 
		 public function get textColorAlpha():Object
		 {
		 	return _textColorAlpha;
		 }
		 
		 public function set textColorAlpha(value:Object):void
		 {
		 	_textColorAlpha = value;
		 }
		
		/**
		 * The font family.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function get fontFamily():String 
		{
			return _fontFamily;
		}
		
		public function set fontFamily(value:String):void 
		{
			_fontFamily = value;
		}
		
		/**
		 * The font size in pixels.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function get fontSize():int 
		{
			return _fontSize;
		}
		
		public function set fontSize(value:int):void 
		{
			_fontSize = value;
		}
		
		/**
		 * The font style, normal or italic.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function get fontStyle():String 
		{
			return _fontStyle;
		}
		
		public function set fontStyle(value:String):void 
		{
			_fontStyle = value;
		}
		
		/**
		 * The font weight, normal or bold.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function get fontWeight():String 
		{
			return _fontWeight;
		}
		
		public function set fontWeight(value:String):void 
		{
			_fontWeight = value;
		}
		
		/**
		 * The text alignment, left, center, or right.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function get textAlign():String 
		{
			return _textAlign;
		}
		
		public function set textAlign(value:String):void 
		{
			_textAlign = value;
		}
		
		/**
		 * The word wrap option.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function get wrapOption():Boolean 
		{
			return _wrapOption;
		}
		
		public function set wrapOption(value:Boolean):void 
		{
			_wrapOption = value;
		}
		
		private var _id:String;
		private var _backgroundColor:Object;
		private var _backgroundColorAlpha:Object;
		private var _textColor:Object;
		private var _textColorAlpha:Object;
		private var _fontFamily:String;
		private var _fontSize:int;
		private var _fontStyle:String;
		private var _fontWeight:String;
		private var _textAlign:String;
		private var _wrapOption:Boolean;
	}
}
