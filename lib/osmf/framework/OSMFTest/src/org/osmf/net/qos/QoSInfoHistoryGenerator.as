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
	import org.osmf.net.qos.QoSInfo;
	import org.osmf.net.qos.QoSInfoHistory;

	public class QoSInfoHistoryGenerator
	{
		public static function generateSampleQoSInfoHistory():QoSInfoHistory
		{
			var qosInfoHistory:QoSInfoHistory = generateEmptyQoSInfoHistory();
			
			var qosInfo:QoSInfo = new QoSInfo(SAMPLE_MACHINE_TIME);
			
			qosInfoHistory.addQoSInfo(qosInfo);
			
			return qosInfoHistory;
		}
		
		public static function generateEmptyQoSInfoHistory():QoSInfoHistory
		{
			var conn:NetConnection = new NetConnection();
			conn.connect(null);
			
			var ns:NetStream = new NetStream(conn);

			var qosInfoHistory:QoSInfoHistory = new QoSInfoHistory(ns);
			
			return qosInfoHistory;
		}
		
		private static const SAMPLE_MACHINE_TIME:Number = 100;
	}
}