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
*****************************************************/
package org.osmf.utils
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	public class MockURLLoader extends URLLoader
	{
		public function MockURLLoader()
		{
			super();
			
			expectations = new Dictionary();
		}
		
		public function setExpectationForURL(url:String, expectSuccess:Boolean, expectedData:*):void
		{
			expectations[url] = {"success":expectSuccess, "data":expectedData};
		}
				
		override public function load(request:URLRequest):void
		{
			var expectation:Object = expectations[request.url];
			if (expectation != null)
			{
				data = expectation["data"];
				
				// Prevent the network request from happening.
				if (expectation["success"] == true)
				{
					dispatchEvent(new Event(Event.COMPLETE));
				}
				else
				{
					data = null;
					dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
				}
			}
			else
			{
				throw new Error("Expectation needs to be set on MockURLLoader!");
			}
		}
		
		private var expectations:Dictionary;
	}
}