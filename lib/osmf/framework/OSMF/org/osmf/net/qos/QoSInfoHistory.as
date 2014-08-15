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
	import flash.net.NetStream;
	
	import org.osmf.events.QoSInfoEvent;

	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
		import org.osmf.logging.Log;
	}
	
	/**
	 * QoSInfoHistory holds a number of QoSInfo records  
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class QoSInfoHistory
	{
		
		public static const DEFAULT_HISTORY_LENGTH:Number = 10;
		
		/**
		 * Constructor.
		 * 
		 * @param netStream The NetStream instance that will be providing the QoS information
		 * @param maxHistoryLength The maximum number of records to keep
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function QoSInfoHistory(netStream:NetStream, maxHistoryLength:uint = DEFAULT_HISTORY_LENGTH)
		{
			history = new Vector.<QoSInfo>();
			this.maxHistoryLength = maxHistoryLength;
			
			netStream.addEventListener(QoSInfoEvent.QOS_UPDATE, onQoSUpdate);
		}
		
		/**
		 * Returns the length of the history
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get length():uint
		{
			return history.length;
		}
		
		/**
		 * Returns an array with the most recent QoSInfo records
		 * 
		 * @param count the maximum length of the history
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function getHistory(count:uint = 0):Vector.<QoSInfo>
		{
			if (count == 0)
			{
				return history.slice();
			}
			
			// return the first count elements (most recent)
			return history.slice(0, count);
		}
		
		/**
		 * Returns the most recent QoSInfo in the history
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function getLatestQoSInfo():QoSInfo
		{
			if (history.length > 0)
			{
				return history[0];
			}
			
			return null;
		}
		
		/**
		 * The maximum number of records to keep.<br />
		 * Setting it to a value smaller than the current 
		 * number of records results in the overflowing records
		 * being removed (the oldest).
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get maxHistoryLength():uint
		{
			return _maxHistoryLength;
		}
		
		public function set maxHistoryLength(length:uint):void
		{
			if (length == 0)
			{
				throw new ArgumentError("maxHistoryLength needs to be greater than 0.");
			}
			
			_maxHistoryLength = length;
			trimHistory();
		}
		
		/**
		 * Erases the history
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function flush():void
		{
			history = new Vector.<QoSInfo>();
		}
		
		/**
		 * @private
		 * 
		 * Adds a QoSInfo object to the history
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		internal function addQoSInfo(qosInfo:QoSInfo):void
		{
			CONFIG::LOGGING
			{
				logger.info("Adding new QoSInfo:");
				
				qosInfo.logInformation();
			}
			
			history.splice(0, 0, qosInfo);
			trimHistory();
		}
				
		/**
		 * Inserts a new QoSInfo object at the beginning.<br />
		 * It may remove the oldest entry (if the size of the
		 * history is exceeded by adding this item)
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		private function onQoSUpdate(event:QoSInfoEvent):void
		{
			addQoSInfo(event.qosInfo);
		}
		
		/**
		 * Removes old entries (at the end of the array) if the history's 
		 * length has exceeded the maximum allowed value
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		private function trimHistory():void
		{
			if (history.length > _maxHistoryLength)
			{
				history.length = _maxHistoryLength;
			}
		}
		
		private var history:Vector.<QoSInfo>;
		private var _maxHistoryLength:uint = 0;
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.qos.QoSInfoHistory");
		}
	}
}