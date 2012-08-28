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
package org.osmf.smpte.tt.timing
{
	import org.osmf.smpte.tt.enums.Enum;
	
	public class ClockMode extends Enum
	{
		{initEnum(ClockMode);} // static ctor
		
		public static const LOCAL:ClockMode	= new ClockMode("local");
		public static const GPS:ClockMode = new ClockMode("gps");
		public static const UTC:ClockMode = new ClockMode("utc");
		
		// Constant query.
		public static function getConstants():Array
		{ 
			return Enum.getConstants(ClockMode);
		}
		public static function parseConstant(i_constantName:String, i_caseSensitive:Boolean=false):ClockMode
		{ 
			return ClockMode(Enum.parseConstant(ClockMode, i_constantName, i_caseSensitive));
		}
		
		// constant attribute
		public function get value():String { return _value; }   
		
		// Private.
		/* private */ function ClockMode(value:String)
		{ 
			_value = value;
		}
		private var _value:String;
	}
}