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
package org.osmf.logging
{
	import org.flexunit.Assert;
	
	public class TestLog
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
		public function testAccessLoggerFactory():void
		{
			CONFIG::LOGGING
			{
				var loggerFactory:TraceLoggerFactory = new TraceLoggerFactory();
				Log.loggerFactory = loggerFactory;
				
				Assert.assertTrue(loggerFactory == Log.loggerFactory);
			}
		}
		
		[Test]
		public function testGetLogger():void
		{
			CONFIG::LOGGING
			{
				var logger:Logger = Log.getLogger("testLogger");
				
				CONFIG::LOGGING
				{
					Assert.assertTrue(logger != null);
					logger = null;
				}
				
				Assert.assertTrue(logger == null);
				
				Log.loggerFactory = new TraceLoggerFactory();
				
				logger = Log.getLogger("testLogger");
				Assert.assertTrue(logger != null);
			}
		}
		
		[Test]
		public function testLevelEnablements():void
		{
			CONFIG::LOGGING
			{
				var logger:Logger = new TraceLoggerFactory().getLogger("testLogger");
				
				logger.debug("message");
				logger.error("message");
				logger.info("message");
				logger.warn("message");
				logger.fatal("message");
				
				logger.debug("{0} message", "debug");
				logger.error("{0} message", "error");
				logger.info("{0} message", "info");
				logger.warn("{0} message", "warn");
				logger.fatal("{0} message", "fatal");
			}
		}
	}
}