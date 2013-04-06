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
	
	public class Visibility extends Enum
	{
		{initEnum(Visibility);} // static ctor
		
		public static const VISIBLE:Visibility = new Visibility("visible");
		public static const HIDDEN:Visibility = new Visibility("hidden");
		
		// Constant query.
		public static function getConstants():Array
		{ 
			return Enum.getConstants(Visibility);
		}
		public static function parseConstant(i_constantName:String, i_caseSensitive:Boolean=false):Visibility
		{ 
			return Visibility(Enum.parseConstant(Visibility, i_constantName, i_caseSensitive));
		}
		
		// constant attribute
		public function get value():String { return _value; }   
		
		// Private.
		/* private */ function Visibility(i_value:String)
		{ 
			_value = i_value;
		}
		private var _value:String;
	}
}