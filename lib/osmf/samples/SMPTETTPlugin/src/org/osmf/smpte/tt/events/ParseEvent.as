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
package org.osmf.smpte.tt.events
{
	import flash.events.Event;
	
	public class ParseEvent extends Event
	{
		public static const BEGIN:String = "begin";
		public static const PROGRESS:String = "progress";
		public static const COMPLETE:String = "complete";
		public static const PARTIAL:String = "partial"; 
		
		private var _data:Object;

		public function get data():Object
		{
			return _data;
		}

		public function set data(value:Object):void
		{
			_data = value;
		}


		public override function clone():Event
		{
			return new ParseEvent(type,bubbles,cancelable,data);
		}


		public override function toString():String
		{
			return formatToString("ParseEvent","type","data");
		}

		
		public function ParseEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:Object=null)
		{
			_data = data;
			super(type, bubbles, cancelable);
		}
		
		
	}
}