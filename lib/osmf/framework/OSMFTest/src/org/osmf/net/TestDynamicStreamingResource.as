/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.net
{
	import __AS3__.vec.Vector;
	
	import flash.utils.Dictionary;
	
	import flexunit.framework.Assert;
	
	import org.osmf.utils.OSMFStrings;

	public class TestDynamicStreamingResource
	{
		[Test]
		public function testDynamicStreamingResource():void
		{
			var dsr:DynamicStreamingResource = new DynamicStreamingResource(HOSTNAME);
			
			// Test hostName property
			Assert.assertEquals(HOSTNAME, dsr.host);
			
			Assert.assertEquals(0, dsr.streamItems.length);
			
			// Try an index out of range for the initial index
			try
			{
				dsr.initialIndex = 1;
				Assert.fail("DynamicStreamingResource.initialIndex should have thrown a RangeError");
			}
			catch(e:RangeError)
			{
				Assert.assertEquals(e.message, OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			
			// Test adding items. 
			dsr.streamItems.push(new DynamicStreamingItem("stream_1", bitrates[3]));
			dsr.streamItems.push(new DynamicStreamingItem("stream_2", bitrates[5]));
			dsr.streamItems.push(new DynamicStreamingItem("stream_3", bitrates[0]));
			dsr.streamItems.push(new DynamicStreamingItem("stream_4", bitrates[2]));
			dsr.streamItems.push(new DynamicStreamingItem("stream_5", bitrates[4]));
			dsr.streamItems.push(new DynamicStreamingItem("stream_6", bitrates[1]));
			
			Assert.assertEquals(bitrates.length, dsr.streamItems.length);
			
			// Test accessors. Note that the resource doesn't auto-sort the items,
			// they remain in the original order because we have no way to hook
			// into the push() call.
			Assert.assertEquals(bitrates[3], dsr.streamItems[0].bitrate);
			Assert.assertEquals(bitrates[5], dsr.streamItems[1].bitrate);
			Assert.assertEquals(bitrates[0], dsr.streamItems[2].bitrate);
			Assert.assertEquals(bitrates[2], dsr.streamItems[3].bitrate);
			Assert.assertEquals(bitrates[4], dsr.streamItems[4].bitrate);
			Assert.assertEquals(bitrates[1], dsr.streamItems[5].bitrate);
			
			// However, if the stream items are pushed all at once, we sort them.
			var streamItems:Vector.<DynamicStreamingItem> = new Vector.<DynamicStreamingItem>();
			streamItems.push(new DynamicStreamingItem("stream_1", bitrates[3]));
			streamItems.push(new DynamicStreamingItem("stream_2", bitrates[5]));
			streamItems.push(new DynamicStreamingItem("stream_3", bitrates[0]));
			streamItems.push(new DynamicStreamingItem("stream_4", bitrates[2]));
			streamItems.push(new DynamicStreamingItem("stream_5", bitrates[4]));
			streamItems.push(new DynamicStreamingItem("stream_6", bitrates[1]));
			dsr.streamItems = streamItems;
			
			for (var i:int = 0; i < dsr.streamItems.length; i++)
			{
				var bitrate:int = dsr.streamItems[i].bitrate;
				Assert.assertEquals(bitrates[i], dsr.streamItems[i].bitrate);
			}
			
			// Test initialIndex property
			Assert.assertEquals(0, dsr.initialIndex);
			dsr.initialIndex = 3;
			Assert.assertEquals(3, dsr.initialIndex);
			
			// Try an index out of range
			try
			{
				dsr.initialIndex = dsr.streamItems.length + 1;
				Assert.fail("DynamicStreamingResource.initialIndex should have thrown a RangeError");
			}
			catch(e:RangeError)
			{
				Assert.assertEquals(e.message, OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
						
			// Test indexFromName
			Assert.assertEquals(5, dsr.indexFromName("stream_2"));
			var index:int = dsr.indexFromName("bogus name");
			Assert.assertEquals(-1, index);
		}
		
		[Test]
		public function testDynamicStreamingResourceFM925():void
		{
			var dsr:DynamicStreamingResource = new DynamicStreamingResource(HOSTNAME);
			
			// Test adding items. 
			dsr.streamItems.push(new DynamicStreamingItem("stream_1?arg1=15&arg2=20", bitrates[3]));
			dsr.streamItems.push(new DynamicStreamingItem("stream_2", bitrates[5]));
			dsr.streamItems.push(new DynamicStreamingItem("stream_3?arg1=15&arg2=20", bitrates[0]));
			dsr.streamItems.push(new DynamicStreamingItem("mp4:stream_4", bitrates[2]));
			dsr.streamItems.push(new DynamicStreamingItem("stream_5?arg1=15&arg2=20", bitrates[4]));
			dsr.streamItems.push(new DynamicStreamingItem("mp4:stream_6", bitrates[1]));
			
			Assert.assertTrue(dsr.indexFromName("stream_1") == 0);
			Assert.assertTrue(dsr.indexFromName("stream_2") == 1);
			Assert.assertTrue(dsr.indexFromName("stream_3") == 2);
			Assert.assertTrue(dsr.indexFromName("stream_4") == 3);
			Assert.assertTrue(dsr.indexFromName("stream_5") == 4);
			Assert.assertTrue(dsr.indexFromName("stream_6") == 5);
		}
		
		private var bitrates:Array = [400, 900, 900, 1200, 3000, 3500]; 
		private const HOSTNAME:String = "rtmp://hostname.com/ondemand";
	}
}
