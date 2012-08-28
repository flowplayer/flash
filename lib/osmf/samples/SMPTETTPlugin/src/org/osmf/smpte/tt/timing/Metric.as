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
	
	public class Metric extends Enum
	{
		{initEnum(Metric);} // static ctor
		
		public static const HOURS:Metric	= new Metric("h");
		public static const MINUTES:Metric = new Metric("m");
		public static const SECONDS:Metric = new Metric("s");
		public static const MILLISECONDS:Metric = new Metric("ms");
		public static const FRAMES:Metric = new Metric("f");
		public static const TICKS:Metric = new Metric("t");
		
		// Constant query.
		public static function getConstants():Array
		{ 
			return Enum.getConstants(Metric);
		}
		public static function parseConstant(i_constantName:String, i_caseSensitive:Boolean=false):Metric
		{ 
			return Metric(Enum.parseConstant(Metric, i_constantName, i_caseSensitive));
		}
		
		// constant attribute
		public function get value():String { return _value; }   
		
		// Private.
		/* private */ function Metric(value:String)
		{ 
			_value = value;
		}
		private var _value:String;
	}
}