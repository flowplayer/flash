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
package org.osmf.vast.parser.base.events{
	import flash.events.Event;
	/**
	 * Events dispatched by the parser.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public dynamic class ParserEvent extends Event
	{
		public static const XML_PARSED:String = "XML Parsed";
		public static const XML_LOADED:String = "XML Loaded";
		public static const XML_LOAD_START:String = "XML Load Start";
		public static const XML_COMPANION_DETECTED:String = "XML Companion Detected";
		
		public var uifVars:Object = new Object();
		/**
		 * @private
		 * 
		 * Constructor
		 * 
		 */	
		public function ParserEvent( type:String, uifVars:Object = null)
		{
			super( type );
			this.uifVars = uifVars;
		}
		/**
		 * @private
		 * 
		 */	
		public override function toString():String
		{
			var eventString:String = super.toString();
			eventString = eventString.slice(0, eventString.length - 1);
			return eventString + " UIFVars=" + String(uifVars) + "]";
		}
	}
}
