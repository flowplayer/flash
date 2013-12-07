/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*  Contributor(s): Adobe Systems Inc.
* 
*****************************************************/
package org.osmf.vast.model
{
	/**
	 * This class represents a NonLinear tag in a VAST document.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class VASTNonLinearAd extends VASTAdBase
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function VASTNonLinearAd()
		{
			super();
		}
		
		/**
		 * Whether or not it is acceptable to scale the image.
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
		 * Whether or not the ad must have its aspect ratio maintained when
		 * scaled.
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
		 * Framework, if any, used for communication from ad to Video Player,
		 * such as "FlashVars".
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
		private var _maintainAspectRatio:Boolean;
		private var _apiFramework:String;
	}
}
