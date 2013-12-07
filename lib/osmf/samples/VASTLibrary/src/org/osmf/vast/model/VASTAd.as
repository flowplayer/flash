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
	import flash.errors.IllegalOperationError;
	
	/**
	 * This class represents the second-level element in a VAST document.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class VASTAd
	{		
		/**
		 * Constructor. 
		 * 
		 * @param id The id attribute (on the Ad element) from the 
		 * VAST document.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function VASTAd(id:String) 
		{
			_id = id;
		}

		/**
		 * The value of the id attribute on the Ad element from the 
		 * VAST document.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get id():String 
		{
			return _id;
		}

		/**
		 * The value of the InLine element from the VAST document represented
		 * by a VASTAdInline object.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get inlineAd():VASTInlineAd 
		{
			return _inlineAd;
		}
		
		public function set inlineAd(value:VASTInlineAd):void 
		{
			_inlineAd = value;
		}
		
		/**
		 * The value of the Wrapper element from the VAST document represented
		 * by a VASTAdWrapper object.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get wrapperAd():VASTWrapperAd 
		{
			return _wrapperAd;
		}
		
		public function set wrapperAd(value:VASTWrapperAd):void 
		{
			_wrapperAd = value;
		}
		
		private var _id:String;
		private var _inlineAd:VASTInlineAd;
		private var _wrapperAd:VASTWrapperAd;		
	}
}
