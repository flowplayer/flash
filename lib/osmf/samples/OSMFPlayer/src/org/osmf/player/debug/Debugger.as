/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
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
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/

package org.osmf.player.debug
{
	import flash.events.AsyncErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.net.LocalConnection;
	import flash.utils.Timer;
	
	public class Debugger
	{
		public static const FLUSH_INTERVAL:Number = 200;
		public static const MAX_QUEUE_LENGTH:Number = 30;
		
		public function Debugger(instanceId:String)
		{
			this.instanceId = instanceId;
				
			sender = new LocalConnection();
			sender.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
			sender.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			sender.addEventListener(StatusEvent.STATUS, onStatus);
			
			queue = [];
			
			timer = new Timer(FLUSH_INTERVAL);
			timer.addEventListener(TimerEvent.TIMER, onTimerTick);
			timer.start();
			
			send("TRACE", "debugger instance constructed");
		}
		
		public function send(type:String, ...parameters):void
		{
			parameters.unshift(type);
			parameters.unshift(new Date());
			parameters.unshift(instanceId);
			
			queue.push(parameters);	
			if (queue.length > MAX_QUEUE_LENGTH)
			{
				flush();
			}
		}

		// Internals
		//
		
		private var sender:LocalConnection;
		private var instanceId:String;
		
		private var queue:Array;
		private var timer:Timer;
		
		private static const SENDER_NAME:String = "_OSMFWebPlayerDebugger";
		
		private function onAsyncError(event:AsyncErrorEvent):void
		{
			//	
		}
		
		private function onSecurityError(event:SecurityErrorEvent):void
		{
			//	
		}
		
		private function onStatus(event:StatusEvent):void
		{
			//
		}
		
		private function flush():void
		{
			sender.send(SENDER_NAME, "debug", queue);
			
			queue = [];
		}
		
		private function onTimerTick(event:TimerEvent):void
		{
			if (queue.length > 0)
			{
				flush();
			}
		}
	}
}