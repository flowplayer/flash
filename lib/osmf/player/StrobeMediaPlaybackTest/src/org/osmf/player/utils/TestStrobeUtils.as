/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 *  The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 *  (the "License"); you may not use this file except in
 *  compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 * 
 **********************************************************/

package org.osmf.player.utils
{
	import org.flexunit.asserts.assertEquals;

	public class TestStrobeUtils
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
		
		[Test]
		public function testRetrieveHostNameFromUrlHostOnly():void
		{
			var result:String = StrobeUtils.retrieveHostNameFromUrl("http://example.com");
			assertEquals("example.com", result);
		}
		
		[Test]
		public function testRetrieveHostNameFromUrlLocalhost():void
		{
			var result:String = StrobeUtils.retrieveHostNameFromUrl("http://localhost/work/smp/trunk/samples/bin-debug/Preloader.swf");
			assertEquals("localhost", result);
		}
		
		[Test]
		public function testRetrieveHostNameFromUrlSwfInRoot():void
		{
			var result:String = StrobeUtils.retrieveHostNameFromUrl("http://example.com/myswf.swf");
			assertEquals("example.com", result);
		}
		
		[Test]
		public function testRetrieveHostNameFromUrl():void
		{
			var result:String = StrobeUtils.retrieveHostNameFromUrl("http://example.com/mypath/index.php?scr=http://example2.com/path2/myasset.flv");
			assertEquals("example.com", result);
		}
	}
}