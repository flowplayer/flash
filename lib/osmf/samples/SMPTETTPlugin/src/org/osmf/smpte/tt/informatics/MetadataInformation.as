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
package org.osmf.smpte.tt.informatics
{
	public class MetadataInformation
	{
		public function MetadataInformation()
		{
		}
		
		private var _role:String;
		public function get role():String
		{
			return _role;
		}
		public function set role(value:String):void
		{
			_role = value;
		}
		
		
		private var _agent:String;
		public function get agent():String
		{
			return _agent;
		}
		public function set agent(value:String):void
		{
			_agent = value;
		}
		
		
		private var _nameType:String;
		public function get nameType():String
		{
			return _nameType;
		}
		public function set nameType(value:String):void
		{
			_nameType = value;
		}
		
		
		private var _name:String;
		public function get name():String
		{
			return _name;
		}
		public function set name(value:String):void
		{
			_name = value;
		}
		
		private var _actors:Vector.<String> = new Vector.<String>();
		public function get actors():Vector.<String>
		{
			return _actors;
		}
	}
}