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

package org.osmf.player.configuration
{
	public class PlayerConfiguration
	{
		public function PlayerConfiguration(parameters:Object):void
		{
			_url = parameters.url || "";
			
			_backgroundColor 
				= parameters.backgroundColor == undefined
					? NaN
					: parseInt(parameters.backgroundColor);
							
			_autoHideControlBar
				= parameters.autoHideControlBar == undefined
					? true
					: parameters.autoHideControlBar.toString().toLowerCase() == "false" 
						? false
						: true;
						
			_autoSwitchQuality
				= parameters.autoSwitchQuality == undefined
					? true
					: parameters.autoSwitchQuality.toString().toLowerCase() == "false" 
						? false
						: true;
						
			_autoPlay
				= parameters.autoPlay == undefined
					? true
					: parameters.autoPlay.toString().toLowerCase() == "false" 
						? false
						: true;
		}

		public function get url():String
		{
			return _url;
		}
		
		public function get backgroundColor():Number
		{
			return _backgroundColor;
		}
		
		public function get autoHideControlBar():Boolean
		{
			return _autoHideControlBar;
		}
		
		public function get autoSwitchQuality():Boolean
		{
			return _autoSwitchQuality;
		}
		
		public function get autoPlay():Boolean
		{
			return _autoPlay;
		}
		
		// Internals
		//
		
		private var _url:String;
		private var _backgroundColor:Number;
		private var _showStopButton:Boolean;
		private var _autoHideControlBar:Boolean;
		private var _autoSwitchQuality:Boolean;
		private var _autoPlay:Boolean;
	}
}