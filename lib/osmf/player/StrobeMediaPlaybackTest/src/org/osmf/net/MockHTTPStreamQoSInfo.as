/*****************************************************
 *  
 *  Copyright 2011 Adobe Systems Incorporated.  All Rights Reserved.
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
 *  Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems 
 *  Incorporated. All Rights Reserved. 
 *  
 *****************************************************/
package org.osmf.net
{
	[ExcludeClass]
	
	import org.osmf.net.httpstreaming.HTTPStreamQoSInfo;
	
	/**
	 * @private
	 * 
	 * Mock implementation for HTTP Streaming QOS information.
	 */
	public class MockHTTPStreamQoSInfo extends HTTPStreamQoSInfo
	{
		/**
		 * Default constructor.
		 */
		public function MockHTTPStreamQoSInfo(desiredRatio:Number)
		{
			super(0,0,0);
			_desiredRatio = desiredRatio;
		}
		
		override public function get downloadRatio():Number
		{
			return _desiredRatio;
		}
		
		/// Internals
		private var _desiredRatio:Number = 0;
	}
}