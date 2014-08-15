/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
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
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/

package org.osmf.player.debug
{
	import org.osmf.logging.Logger;
	import org.osmf.logging.LoggerFactory;

	public class DebuggerLoggerFactory extends LoggerFactory
	{
		public function DebuggerLoggerFactory(debugger:Debugger)
		{
			super();
			
			this.debugger = debugger;
		}

		override public function getLogger(name:String):Logger
		{
			return new DebuggerLogger(name, debugger);
		}
		
		// Internals
		//
		
		private var debugger:Debugger;
		
	}
}