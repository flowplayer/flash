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
	import org.flexunit.Assert;
	
	public class OSMFUtilTestURL
	{		
		[Before]
		public function setUp():void
		{
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test(description="A URL with username:password, a port number, a query string, and a fragment")]
		public function testURLCompleteURL():void
		{
			var url:URL = new URL("http://fred:wilma@hostexample.com:80/foo/bar.php?var1=foo&var2=bar#yyz");
			Assert.assertEquals(url.toString(), "http://fred:wilma@hostexample.com:80/foo/bar.php?var1=foo&var2=bar#yyz");
			Assert.assertEquals(url.protocol, "http");
			Assert.assertEquals(url.userInfo, "fred:wilma");
			Assert.assertEquals(url.host, "hostexample.com");
			Assert.assertEquals(url.port, "80");
			Assert.assertEquals(url.path, "foo/bar.php");
			Assert.assertEquals(url.getParamValue("var1"), "foo");
			Assert.assertEquals(url.getParamValue("var2"), "bar");
			Assert.assertEquals(url.fragment, "yyz");
			Assert.assertEquals(url.extension, "php");
			Assert.assertTrue(url.absolute);
		}
		
		[Test(description="A URI with an IP address")]
		public function testURLAddressIP():void 
		{
			var url:URL = new URL("telnet://192.0.2.16:80/");
			Assert.assertEquals(url.toString(), "telnet://192.0.2.16:80/");
			Assert.assertEquals(url.protocol, "telnet");
			Assert.assertEquals(url.host, "192.0.2.16");
			Assert.assertEquals(url.port, "80");
			Assert.assertEquals(url.path, "");
			Assert.assertEquals(url.extension, "");
			Assert.assertTrue(url.absolute);
		}
		
		[Test(description="A local file location")]
		public function testURLLocalFile():void 
		{
			var url:URL = new URL("/Users/mynamehere/Documents/media/myfile.flv");
			Assert.assertEquals(url.protocol, "");
			Assert.assertEquals(url.userInfo, "");
			Assert.assertEquals(url.host, "");
			Assert.assertEquals(url.port, "");
			Assert.assertEquals(url.path, "Users/mynamehere/Documents/media/myfile.flv");
			Assert.assertEquals(url.extension, "flv");
			Assert.assertFalse(url.absolute);
		}
		
		[Test(description="A URL with no slashes")]
		public function testURLNoSlashes():void 
		{
			var url:URL = new URL("rtmfp:");
			Assert.assertEquals(url.protocol, "rtmfp");
			Assert.assertEquals(url.userInfo, "");
			Assert.assertEquals(url.host, "");
			Assert.assertEquals(url.port, "");
			Assert.assertEquals(url.path, "");
			Assert.assertEquals(url.extension, "");
			Assert.assertTrue(url.absolute);
		}
		
		[Test(description="A URL with one trailing slash")]
		public function testURLOneTrailingSlash():void
		{
			var url:URL = new URL("rtmfp:/");
			Assert.assertEquals(url.protocol, "rtmfp");
			Assert.assertEquals(url.userInfo, "");
			Assert.assertEquals(url.host, "");
			Assert.assertEquals(url.port, "");
			Assert.assertEquals(url.path, "");
			Assert.assertEquals(url.extension, "");
			Assert.assertTrue(url.absolute);
		}
		
		[Test(description="A URL with one slash")]
		public function testURLOneSlash():void
		{
			var url:URL = new URL("blah:/hostexample.com:80/foo/bar.php?var1=foo&var2=bar#yyz");
			Assert.assertEquals(url.toString(), "blah:/hostexample.com:80/foo/bar.php?var1=foo&var2=bar#yyz");
			Assert.assertEquals(url.protocol, "blah");
			Assert.assertEquals(url.userInfo, "");
			Assert.assertEquals(url.host, "hostexample.com");
			Assert.assertEquals(url.port, "80");
			Assert.assertEquals(url.path, "foo/bar.php");
			Assert.assertEquals(url.getParamValue("var1"), "foo");
			Assert.assertEquals(url.getParamValue("var2"), "bar");
			Assert.assertEquals(url.fragment, "yyz");
			Assert.assertEquals(url.extension, "php");
			Assert.assertTrue(url.absolute);
		}
		
		[Test(description="Multiple level relative path test like ../../../file")]
		public function testURLMultipleLevelRelativePath():void
		{
			var url:URL = new URL("../../../myfile.flv");
			Assert.assertEquals(url.protocol, "");
			Assert.assertEquals(url.host, "");
			Assert.assertEquals(url.path, "../../../myfile.flv");
			Assert.assertEquals(url.extension, "flv");
			Assert.assertFalse(url.absolute);
		}
		
		[Test(description="Uplevel relative path test like ../file")]
		public function testURLUplevelRelativePath():void
		{
			var url:URL = new URL("../myfile.flv");
			Assert.assertEquals(url.protocol, "");
			Assert.assertEquals(url.host, "");
			Assert.assertEquals(url.path, "../myfile.flv");
		}
		
		[Test(description="Same level relative path test like ./file")]
		public function testURLSameLevelRelativePath():void
		{
			var url:URL = new URL("./myfile.flv");
			Assert.assertEquals(url.protocol, "");
			Assert.assertEquals(url.host, "");
			Assert.assertEquals(url.path, "./myfile.flv");
		}
		
		[Test(description="Multiple folders relative path test like foo/foo/foo/file")]
		public function testURLMultipleFoldersRelativePath():void
		{			
			var url:URL = new URL("foo/bar/myfile.flv");
			Assert.assertEquals(url.protocol, "");
			Assert.assertEquals(url.host, "");
			Assert.assertEquals(url.path, "foo/bar/myfile.flv");
		}
		
		[Test(description="One folder relative path test like foo/file")]
		public function testURLOneFolderRelativePath():void
		{
			var url:URL = new URL("foo/myfile.flv");
			Assert.assertEquals(url.protocol, "");
			Assert.assertEquals(url.host, "");
			Assert.assertEquals(url.path, "foo/myfile.flv");
		}
		
		[Test(description="Simple file name")]
		public function testURLSimpleFileName():void
		{
			var url:URL= new URL("myfile.flv");
			Assert.assertEquals(url.protocol, "");
			Assert.assertEquals(url.host, "");
			Assert.assertEquals(url.path, "myfile.flv");
		}
		
		[Test(description="Simple HTTP URL")]
		public function testURLSimpleHHTP():void
		{
			var url:URL = new URL("http://foo.com/mymp4.mp4");
			Assert.assertEquals(url.protocol, "http");
			Assert.assertEquals(url.host, "foo.com");
			Assert.assertEquals(url.path, "mymp4.mp4");
			Assert.assertEquals(url.port, "");
			Assert.assertEquals(url.extension, "mp4");
			Assert.assertTrue(url.absolute);
		}
		
		[Test(description="Leading and trailing whitespace test")]
		public function testURLWhiteSpace():void
		{
			var url:URL = new URL("  http://foo.com/file.flv  ");
			Assert.assertEquals(url.protocol, "http");
			Assert.assertEquals(url.host, "foo.com");
			Assert.assertEquals(url.path, "file.flv");
			Assert.assertEquals(url.port, "");
			Assert.assertEquals(url.extension, "flv");
		}

	}
}