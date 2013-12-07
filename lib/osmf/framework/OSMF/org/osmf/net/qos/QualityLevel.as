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
	/**
	 * QualityLevel describes a quality level of an ABR stream
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class QualityLevel
	{
		/**
		 * Constructor.
		 * 
		 * @param index The index of the quality level
		 * @param bitrate The declared bitrate of the quality level (in kbps)
		 * @param streamName The name of the stream corresponding to this quality level
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function QualityLevel(index:uint, bitrate:Number, streamName:String = null)
		{
			_index = index;
			_bitrate = bitrate;
			_streamName = streamName;
		}
		
		/**
		 * The index of the quality level
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get index():uint
		{
			return _index;
		}
		
		/**
		 * The declared bitrate of the quality level
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get bitrate():Number
		{
			return _bitrate;
		}
		
		/**
		 * The name of the stream corresponding to this quality level
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get streamName():String
		{
			return _streamName;
		}
		
		private var _index:uint;
		private var _bitrate:Number;
		private var _streamName:String;
	}
}