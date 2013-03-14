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
	
	public class WrapOption extends Enum
	{
		{initEnum(WrapOption);} // static ctor
		
		public static const WRAP:WrapOption	= new WrapOption("wrap");
		public static const NOWRAP:WrapOption = new WrapOption("noWrap");
		
		// Constant query.
		public static function getConstants():Array
		{ 
			return Enum.getConstants(WrapOption);
		}
		public static function parseConstant(i_constantName:String, i_caseSensitive:Boolean=false):WrapOption
		{ 
			return WrapOption(Enum.parseConstant(WrapOption, i_constantName, i_caseSensitive));
		}
		
		// constant attribute
		public function get value():String { return _value; }   
		
		// Private.
		/* private */ function WrapOption(value:String)
		{ 
			_value = value;
		}
		private var _value:String;
	}
}