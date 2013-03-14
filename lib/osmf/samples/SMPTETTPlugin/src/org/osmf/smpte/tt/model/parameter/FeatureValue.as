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
package org.osmf.smpte.tt.model.parameter
{
	public class FeatureValue
	{
		public function FeatureValue(p_label:String="",p_required:Boolean=false)
		{
			if(p_label.length>0) _label = p_label;
			if(p_required) _required = p_required;
		}
		
		private var _label:String;
		public function get label():String
		{
			return _label;
		}
		public function set label(value:String):void
		{
			_label = value;
		}

		private var _required:Boolean=false;
		public function get required():Boolean
		{
			return _required;
		}
		public function set required(value:Boolean):void
		{
			_required = value;
		}

		public function equals(obj:Object):Boolean
		{
			if (obj is FeatureValue)
			{
				return this.equalTo(FeatureValue(obj));
			}
			return false;
		}
		
		public function equalTo(value2:FeatureValue):Boolean
		{
			
			var sameLabel:Boolean = (label == value2.label);
			if (sameLabel) return (required == value2.required);
			return false;
		}
		
		public function notEqualTo(value2:FeatureValue):Boolean
		{
			
			var sameLabel:Boolean = (label == value2.label);
			if (sameLabel) return !(required == value2.required);
			return true;
		}
	}
}