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
	import org.osmf.smpte.tt.enums.Enum;
	
	public class TextDecorationAttributeValue extends Enum
	{
		{initEnum(TextDecorationAttributeValue);} // static ctor
		
		public static const NONE:TextDecorationAttributeValue	= new TextDecorationAttributeValue("none");
		public static const UNDERLINE:TextDecorationAttributeValue = new TextDecorationAttributeValue("underline");
		public static const NO_UNDERLINE:TextDecorationAttributeValue	= new TextDecorationAttributeValue("noUnderline");
		public static const OVERLINE:TextDecorationAttributeValue = new TextDecorationAttributeValue("overline");
		public static const NO_OVERLINE:TextDecorationAttributeValue	= new TextDecorationAttributeValue("noOverline");
		public static const LINE_THROUGH:TextDecorationAttributeValue = new TextDecorationAttributeValue("lineThrough");
		public static const NO_LINE_THROUGH:TextDecorationAttributeValue	= new TextDecorationAttributeValue("noLineThrough");
		
		// Constant query.
		public static function getConstants():Array
		{ 
			return Enum.getConstants(TextDecorationAttributeValue);
		}
		public static function parseConstant(i_constantName:String, i_caseSensitive:Boolean=false):TextDecorationAttributeValue
		{ 
			return TextDecorationAttributeValue(Enum.parseConstant(TextDecorationAttributeValue, i_constantName, i_caseSensitive));
		}
		
		// constant attribute
		public function get value():String { return _value; }   
		
		// Private.
		/* private */ function TextDecorationAttributeValue(value:String)
		{ 
			_value = value;
		}
		private var _value:String;
	}
}