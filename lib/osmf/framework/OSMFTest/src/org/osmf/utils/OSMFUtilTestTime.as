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
	
	public class OSMFUtilTestTime
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
		
		[Test(description="Test hh:mm:ss format")]
		public function testParseTimeHMSTimeFormat():void
		{
			var seconds:Number = TimeUtil.parseTime("5:12:30");
			Assert.assertEquals(seconds, 18750);
			seconds = TimeUtil.parseTime("0:0:31");
			Assert.assertEquals(seconds, 31);
			seconds = TimeUtil.parseTime("0:2:01");
			Assert.assertEquals(seconds, 121);
		}
		
		[Test(description="Test offset times, e.g. 10s, 5m, 2h")]
		public function testParseTimeOffsetTimes():void
		{
			var seconds:Number = TimeUtil.parseTime("12s");
			Assert.assertEquals(seconds, 12);
			seconds = TimeUtil.parseTime("2m");
			Assert.assertEquals(seconds, 120);
			seconds = TimeUtil.parseTime("3h");
			Assert.assertEquals(seconds, 10800);
		}
			
		[Test(description="Give it some invalid formats")]
		public function testParseTimeInvalidFormats():void
		{
			var seconds:Number = TimeUtil.parseTime("12:30");
			Assert.assertTrue(isNaN(seconds));
			seconds = TimeUtil.parseTime("12;30");
			Assert.assertTrue(isNaN(seconds));
			seconds = TimeUtil.parseTime("23:");
			Assert.assertTrue(isNaN(seconds));
			seconds = TimeUtil.parseTime(":23");
			Assert.assertTrue(isNaN(seconds));
			seconds = TimeUtil.parseTime("37n");
			Assert.assertTrue(isNaN(seconds));
			seconds = TimeUtil.parseTime("abc");
			Assert.assertTrue(isNaN(seconds));
		}
		
		[Test]
		public function testFormatAsTimeCode():void
		{
			var time:String = TimeUtil.formatAsTimeCode(126);
			Assert.assertEquals(time, "02:06");
			time = TimeUtil.formatAsTimeCode(18750);
			Assert.assertEquals(time, "05:12:30");
			time = TimeUtil.formatAsTimeCode(31);
			Assert.assertEquals(time, "00:31");
			time = TimeUtil.formatAsTimeCode(1);
			Assert.assertEquals(time, "00:01");
		}
	}
}