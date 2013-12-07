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
package org.osmf.net.qos
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamInfo;
	
	import mx.netmon.NetworkMonitor;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.flexunit.asserts.assertTrue;
	import org.osmf.events.QoSInfoEvent;
	import org.osmf.net.qos.FragmentDetails;
	import org.osmf.net.qos.PlaybackDetails;
	import org.osmf.net.qos.QoSInfo;
	import org.osmf.net.qos.QoSInfoHistory;
	import org.osmf.net.qos.QualityLevel;

	public class TestQoSInfoHistory
	{		
		[Before]
		public function setUp():void
		{
			netConnection = new NetConnection();
			netConnection.connect(null);
			netStream = new NetStream(netConnection);
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
		public function testInitQoSInfoHistoryDefault():void
		{
			qosInfoHistory = new QoSInfoHistory(netStream);
			assertEquals(10, qosInfoHistory.maxHistoryLength);
			assertEquals(0, qosInfoHistory.length);
			assertNull(qosInfoHistory.getLatestQoSInfo());
		
		}
		
		[Test(expects="ArgumentError")]
		public function testInitQosInfoHistoryZeroMaxLength():void
		{
			qosInfoHistory = new QoSInfoHistory(netStream, 0);
		}
		
		[Test]
		public function testQoSInfoHistoryWrap():void
		{
			qosInfoHistory = new QoSInfoHistory(netStream,3);
			
			
			var qos:QoSInfo;

			addQoSInfo(generateQoSInfo(1111));
			assertEquals(1, qosInfoHistory.length);
			addQoSInfo(generateQoSInfo(2222));
			assertEquals(2, qosInfoHistory.length);
			addQoSInfo(generateQoSInfo(3333));
			assertEquals(3, qosInfoHistory.length);
			addQoSInfo(generateQoSInfo(4444));
			assertEquals(3, qosInfoHistory.length);
			
			assertEquals(4444, qosInfoHistory.getHistory(3)[0].timestamp);
			assertEquals(3333, qosInfoHistory.getHistory(3)[1].timestamp);
			assertEquals(2222, qosInfoHistory.getHistory(3)[2].timestamp);
			
		}

		[Test]
		public function testQoSInfoHistoryFlush():void
		{
			qosInfoHistory = new QoSInfoHistory(netStream,3);
			
			//fill the QoSInfoHistory
			var qos:QoSInfo;
			
			addQoSInfo(generateQoSInfo(1111));
			assertEquals(1, qosInfoHistory.length);
			
			assertEquals(qosInfoHistory.getHistory()[0],qosInfoHistory.getLatestQoSInfo());
			
			addQoSInfo(generateQoSInfo(2222));
			assertEquals(2, qosInfoHistory.length);
			addQoSInfo(generateQoSInfo(3333));
			assertEquals(3, qosInfoHistory.length);
			addQoSInfo(generateQoSInfo(4444));
			assertEquals(3, qosInfoHistory.length);
			
			assertEquals(4444, qosInfoHistory.getHistory(3)[0].timestamp);
			assertEquals(3333, qosInfoHistory.getHistory(3)[1].timestamp);
			assertEquals(2222, qosInfoHistory.getHistory(3)[2].timestamp);
			
			//flush  the QoSInfoHistory
			qosInfoHistory.flush();
			
			assertEquals(0,qosInfoHistory.length);
			assertEquals(0,qosInfoHistory.getHistory(3).length);
			
		}
		
		[Test]
		public function testQoSInfoHistorySlice():void
		{
			qosInfoHistory = new QoSInfoHistory(netStream,3);
			
			var qos:QoSInfo;
			
			addQoSInfo(generateQoSInfo(1111));
			assertEquals(1, qosInfoHistory.length);
			addQoSInfo(generateQoSInfo(2222));
			assertEquals(2, qosInfoHistory.length);
			
			//get slices
			assertEquals(1, qosInfoHistory.getHistory(1).length);

			assertEquals(2, qosInfoHistory.getHistory().length);
			
			//next assert checks for slice limit
			assertEquals(2, qosInfoHistory.getHistory(16777215+1).length);
			
			//next assert checks for default responses
			assertEquals(2, qosInfoHistory.getHistory(0).length);
			
			//assert that the last pushed element is first always
			assertEquals(2222, qosInfoHistory.getHistory(0)[0].timestamp);
			assertEquals(2222, qosInfoHistory.getHistory()[0].timestamp);
			assertEquals(2222, qosInfoHistory.getHistory(1)[0].timestamp);
			
			//check for more elements than available in the history
			assertEquals(2, qosInfoHistory.getHistory(4).length);
			assertEquals(2222, qosInfoHistory.getHistory(4)[0].timestamp);
			assertEquals(1111, qosInfoHistory.getHistory(4)[1].timestamp);
		}
		
		
		[Test]
		public function testQoSInfoHistoryIncreaseLength():void
		{
			qosInfoHistory = new QoSInfoHistory(netStream,3);
			
			var qos:QoSInfo;
			
			addQoSInfo(generateQoSInfo(1111));
			assertEquals(1, qosInfoHistory.length);
			addQoSInfo(generateQoSInfo(2222));
			assertEquals(2, qosInfoHistory.length);
			addQoSInfo(generateQoSInfo(3333));
			assertEquals(3, qosInfoHistory.length);
			
			//action
			qosInfoHistory.maxHistoryLength = 4;

			assertEquals(4, qosInfoHistory.maxHistoryLength);
			assertEquals(3, qosInfoHistory.length);

			
			assertEquals(3, qosInfoHistory.getHistory().length);
			assertEquals(3333, qosInfoHistory.getHistory()[0].timestamp);
			assertEquals(2222, qosInfoHistory.getHistory()[1].timestamp);
			assertEquals(1111, qosInfoHistory.getHistory()[2].timestamp);
			
		}
		
		[Test]
		public function testQoSInfoHistoryDecreaseLength():void
		{
			qosInfoHistory = new QoSInfoHistory(netStream,3);
			
			var qos:QoSInfo;
			
			addQoSInfo(generateQoSInfo(1111));
			assertEquals(1, qosInfoHistory.length);
			addQoSInfo(generateQoSInfo(2222));
			assertEquals(2, qosInfoHistory.length);
			addQoSInfo(generateQoSInfo(3333));
			assertEquals(3, qosInfoHistory.length);
			
			//action
			qosInfoHistory.maxHistoryLength = 2;
			
			assertEquals(2, qosInfoHistory.maxHistoryLength);
			assertEquals(2, qosInfoHistory.length);
			
			
			assertEquals(2, qosInfoHistory.getHistory().length);
			assertEquals(3333, qosInfoHistory.getHistory()[0].timestamp);
			assertEquals(2222, qosInfoHistory.getHistory()[1].timestamp);			
		}
		
		
		
		[Test]
		public function testInitQoSInfoDefault():void
		{
			var qos:QoSInfo = new QoSInfo();
			assertTrue(isNaN(qos.timestamp));
			assertTrue(isNaN(qos.playheadTime));


			assertNull(qos.availableQualityLevels);
			
			assertEquals(-1, qos.currentIndex);
			assertEquals(-1, qos.actualIndex);
			
			assertNull(qos.lastDownloadedFragmentDetails);
			assertTrue(isNaN(qos.maxFPS));
			assertNull(qos.playbackDetailsRecord);
			assertNull(qos.nsInfo);

			assertTrue(isNaN(qos.bufferLength));
			assertTrue(isNaN(qos.bufferTime));
			
			assertFalse(qos.emptyBufferOccurred);
		}
		
		[Test]
		public function testInitQoSInfoWithInformation():void
		{
			var qos:QoSInfo = generateQoSInfo(1234);
			
			assertEquals(1234, qos.timestamp);
			assertEquals(5678, qos.playheadTime);
			assertEquals(0, qos.actualIndex);
			assertNotNull(qos.availableQualityLevels);
			assertEquals(2,qos.availableQualityLevels.length);
			assertEquals("test1",qos.availableQualityLevels[0].streamName);
			assertEquals(0,qos.availableQualityLevels[0].index);
			assertEquals(611,qos.availableQualityLevels[0].bitrate);
			assertEquals("test2",qos.availableQualityLevels[1].streamName);
			assertEquals(1,qos.availableQualityLevels[1].index);
			assertEquals(711,qos.availableQualityLevels[1].bitrate);
			assertNotNull(qos.lastDownloadedFragmentDetails);
			assertEquals(14000, qos.lastDownloadedFragmentDetails.size);
			assertEquals(568, qos.lastDownloadedFragmentDetails.downloadDuration);
			assertEquals(4000, qos.lastDownloadedFragmentDetails.playDuration);
			assertEquals(2, qos.lastDownloadedFragmentDetails.index);
			assertEquals(31.3, qos.maxFPS);
			assertNotNull(qos.nsInfo);
			assertTrue(qos.nsInfo is NetStreamInfo);
			assertEquals(29.7, qos.nsInfo.currentBytesPerSecond);
			assertNotNull(qos.playbackDetailsRecord);
			assertTrue(qos.playbackDetailsRecord is Vector.<PlaybackDetails>);
			assertEquals(2, qos.playbackDetailsRecord.length);
			assertEquals(2.2, qos.playbackDetailsRecord[1].duration);
			assertEquals(8.3, qos.bufferLength);
			assertEquals(9.5, qos.bufferTime);
			assertTrue(qos.emptyBufferOccurred);

		}
		
		private function addQoSInfo(qos:QoSInfo):void
		{			
			netStream.dispatchEvent(new QoSInfoEvent(QoSInfoEvent.QOS_UPDATE, false, false, qos));	
		}
		
		private function generateQoSInfo(timestamp:Number):QoSInfo
		{
			var q:Vector.<QualityLevel> = new Vector.<QualityLevel>();
			q[0]= new QualityLevel(0,611,"test1");
			q[1]= new QualityLevel(1,711,"test2");
			
			var nsi:NetStreamInfo = new NetStreamInfo(29.7,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28);
			var playbackDetails:Vector.<PlaybackDetails> = new Vector.<PlaybackDetails>();
			playbackDetails.push(new PlaybackDetails(0,2.03,22));
			playbackDetails.push(new PlaybackDetails(1,2.2,20));
			
			return (new QoSInfo(timestamp, 5678, q, 0, 0, new FragmentDetails(14000, 4000, 568, 2), 31.3, playbackDetails, nsi, 8.3, 9.5, true));
		}
		
		private var qosInfoHistory:QoSInfoHistory;
		private var netStream:NetStream;
		private var netConnection:NetConnection;
		
		
		
	}
}