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
	import org.osmf.smpte.tt.enums.Enum;
	
	public class TextAlignment extends Enum
	{

		{initEnum(TextAlignment);} // static ctor
		
		public static const Center:TextAlignment = new TextAlignment("center");
		public static const End:TextAlignment = new TextAlignment("end");
		public static const Justify:TextAlignment = new TextAlignment("justify");
		public static const Left:TextAlignment = new TextAlignment("left");
		public static const Right:TextAlignment = new TextAlignment("right");
		public static const Start:TextAlignment = new TextAlignment("start");
		
		// Constant query.
		public static function getConstants():Array
		{ 
			return Enum.getConstants(TextAlignment);
		}
		public static function parseConstant(i_constantName:String, i_caseSensitive:Boolean=false):TextAlignment
		{ 
			return TextAlignment(Enum.parseConstant(TextAlignment, i_constantName, i_caseSensitive));
		}
		
		// constant attribute
		public function get value():String { return _value; }   
		
		// Private.
		/* private */ function TextAlignment(value:String)
		{ 
			_value = value;
		}
		private var _value:String;
	}
}