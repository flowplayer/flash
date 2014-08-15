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
package org.osmf.net.rules
{
	/**
	 * RuleType identifies the various rule types that the Open Source Media
	 * Framework can handle out of the box.  
	 * 
	 * @see org.osmf.net.abr.RuleBase
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */ 
	public final class RuleType
	{
		/**
		 * The type constant for the Bandwidth rule.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */	
		public static const BANDWIDTH:String = "org.osmf.net.rules.bandwidth";
		
		/**
		 * The type constant for the Dropped FPS rule.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */	
		public static const DROPPED_FPS:String = "org.osmf.net.rules.droppedFPS";
		
		/**
		 * The type constant for the Buffer Bandwidth rule.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */	
		public static const BUFFER_BANDWIDTH:String = "org.osmf.net.rules.bufferBandwidth";
		
		/**
		 * The type constant for the Empty Buffer rule.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */	
		public static const EMPTY_BUFFER:String = "org.osmf.net.rules.emptyBuffer";
		
		/**
		 * The type constant for the After Up-Switch Buffer Bandwidth rule.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */	
		public static const AFTER_UP_SWITCH_BUFFER_BANDWIDTH:String = "org.osmf.net.rules.afterUpSwitchBufferBandwidth";
	}
}