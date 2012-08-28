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
 **********************************************************/

package org.osmf.net
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamInfo;
	import flash.utils.Timer;
	
	import org.osmf.netmocker.MockNetStream;

	public class MockProgressiveNetStream extends MockNetStream
	{
		public var simulatedDownloadBytesPerSecond:uint;
		public var simulatedPlaybackBytesPerSecond:uint;
		public var isProgressive:Boolean = true;
	
		public function MockProgressiveNetStream(connection:NetConnection)
		{
			super(connection);
			if (isProgressive)
			{
				_bytesLoaded = 1;
				_bytesTotal = 5;
			}
			var timer:Timer = new Timer(100, 100);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
		}
		public function get infoFactory():MockNetStreamInfoFactory
		{
			return _infoFactory;
		}
		
		
		override public function get bytesLoaded():uint
		{
			return _bytesLoaded;
		}
		
		override public function get bytesTotal():uint
		{
			return _bytesTotal;
		}
		
		override public function get info():NetStreamInfo
		{
			 return _infoFactory.info || super.info;
		}
		// Internals
		//
		private function onTimer(event:Event):void
		{
			if (isProgressive)
			{
				_infoFactory.videoBufferByteLength = simulatedPlaybackBytesPerSecond;
				_infoFactory.videoBufferLength = 1; 
				_bytesLoaded += simulatedDownloadBytesPerSecond / 10;
				_bytesTotal += simulatedDownloadBytesPerSecond / 10 * 2;
			}
			else
			{
				_bytesLoaded = 0;
				_bytesTotal = 0;
				_infoFactory.playbackBytesPerSecond = simulatedPlaybackBytesPerSecond;
				_infoFactory.maxBytesPerSecond = simulatedDownloadBytesPerSecond;
			}
		}
		private var _infoFactory:MockNetStreamInfoFactory = new MockNetStreamInfoFactory();
		private var _bytesLoaded:uint;
		private var _bytesTotal:uint;
	}
}