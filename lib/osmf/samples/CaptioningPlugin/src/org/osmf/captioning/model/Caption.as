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
*****************************************************/
package org.osmf.captioning.model
{
	import __AS3__.vec.Vector;
	
	import flash.errors.IllegalOperationError;
	
	import org.osmf.metadata.TimelineMarker;
	import org.osmf.utils.OSMFStrings;

	/**
	 * Represents a caption, including text and style formatting information, 
	 * as well as when to show the caption and when to hide it.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.0
	 *  @productversion OSMF 1.0
	 */
	public class Caption extends TimelineMarker
	{
		/**
		 * Constructor.
		 * 
		 * @param id The caption id if supplied (optional).
		 * @param start The time in seconds the media when the caption should appear.
		 * @param end The time in seconds the media when the caption should no longer appear.
		 * @param captionText The caption text to display.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function Caption(id:uint, start:Number, end:Number, captionText:String)
		{
			var duration:Number = end > 0 ? (end - start) : NaN;
			super(start, duration);
			
			_id = id;
			_captionText = captionText;
		}
		
		/**
		 * Adds a CaptionFormat to this class' internal collection.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function addCaptionFormat(value:CaptionFormat):void
		{
			if (_formats == null)
			{
				_formats = new Vector.<CaptionFormat>();
			}
			
			_formats.push(value);
		}
		
		/**
		 * Returns the number of CaptionFormat objects in this class'
		 * internal collection.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */		
		public function get numCaptionFormats():int
		{
			var num:int = 0;
			
			if (_formats != null)
			{
				num = _formats.length;
			}
			
			return num;
		}

		/**
		 * Returns the CaptionFormat object at the index specified.
		 * 
		 * @throws IllegalOperationError If index argument is out of range.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function getCaptionFormatAt(index:int):CaptionFormat
		{
			if (_formats == null || index >= _formats.length || index < 0)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			return _formats[index];
		}		
		
		/**
		 * Returns the caption text which will include embedded HTML
		 * tags. To get the caption text without embedded HTML tags,
		 * use the <code>clearText<code> property.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function get text():String
		{
			return _captionText;
		}
		
		/**
		 * Returns the caption text without embedded HTML tags.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function get clearText():String
		{
			var clrTxt:String = "";
			if (_captionText != null && _captionText.length > 0)
			{
				clrTxt = _captionText.replace(/<(.|\n)*?>/g, "");
			}
			return clrTxt;
		}
		
		private var _id:uint;
		private var _captionText:String;	// The text to display, can contain embedded html tags, such as <br/>
		private var _formats:Vector.<CaptionFormat>;
	}
}
