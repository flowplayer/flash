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
package org.osmf.metadata
{
	import flexunit.framework.Assert;
	
	public class TestMetadataWatcher
	{
		[Test]
		public function testWatchFacet():void
		{
			var callbackArgument:* = null;
			var callbackCount:int = 0;
			function changeCallback(value:*):void
			{
				callbackArgument = value;
				callbackCount++;
			}
			
			var ns1:String = new String("http://www.ns1.com");
			var ns2:String = new String("http://www.ns2.com");
			var parentMetadata:Metadata = new Metadata();
			var watcher:MetadataWatcher = new MetadataWatcher(parentMetadata, ns1, null, changeCallback);
			watcher.watch();
			
			Assert.assertEquals(1,callbackCount);
			Assert.assertNull(callbackArgument);
			
			var m1:Metadata = new Metadata();
			parentMetadata.addValue(ns1, m1);
			
			Assert.assertEquals(2, callbackCount);
			Assert.assertEquals(callbackArgument, m1);
			
			parentMetadata.removeValue(ns1);
			
			Assert.assertEquals(3, callbackCount);
			Assert.assertNull(callbackArgument);
			
			var m2:Metadata = new Metadata();
			parentMetadata.addValue(ns2, m2);
			
			Assert.assertEquals(3, callbackCount);
			Assert.assertNull(callbackArgument);
			
			// No event, we're not watching values.
			m1.addValue("foo", "bar");
			Assert.assertEquals(3, callbackCount);
		}
		
		[Test]
		public function testWatchValue():void
		{
			var callbackArgument:* = null;
			var callbackCount:int = 0;
			function valueChangeCallback(value:*):void
			{
				callbackArgument = value;
				callbackCount++;
			}
			
			var ns1:String = new String("http://www.ns1.com");
			var ns2:String = new String("http://www.ns2.com");
			var parentMetadata:Metadata = new Metadata();
			var watcher:MetadataWatcher
				= new MetadataWatcher
					( parentMetadata
					, ns1
					, "myKey"
					, valueChangeCallback
					);
			watcher.watch();
			
			Assert.assertEquals(1,callbackCount);
			Assert.assertNull(callbackArgument);
			
			var m1:Metadata = new Metadata();
			parentMetadata.addValue(ns1, m1);
			
			Assert.assertEquals(2, callbackCount);
			Assert.assertNull(callbackArgument);
			
			var m2:Metadata = new Metadata();
			m2.addValue("myKey", "myValue");
			parentMetadata.addValue(ns2, m2);
			
			Assert.assertEquals(2, callbackCount);
			
			// Event, we're watching values.
			m1.addValue("myKey", "bar");
			Assert.assertEquals(3, callbackCount);
			Assert.assertEquals(callbackArgument, "bar");

			m1.addValue("myKey", "23");
			Assert.assertEquals(4, callbackCount);
			Assert.assertEquals(callbackArgument, "23");

			m1.removeValue("myKey");
			
			Assert.assertEquals(5, callbackCount);
			Assert.assertNull(callbackArgument);

			m1.addValue("foo", "bar");
			Assert.assertEquals(5, callbackCount);
			Assert.assertNull(callbackArgument);
		}
	}
}