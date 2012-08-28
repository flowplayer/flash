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
	import flexunit.framework.Assert;
	
	public class TestMediaError
	{
		[Test]
		public function testGetters1():void
		{
			var mediaError:MediaError = createMediaError(999);
			Assert.assertTrue(mediaError.errorID == 999);
			Assert.assertTrue(mediaError.message == "");
			Assert.assertTrue(mediaError.detail == null);
		}
		
		[Test]
		public function testGetters2():void
		{
			var mediaError:MediaError = createMediaError(MediaErrorCodes.URL_SCHEME_INVALID, "Here are some details...");
			Assert.assertTrue(mediaError.errorID == MediaErrorCodes.URL_SCHEME_INVALID);
			Assert.assertTrue(mediaError.message == "Invalid URL scheme");
			Assert.assertTrue(mediaError.detail == "Here are some details...");
		}
		
		[Test]
		public function testGetters3():void
		{
			var mediaError:MediaError = createMediaError(33, "");
			Assert.assertTrue(mediaError.errorID == 33);
			Assert.assertTrue(mediaError.message == "");
			Assert.assertTrue(mediaError.detail == "");
		}
		
		protected function createMediaError(errorID:int, detail:String=null):MediaError
		{
			return new MediaError(errorID, detail);
		}
	}
}