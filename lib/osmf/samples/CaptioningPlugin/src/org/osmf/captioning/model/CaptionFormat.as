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
	 * Represents formatting for a caption object. 
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.0
	 *  @productversion OSMF 1.0
	 */	
	public class CaptionFormat
	{
		public static const UNDEFINED_INDEX:int = -1;
		
		/**
		 * Creates a CaptionFormat object specifying the Style 
		 * object and the zero-based start and end indices of the range.
		 * 
		 * @param style The instance of CaptionStyle object to apply.
		 * @param start The optional zero-based index position specifying 
		 * the first character of the desired range of text.
		 * @param end The optional zero-based index position specifying the 
		 * last character of the desired range of text. 
		 * 
		 * @throws ArgumentError If the style argument is null.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function CaptionFormat(style:CaptionStyle, start:int = UNDEFINED_INDEX, end:int = UNDEFINED_INDEX)
		{
			// What good is a caption format without a style?
			if (style == null)
			{
				throw new ArgumentError(MISSING_STYLE_ERROR_MSG);
			}
			_startIndex = start;
			_endIndex = end;
			_style = style;
		}
		
		/**
		 *  Get the start index supplied to the constructor.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function get startIndex():int 
		{
			return _startIndex;
		}
		
		/**
		 * Get the end index supplied to the constructor.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function get endIndex():int 
		{
			return _endIndex;
		}
		
		/**
		 * Get the style object supplied to the constructor.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function get style():CaptionStyle 
		{
			return _style;
		}

		private var _startIndex:int;
		private var _endIndex:int;
		private var _style:CaptionStyle;
		
		private static const MISSING_STYLE_ERROR_MSG:String = "CaptionStyle is required for CaptionFormat objects";

	}
}
