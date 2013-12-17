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
package org.osmf.examples.netconnection
{
	import flash.errors.IllegalOperationError;
	import flash.net.NetConnection;
	
	import org.osmf.events.NetConnectionFactoryEvent;
	import org.osmf.media.URLResource;
	import org.osmf.net.NetConnectionFactoryBase;

	/**
	 * NetConnectionFactory which always returns the NetConnection it
	 * is constructed with.
	 **/
	public class SimpleNetConnectionFactory extends NetConnectionFactoryBase
	{
		/**
		 * Constructor.
		 * 
		 * @param netConnection The NetConnection to always return.
		 **/
		public function SimpleNetConnectionFactory(netConnection:NetConnection)
		{
			super();
			
			this.netConnection = netConnection;

			if (netConnection == null)
			{
				throw new IllegalOperationError();
			}
		}
		
		/**
		 * @private
		 **/
		override public function create(resource:URLResource):void
		{
			dispatchEvent
				( new NetConnectionFactoryEvent
					( NetConnectionFactoryEvent.CREATION_COMPLETE
					, false
					, false
					, netConnection
					)
				);
		}
		
		private var netConnection:NetConnection;
	}
}