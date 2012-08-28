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
package org.osmf.events
{
	import flexunit.framework.TestCase;
	
	import org.osmf.utils.CustomMediaError;
	import flexunit.framework.Assert;
	
	public class TestMediaErrorAsSubclass extends TestMediaError
	{
		[Test]
		public function testGettersForSubclass():void
		{
			var mediaError:MediaError = createMediaError(1999);
			Assert.assertTrue(mediaError.errorID == 1999);
			Assert.assertTrue(mediaError.message == "custom error");
			Assert.assertTrue(mediaError.detail == null);
		}
		
		override protected function createMediaError(errorID:int, detail:String=null):MediaError
		{
			return new CustomMediaError(errorID, detail);
		}
	}
}