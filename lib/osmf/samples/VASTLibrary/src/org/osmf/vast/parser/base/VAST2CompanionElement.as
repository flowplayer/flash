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
package org.osmf.vast.parser.base
{
	/**
	 * Public companion element parser and data object
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	 
	public dynamic class VAST2CompanionElement extends VAST2Element
	{
		/* All these variables are references or arrays of references */
		private var _id:String;
		private var _width:Number;
		private var _height:Number;
		private var _expandedWidth:Number;
		private var _expandedHeight:Number;
		/* private var _resourceType:String; NO LONGER USED */
		private var _staticResource:String;
		private var _iframeResource:String;
		private var _htmlResource:String;
		private var _staticResourceCreativeType:String;
		/* NO LONGER USED
		private var _URL:String;
		private var _Code:String; */
		private var _CompanionClickThrough:String;
		private var _AltText:String;
		private var _apiFramework:String;
		private var _adParameters:String;
	
		/** VAST2CompanionElement - constructor
		 *
		 * @param forxData:Object The forx tree at the specific location where Wrapper is defined (points to Wrapper)
		*/ 
		public function VAST2CompanionElement(forxData:Object)	
		{
			super(forxData, "VAST2CompanionElement", null);
			//UIFDebugMessage.getInstance()._debugMessage(3, "Element" + elementName + " created", "Instream", elementName); 
			_id = new String();
			_width = new Number();
			_height = new Number();
			_expandedWidth = new Number();
			_expandedHeight = new Number();
			_staticResource = new String();
			_iframeResource = new String();
			_htmlResource = new String();
			_staticResourceCreativeType = new String();
			/* _URL = ""; NO LONGER USED */
			/* _Code = ""; NO LONGER USED */
			_CompanionClickThrough = new String();
			_apiFramework = new String();
			_adParameters = new String();
			
			if ( forxData == null)
			{
				//UIFDebugMessage.getInstance()._debugMessage(3, "Element" + elementName + " is just a temporary placeholder.", "Instream", elementName); 	
				return;		// Just a placeholder object to prevent null reference errors
			}
		}
		
		/** parseXMLData
		 *
		 * Parse out XML data and set variables accordingly.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		*/ 
		
		public function parseXMLData() : void
		{
			if (forxRef == null)
				return;
			if (forxRef.@id != undefined) _id = forxRef.@id;
			if (forxRef.@width != undefined) _width = forxRef.@width;
			if (forxRef.@height != undefined) _height = forxRef.@height;
			if (forxRef.@expandedWidth != undefined) _expandedWidth = forxRef.@expandedWidth;
			if (forxRef.@expandedHeight != undefined) _expandedHeight = forxRef.@expandedHeight;
			/*if (forxRef.URL != undefined) _URL = forxRef.URL; NO LONGER USED */
			/* if (forxRef.Code != undefined) _Code = forxRef.Code; NO LONGER USED */
			if (forxRef.CompanionClickThrough != undefined ) _CompanionClickThrough = forxRef.CompanionClickThrough.text();
			if (forxRef.AltText != undefined) _AltText = forxRef.AltText.text();
			if (forxRef.@apiFramework != undefined ) _apiFramework = forxRef.@apiFramework;
			if (forxRef.StaticResource != undefined ) _staticResource = forxRef.StaticResource.text();
			if (forxRef.StaticResource.@creativeType != undefined ) _staticResourceCreativeType = forxRef.StaticResource.@creativeType;
			if (forxRef.IFrameResource != undefined ) _iframeResource = forxRef.IFrameResource.text();
			if (forxRef.HTMLResource != undefined ) _htmlResource = forxRef.HTMLResource.text();
			if (forxRef.AdParameters != undefined ) _adParameters = forxRef.AdParameters.text();
		}
		
		/**
		 * Returns the ID of the current companion element 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get id():String {return _id;}
				/**
		 * Returns the width of the current companion element 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get width():Number {return _width;}
				/**
		 * Returns the height of the current companion element 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get height():Number {return _height;}
		/**
		 * Returns the expandedWidth of the current companion element 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get expandedWidth():Number {return _expandedWidth;}
		/**
		 * Returns the expandedHeight of the current companion element 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get expandedHeight():Number {return _expandedHeight;}

		public function get resourceType():String {return "";} // NO LONGER USED
		public function get creativeType():String {return staticResourceCreativeType;} // DEPRECATED. USE staticResourceCreativeType
		public function get URL():String {return staticResource;} // DEPRECATED. USE staticResource
		public function get Code():String {return "";} // NO LONGER USED
		/**
		 * Returns the companionClickThrough of the current companion element 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get companionClickThrough():String {return _CompanionClickThrough;}
		/**
		 * Returns the AltText of the current companion element 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get AltText():String {return _AltText;}
		/**
		 * Returns the apiFramework of the current companion element 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get apiFramework():String {return _apiFramework;}
		/**
		 * Returns the staticResource of the current companion element 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get staticResource():String {return _staticResource;}
		/**
		 * Returns the staticResourceCreativeType of the current companion element 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get staticResourceCreativeType():String { return _staticResourceCreativeType;}
		/**
		 * Returns the iframeResource of the current companion element 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get iframeResource():String {return _iframeResource };
		/**
		 * Returns the htmlResource of the current companion element 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get htmlResource():String { return _htmlResource};
		/**
		 * Returns the adParameters of the current companion element 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get adParameters():String { return _adParameters};		
	}
	
}
