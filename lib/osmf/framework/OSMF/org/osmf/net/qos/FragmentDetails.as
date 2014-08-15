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
	 * FragmentDetails represents a collection of data about a media fragment.<br />
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class FragmentDetails
	{
		/**
		 * Constructor.
		 * 
		 * @param size The size of the fragment (in bytes)
		 * @param playDuration The play duration of the fragment (in seconds)
		 * @param downloadDuration The time it took to download the fragment (in seconds)
		 * @param index The index of the quality level to which the fragment is a part
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function FragmentDetails
			( size:Number
			, playDuration:Number
			, downloadDuration:Number
			, index:uint
			, fragmentIdentifier:String = null
			)
		{
			_size = size;
			_playDuration = playDuration;
			_downloadDuration = downloadDuration;
			_index = index;
			_fragmentIdentifier = fragmentIdentifier;
		}
		
		/**
		 * The size of the fragment (in bytes)
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get size():Number
		{
			return _size;
		}
		
		/**
		 * The play duration of the fragment (in seconds)
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get playDuration():Number
		{
			return _playDuration;
		}
		
		/**
		 * The time it took to download the fragment (in seconds)
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get downloadDuration():Number
		{
			return _downloadDuration;
		}
		
		/**
		 * The index of the stream of which this fragment is a part
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
		 * The identifier of the fragment (SegX-FragY)
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get fragmentIdentifier():String
		{
			return _fragmentIdentifier;
		}
		
		private var _index:uint;
		private var _size:Number;
		private var _playDuration:Number;
		private var _downloadDuration:Number;
		private var _fragmentIdentifier:String;
	}
}