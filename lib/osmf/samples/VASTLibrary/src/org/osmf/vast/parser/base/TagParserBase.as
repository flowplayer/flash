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

import org.osmf.vast.parser.base.interfaces.ITagParserBase;
import org.osmf.vast.parser.base.errors.ParserErrors;
import org.osmf.vast.parser.base.events.ParserEvent;


import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.StatusEvent;
import flash.net.LocalConnection;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.xml.XMLDocument;


	public dynamic class TagParserBase extends EventDispatcher implements ITagParserBase {

	//PRIVATE VARS: Accessible only to this class
	public var _adTagDataURL:String;
	public var _adTagClickPrepend:String;
	public var _adTagVersion:String;
	public var _adTagInstreamType:String;
	public var _adTagWidth:Number;
	public var _adTagHeight:Number;
	public var _adTagAlignHorizontal:String;
	public var _adTagAlignVertical:String;
	public var _adURL:String;
	public var _adTagDuration:Number;
	public var _adTagImpr3rdParty:String;
	public var _adTagClick3rdParty:String;
	public var _adTagURLCreativeFormat:String;
	public var _debugMessages:Number;
	
	public var _parserErrors:ParserErrors;
	
	
	//PROTECTED VARS: Accessible for sub classes and this class
	protected var _urlLoader:URLLoader;
	protected var _urlRequest:URLRequest;
	protected var _adTagXML:XML;
	protected var _uifVars:Object = new Object();
	public var _tagType:String;
	
	/**
	 *	Base class for the parser class.
	 * 
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public function TagParserBase() 
	{
		////UIFDebugMessage.getInstance()._debugMessage(3, "In TagParserBase() ", "INSTREAM", "TagParserBase");
		_parserErrors = new ParserErrors();
	}
	
	/*
	 * 
	 */
	 
	/**
		parseBase: Starts the loading and parsing of the tag url
	 * 
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	protected function parseBase(url : String, successFunction: Function, errorFunction: Function) : void
	{
		
		//_adTagXML = new XMLDocument();
		_urlLoader = new URLLoader();
		_uifVars = new Object();
		
		_adURL = "";
		_adTagClickPrepend = "";
		_adTagDataURL = "";
		_adTagVersion = "";
		_adTagInstreamType = "";
		_adTagWidth = 0;
		_adTagHeight = 0;
		_adTagAlignHorizontal = "";
		_adTagAlignVertical = "";
		_adTagDuration = 0;
		_adTagImpr3rdParty = "";
		_adTagClick3rdParty = "";
		_adTagURLCreativeFormat = "";	
		
		_urlLoader.addEventListener(Event.COMPLETE, successFunction);
		_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, errorFunction);
		
		getXMLFromServer(url);
	}

	/**
		getXMLFromServer: Loads in the XML from the url string
	 * 
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	 
	public function getXMLFromServer(url:String) : void
	{
		
		
		_urlRequest = new URLRequest(url);
		_adTagXML = new XML();
		_adTagXML.ignoreWhite = true;
		_urlLoader.load(_urlRequest);
		dispatchEvent(new Event(ParserEvent.XML_LOAD_START));
	}
	
	/*
	 * createUIFVars: Assigned the parsed data to correct variable names to be
	 * used in UIF. Called after XML data is parsed into this classes variables.
	 * 
	 * Assign additional variables to _uifVars before calling createUIFVars()
	 */
	
	/*
	 * Error Handling Methods
	 */
	protected function dispatchError(id:Number) : void
	{
		dispatchEvent(_parserErrors.getErrorEvent(id));
	}
	    

	//getters and setters

    public function get uifVars() : Object
    {
    	return _uifVars;
    }
   
    public function get tagType() : String
    {
    	return _tagType;
    }
   
    public function set tagType(type:String) : void
    {
    	_tagType = type;
    }
	
}

/* End package */
}
