/*****************************************************
*  
*  Copyright 2010 Eyewonder, LLC.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Eyewonder, LLC.
*  Portions created by Eyewonder, LLC. are Copyright (C) 2010 
*  Eyewonder, LLC. A Limelight Networks Business. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.vast.model
{
	/**
	 * Class representing a MediaFile element in a VAST document.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class VAST2MediaFile extends VASTMediaFile
	{
			

		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function VAST2MediaFile()
		{
			super();
			
			bitrate = 0;
		}
		
		/**
		 * Indicates whether the Ad should scale to the content video.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get scalable():Boolean 
		{
			return _scalable;
		}
		
		public function set scalable(value:Boolean):void 
		{
			_scalable = value;
		}
		
		/**
		 * Indicates whether the Ad should keep the same aspect ratio as the content video.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get maintainAspectRatio():Boolean 
		{
			return _maintainAspectRatio;
		}
		
		public function set maintainAspectRatio(value:Boolean):void 
		{
			_maintainAspectRatio = value;
		}
		
		/**
		 * The current framework (VPAID or VAST).
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get apiFramework():String 
		{
			return _apiFramework;
		}
		
		public function set apiFramework(value:String):void 
		{
			_apiFramework = value;
		}

		

		private var _scalable:Boolean;
		private var	_maintainAspectRatio:Boolean;
		private var _apiFramework:String;
	}
}
