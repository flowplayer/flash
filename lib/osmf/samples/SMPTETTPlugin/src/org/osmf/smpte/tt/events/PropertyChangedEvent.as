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
	
	public class PropertyChangedEvent extends Event
	{
		
		public static const PROPERTY_CHANGED:String = "propertychanged";
		
		private var _propertyName:String;
		private var _newValue:*;
		private var _oldValue:*;
		
		/**
		 * Gets or sets the property name that changed
		 * 
		 * @param value
		 * @return
		 */		
		public function get propertyName():String
		{
			return _propertyName;
		}
		public function set propertyName(value:String):void
		{
			_propertyName = value;
		}
		
		/**
		 * Gets or sets the new value of the property that changed
		 * 
		 * @param value
		 * @return
		 */	
		public function get newValue():Object
		{
			return _newValue;
		}
		
		public function set newValue(value:Object):void
		{
			_newValue = value;
		}
		
		/**
		 * Gets or sets the previous value of the property that changed
		 * 
		 * @param value
		 * @return
		 */
		public function get oldValue():Object
		{
			return _oldValue;
		}
		
		public function set oldValue(value:Object):void
		{
			_oldValue = value;
		}
		
		public function PropertyChangedEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, propertyName:String=null, newValue:*=null, oldValue:*=null)
		{
			if(propertyName) _propertyName = propertyName;
			if(newValue) _newValue = newValue;
			if(oldValue) _oldValue = oldValue;
			
			super(type, bubbles, cancelable);
		}
	}
}