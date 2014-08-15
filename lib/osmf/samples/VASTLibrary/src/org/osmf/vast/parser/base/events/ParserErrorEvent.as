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
package org.osmf.vast.parser.base.events {
	import flash.events.Event;
	/**
	 * Error Events dispatched by the parser.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public dynamic class ParserErrorEvent extends Event
	{
		public static const XML_ERROR:String = "XML Error";
		public static const XML_WARNIG:String = "XML Warning";
		
		public var id:Number;
		public var description:String;

	/**
	 * @private
	 *Constructor
	 * 

	 */			
		public function ParserErrorEvent( type:String, id:Number, description:String )
		{
			this.id = id;
			this.description = description;
			super( type );
		}
	/**
	 * @private
	 */			
		public override function toString():String
		{
			var errorString:String = super.toString();
			errorString = errorString.slice(0, errorString.length - 1);
			return errorString + " id="+id +" description="+ description+"]";
		}
	}
}
