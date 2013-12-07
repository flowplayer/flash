/*****************************************************
 *  
 *  Copyright 2012 Adobe Systems Incorporated.  All Rights Reserved.
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
package org.osmf.events
{
	import flash.events.Event;
	
	import org.osmf.net.qos.QoSInfo;
	
	/**
	 * A NetStream dispatches a QoSInfoEvent when it has generated a new QoSInfo object. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class QoSInfoEvent extends Event
	{
		/**
		 * <p>The SwitchEvent.QOS_UPDATE constant defines the value of the
		 * type property of the event object for a qosUpdate event.</p>
		 * 
		 * <p>This type of event is dispatched by an object that has
		 * just generated a QoSInfo</p>
		 * 
		 * @eventType QOS_UPDATE
		 * 
		 * @see org.osmf.net.qos.QoSInfo
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */	
		public static const QOS_UPDATE:String = "qosUpdate";
		
		/**
		 * Constructor.
		 * 
		 * @param type The type of the event.
		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
		 * @param cancelable Specifies whether the behavior associated with the event can be prevented.
		 * @param qosInfo The QoS information
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function QoSInfoEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, qosInfo:QoSInfo = null)
		{
			super(type, bubbles, cancelable);
			_qosInfo = qosInfo;
		}
		
		/**
		 * The QoS information
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get qosInfo():QoSInfo
		{
			return _qosInfo;
		}
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new QoSInfoEvent(type, bubbles, cancelable, _qosInfo);
		}
		
		private var _qosInfo:QoSInfo = null;
	}
}