/*****************************************************
*  
*  Copyright 2012 Adobe Systems Incorporated.  All Rights Reserved.
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
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2012 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.utils
{
	import flexunit.framework.Assert;

	/**
	 * Centralized test class for URLs.
	 **/
	public class TestURL
	{
		[Test]
		public function testNormalizePathForURL_1():void
		{
			var testUrl:String = "http://10.131.237.104/vod/";
			var expectedUrl:String = "http://10.131.237.104/vod/";
			
			var normalizedUrl:String = URL.normalizePathForURL(testUrl, true);
			Assert.assertEquals(expectedUrl, normalizedUrl);
		}

		[Test]
		public function testNormalizePathForURL_2():void
		{
			var testUrl:String = "http://10.131.237.104/vod/mlm_params.f4m";
			var expectedUrl:String = "http://10.131.237.104/vod/";
			
			var normalizedUrl:String = URL.normalizePathForURL(testUrl, true);
			Assert.assertEquals(expectedUrl, normalizedUrl);
		}

		[Test]
		public function testNormalizePathForURL_3():void
		{
			var testUrl:String = "http://10.131.237.104/vod/mlm_params.f4m?debug=1&path=/check/fm-1485/";
			var expectedUrl:String = "http://10.131.237.104/vod/";
			
			var normalizedUrl:String = URL.normalizePathForURL(testUrl, true);
			Assert.assertEquals(expectedUrl, normalizedUrl);
		}
		
		[Test]
		public function testNormalizePathForURL_4():void
		{
			var testUrl:String = "http://10.131.237.104/vod/";
			var expectedUrl:String = "http://10.131.237.104/vod/";
			
			var normalizedUrl:String = URL.normalizePathForURL(testUrl, false);
			Assert.assertEquals(expectedUrl, normalizedUrl);
		}

		[Test]
		public function testNormalizePathForURL_5():void
		{
			var testUrl:String = "http://10.131.237.104/vod";
			var expectedUrl:String = "http://10.131.237.104/vod/";
			
			var normalizedUrl:String = URL.normalizePathForURL(testUrl, false);
			Assert.assertEquals(expectedUrl, normalizedUrl);
		}
	}
}