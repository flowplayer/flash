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
package org.osmf.vast.parser.base.errors {
	
	import org.osmf.vast.parser.base.events.ParserErrorEvent;
	
	CONFIG::LOGGING
	{
	import org.osmf.logging.Logger;
	import org.osmf.logging.Log;
	}
	
	/**
	 * Class organizes all the errors by id numbers and description. Used by the parser.
	 * 
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public dynamic class ParserErrors extends Errors {
		// Standard errorsg
		// Do NOT change the numbers after release. Publishers may rely on these numbers (but shouldn't)
		public const ERROR_UNKNOWN:Object = 		{id:1,	desc:"Unknown XML error"};
		public const ERROR_URLNOTFOUND:Object = 	{id:2,	desc:"URL not found"};
		public const ERROR_CAPPEDTAG:Object = 		{id:3,	desc:"Capped ad tag"};
		public const ERROR_INVALIDTAG:Object = 		{id:4,	desc:"Invalid ad tag"};
		public const ERROR_MALFORMEDXML:Object = 	{id:5,	desc:"Malformed XML data"};
		
		/**
		 * Constructor
		 * 
		 * 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function ParserErrors()
		{
			super();
			defineError(ERROR_BASE);
			defineError(ERROR_UNKNOWN);
			defineError(ERROR_URLNOTFOUND);
			defineError(ERROR_CAPPEDTAG);
			defineError(ERROR_INVALIDTAG);
			defineError(ERROR_MALFORMEDXML);
			
			//_parseErrorArray.forEach(traceError);
		}
		
		/**
		 * @private
		 * 
		 */	
		public function traceError(item:Object, index:int, array:Array) : void
		{
			var msg:String = new String();
			var id:Number = item.id;
			var desc:String = item.desc;

			if (id >=	ERROR_BASE.id)
			{
				if (id >= WARNING_BASE.id)
				{
					if (id >= TAG_ERROR_BASE.id)
					{
						if (id >= TAG_WARNING_BASE.id)
						{
							if (id >= PUB_ERROR_BASE.id)
							{
								if (id >= PUB_WARNING_BASE.id)
								{	
									msg = "Publisher-specific XML Warning: ";
								}
								else
								{
									// PUB_ERROR_BASE
									msg = "Publisher-specific XML Warning: ";
								}
							}
							else
							{
								// TAG_WARNING_BASE
								msg = "Tag format specific XML Warning: ";
							}
						}
						else
						{
							// TAG_ERROR_BASE
							msg = "Tag format specific XML Error: ";
						}
					}
					else
					{
						// WARNING_BASE
						msg = "XML Warning: ";
					}
				}
				else
				{
					// ERROR_BASE
					msg = "XML Error: ";
				}
			}
			CONFIG::LOGGING
			{
				logger.debug("[VAST] Error: " + msg +"#"+ id +" "+ desc);
			}
		}
		/**
		 * @private
		 * 
		 */	
		public function getErrorEvent(id:int) : ParserErrorEvent
		{
			return new ParserErrorEvent(ParserErrorEvent.XML_ERROR, id, _parseErrorArray[id].desc);
		}
		
		CONFIG::LOGGING
		private static const logger:Logger = Log.getLogger("org.osmf.vast.parser.base.errors.ParseErrors");
	}
}
