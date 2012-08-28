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
	
	public class SmpteFrameRate extends Enum
	{
		{initEnum(SmpteFrameRate);} // static ctor
		/**
		 * SMPTE 23.98 frame rate. Also known as Film Sync.
		 */
		public static const SMPTE_2398:SmpteFrameRate	= new SmpteFrameRate(0);
		/**
		 * SMPTE 24 fps frame rate.
		 */
		public static const SMPTE_24:SmpteFrameRate = new SmpteFrameRate(1);
		/**
		 * SMPTE 25 fps frame rate. Also known as PAL.
		 */
		public static const SMPTE_25:SmpteFrameRate = new SmpteFrameRate(2);
		/**
		 * SMPTE 29.97 fps Drop Frame timecode. Used in the NTSC television system.
		 */
		public static const SMPTE_2997_DROP:SmpteFrameRate = new SmpteFrameRate(3);
		/**
		 * SMPTE 29.97 fps Non Drop Fram timecode. Used in the NTSC television system.
		 */
		public static const SMPTE_2997_NONDROP:SmpteFrameRate = new SmpteFrameRate(4);
		/**
		 * SMPTE 30 fps frame rate.
		 */
		public static const SMPTE_30:SmpteFrameRate = new SmpteFrameRate(5);
		/**
		 * UnKnown Value.
		 */
		public static const UNKNOWN:SmpteFrameRate = new SmpteFrameRate(-1);
		
		public function get value():int
		{
			return _value;
		}
		function SmpteFrameRate(p_value:int){
			_value = p_value;
		}
		private var _value:int = -1;
	}
}