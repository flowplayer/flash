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
package org.osmf.net
{
	import flash.net.NetStream;
	
	
	public class NetStreamSwitcherMocker extends NetStreamSwitcher
	{
		public function NetStreamSwitcherMocker(netStream:NetStream, dsResource:DynamicStreamingResource)
		{
			super(netStream, dsResource);
		}
		
		override public function get currentIndex():uint
		{
			return _currentIndexMocker;
		}
		
		public function set currentIndex(value:uint):void
		{
			_currentIndexMocker = value;
		}
		
		override public function get actualIndex():int
		{
			return _actualIndexMocker;
		}
		
		public function set actualIndex(value:int):void
		{
			_actualIndexMocker = value;
		}
		
		override public function get switching():Boolean
		{
			return _switchingMocker;
		}
		
		public function set switching(value:Boolean):void
		{
			_switchingMocker = value;
		}
		
		override public function switchTo(index:int):void
		{
			lastSwitchIndex = index;
		}
		
		public var lastSwitchIndex:int = -1;
		
		private var _currentIndexMocker:uint = 0;
		private var _actualIndexMocker:int = 0;
		private var _switchingMocker:Boolean = false;
	}
}