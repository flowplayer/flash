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
	import org.osmf.syndication.model.Enclosure;
	
	/**
	 * Represents a link element in an Atom feed.
	 **/
	public class AtomLink extends Enclosure
	{
		/**
		 * A single link relationship type. It can be
		 * a full URL or one of the predefined
		 * values.
		 * 
		 * @see http://www.atomenabled.org/developers/syndication/#link
		 **/
		public function get rel():String
		{
			return _rel
		}
		
		public function set rel(value:String):void
		{
			_rel = value;
		}
		
		/**
		 * The language of the referenced resource.
		 **/
		public function get hreflang():String
		{
			return _hreflang;
		}
		
		public function set hreflang(value:String):void
		{
			_hreflang = value;
		}

		/**
		 * Human readable information about the link, typically
		 * for display purposes.
		 **/
		public function get title():String
		{
			return _title
		}
		
		public function set title(value:String):void
		{
			_title = value;
		}

		private var _rel:String;
		private var _hreflang:String;
		private var _title:String;
	}
}
