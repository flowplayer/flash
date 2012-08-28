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
	import flash.net.NetStreamInfo;

	public class MockNetStreamInfoFactory
	{
		public var videoBufferByteLength:Number;
		public var dataBufferByteLength:Number;
		public var videoBufferLength:Number;
		public var dataBufferLength:Number;
		public var playbackBytesPerSecond:Number;		
		public var maxBytesPerSecond:Number;
		
		public function get info():NetStreamInfo
		{
			try
			{
				var className:Class = NetStreamInfo;
				// In FP 10.1 the NetStreamInfo constructor expects 20 arguments.
				// In FP 10.0 it expects 19. The code below is a workarround 
				// for the compile time issues.			
				CONFIG::FLASH_10_1
				{
					return new className(0,0,
						maxBytesPerSecond,0,0,0,0,0,0,
						playbackBytesPerSecond,0,0,
						videoBufferByteLength, 
						dataBufferByteLength,0,videoBufferLength, dataBufferLength, 
						0, 0, 0);
				}
				
				return new className(0,0,
					maxBytesPerSecond,0,0,0,0,0,0,
					playbackBytesPerSecond,0,0,
					videoBufferByteLength, 
					dataBufferByteLength,0,videoBufferLength, dataBufferLength, 
					0, 0);				
			}
			catch(ignore:Error)
			{
				
			}
			return null;
		}
	}
}