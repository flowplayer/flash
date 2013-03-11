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
	
	public class DisplayAlign extends Enum
	{
		{initEnum(DisplayAlign);} // static ctor
		
		public static const Before:DisplayAlign	= new DisplayAlign("before");
		public static const Center:DisplayAlign = new DisplayAlign("center");
		public static const After:DisplayAlign = new DisplayAlign("after");
		
		// Constant query.
		public static function getConstants():Array
		{ 
			return Enum.getConstants(DisplayAlign);
		}
		public static function parseConstant(i_constantName:String, i_caseSensitive:Boolean=false):DisplayAlign
		{ 
			return DisplayAlign(Enum.parseConstant(DisplayAlign, i_constantName, i_caseSensitive));
		}
		
		// constant attribute
		public function get value():String { return _value; }   
		
		// Private.
		/* private */ function DisplayAlign(value:String)
		{ 
			_value = value;
		}
		private var _value:String;
	}
}