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
	
	public class WritingMode extends Enum
	{
		{initEnum(WritingMode);} // static ctor
		
		public static const LEFT_RIGHT_TOP_BOTTOM:WritingMode = new WritingMode("lrtb");
		public static const RIGHT_LEFT_TOP_BOTTOM:WritingMode = new WritingMode("rltb");
		public static const TOP_BOTTOM_RIGHT_LEFT:WritingMode = new WritingMode("tbrl");
		public static const TOP_BOTTOM_LEFT_RIGHT:WritingMode = new WritingMode("tblr");
		
		// Constant query.
		public static function getConstants():Array
		{ 
			return Enum.getConstants(WritingMode);
		}
		public static function parseConstant(i_constantName:String, i_caseSensitive:Boolean=false):WritingMode
		{ 
			return WritingMode(Enum.parseConstant(WritingMode, i_constantName, i_caseSensitive));
		}
		
		// constant attribute
		public function get value():String { return _value; }   
		
		// Private.
		/* private */ function WritingMode(i_value:String)
		{ 
			_value = i_value;
		}
		private var _value:String;
	}
}