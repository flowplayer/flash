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
package org.osmf.flexunit
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import flexunit.framework.TestCase;

	/**
	 * Defines an extended version of flex unit's TestCase class, providing
	 * a number of additional assert methods.
	 */	
	public class TestCaseEx extends TestCase
	{
		/**
		 * @inheritDoc
		 */
		public function TestCaseEx(methodName:String=null)
		{
			super(methodName);
		}
		
		// Utils
		//
	
		/**
		 * Asserts that a function throws an exception on being invoked.
		 * 
		 * @param f The function that's expected to throw an exception.
		 * @param arguments The arguments to pass to the function on its invocation.
		 * @return The result of the function invocation. 
		 * 
		 */		
		protected function assertThrows(f:Function, ...arguments):*
		{
			var result:*;
			
			try
			{
				result = f.apply(null,arguments);
				fail();
			}
			catch(e:Error)
			{	
			}
			
			return result;
		}
		
		/**
		 * Asserts that one or more events get dispatched on a function being
		 * invoked.
		 *  
		 * @param dispatcher The expected dispatcher of the events.
		 * @param types The types of the events that the dispatcher is expected to dispatch.
		 * @param f The function that's expected to trigger the event dispatching.
		 * @param arguments The arguments to pass to the function on its invocation.
		 * @return The result of the function invocation.
		 * 
		 */		
		protected function assertDispatches(dispatcher:EventDispatcher, types:Array, f:Function, ...arguments):*
		{
			var result:*;
			var dispatched:Dictionary = new Dictionary();
			function handler(event:Event):void
			{
				dispatched[event.type] = true;
			}
			
			var type:String;
			for each (type in types)
			{
				dispatcher.addEventListener(type, handler);
			}
			
			result = f.apply(null, arguments);
			
			for each (type in types)
			{
				dispatcher.removeEventListener(type, handler);
			}
			
			for each (type in types)
			{
				if (dispatched[type] != true)
				{
					fail("Event of type " + type + " was not fired.");
				}
			}
			
			return result;
		}
		
	}
}