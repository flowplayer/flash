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
package org.osmf.smpte.tt.enums
{
	import org.osmf.smpte.tt.enums.Enum;
	
	public class Unit extends Enum
	{
		{initEnum(Unit);} // static ctor
		
		public static const PIXEL:Unit	= new Unit("px");
		public static const EM:Unit = new Unit("em");
		public static const CELL:Unit = new Unit("c");
		public static const PERCENT:Unit = new Unit("%");
		
		// Constant query.
		public static function getConstants():Array
		{ 
			return Enum.getConstants(Unit);
		}
		public static function parseConstant(i_constantName:String, i_caseSensitive:Boolean=false):Unit
		{ 
			return Unit(Enum.parseConstant(Unit, i_constantName, i_caseSensitive));
		}
		
		// constant attribute
		public function get value():String { return _value; }   
		
		// Private.
		/* private */ function Unit(value:String)
		{ 
			_value = value;
		}
		private var _value:String;
	}
}