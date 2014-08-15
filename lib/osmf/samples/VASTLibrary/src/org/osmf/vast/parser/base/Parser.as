/*****************************************************
*  
*  Copyright 2010 Eyewonder, LLC.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Eyewonder, LLC.
*  Portions created by Eyewonder, LLC. are Copyright (C) 2010 
*  Eyewonder, LLC. A Limelight Networks Business. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.vast.parser.base {
	import org.osmf.vast.parser.base.TagParserBase;
	import org.osmf.vast.parser.base.interfaces.IParser


	public dynamic class Parser extends TagParserBase implements IParser {
		
		public var _mainXML:XML;

	/**
	 * Sub classes are VASTParser and EWParser
	 * 
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */

		public function Parser() {
			super();
			tagType = "Generic Parser";
		}
	/**
	 * Checks the format of the current ad package
	 * 
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
		
		public function checkFormat(data:XML):Boolean
		{
			return false;
		}

		/*
		 * Override this function only.
		 */
		protected function parseXMLData() : void {
			//Parse Data Here: _adTagXML:XMLDocument is the XML Data
			//createUIFvars();
		}


	/**
	 * parse: Passed in url and handlers to base class to parse 
	 * 
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
		 
		public function parse(url : XML) : void {
			
			////UIFDebugMessage.getInstance()._debugMessage(3, "In parse(" + url + ") ", "INSTREAM", "Parser");
			
			_mainXML = url
			parseXMLData();
		}
	/**
	 * Returns the mainXML passed to the parser
	 * 
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */		
		public function get mainXML():XML
		{
			return _mainXML;
		}
	}
}
/* End package */

