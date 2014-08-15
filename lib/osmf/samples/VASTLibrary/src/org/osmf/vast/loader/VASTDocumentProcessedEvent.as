/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*
*  Contributor(s): Eyewonder, LLC
*  
*****************************************************/
package org.osmf.vast.loader
{
	import flash.events.Event;
	
	import org.osmf.vast.model.VASTDataObject;
	
	internal class VASTDocumentProcessedEvent extends Event
	{
		public static const PROCESSED:String = "processed";
		public static const PROCESSING_FAILED:String = "processingFailed";
		
		public function VASTDocumentProcessedEvent(type:String, vastDocument:VASTDataObject=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_vastDocument = vastDocument;
		}
		
		public function get vastDocument():VASTDataObject
		{
			return _vastDocument;
		}

		override public function clone():Event
		{
			return new VASTDocumentProcessedEvent(type, vastDocument, bubbles, cancelable);
		}
		
		private var _vastDocument:VASTDataObject;
	}
}