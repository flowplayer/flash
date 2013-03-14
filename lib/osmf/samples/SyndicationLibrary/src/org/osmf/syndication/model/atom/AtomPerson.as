/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.syndication.model.atom
{
	/**
	 * Represents a person in an Atom feed such as
	 * author and contributor.
	 **/
	public class AtomPerson
	{
		/**
		 * Human-readable name for the person.
		 **/
		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}
		
		/**
		 * email address for the person.
		 **/
		public function get email():String
		{
			return _email;
		}
		
		public function set email(value:String):void
		{
			_email = value;
		}
		
		/**
		 * Home page for the person.
		 **/
		public function get url():String
		{
			return _url;
		}
		
		public function set url(value:String):void
		{
			_url = value;
		}
		
		private var _name:String;
		private var _email:String;
		private var _url:String;
	}
}
