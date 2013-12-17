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
	
	import org.osmf.utils.OSMFStrings;
	
	/**
	 * This class represents the root level object
	 * in the Captioning document object model.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.0
	 *  @productversion OSMF 1.0
	 */
	public class CaptioningDocument
	{
		/**
		 * The title, if it was found in the metadata in the header.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function get title():String 
		{
			return _title;
		}
		
		public function set title(value:String):void
		{
			_title = value;
		}
		
		/**
		 * The description, if it was found in the metadata in the header.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function get description():String 
		{
			return _desc;
		}
		
		public function set description(value:String):void
		{
			_desc = value;
		}
		
		/**
		 * The copyright, if it was found in the metadata in the header.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function get copyright():String 
		{
			return _copyright;
		}
		
		public function set copyright(value:String):void
		{
			_copyright = value;
		}
		
		/**
		 * Add a style to the internal collection of styles.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function addStyle(style:CaptionStyle):void
		{
			if (_styles == null)
			{
				_styles = new Vector.<CaptionStyle>();
			}
			
			_styles.push(style);
		}
		
		/**
		 * Returns the number of style objects in this class'
		 * internal collection.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function get numStyles():int
		{
			var num:int = 0;
			
			if (_styles != null)
			{
				num = _styles.length;
			}
			
			return num;
		}
		
		/**
		 * Returns the style object at the index specified.
		 * 
		 * @throws IllegalOperationError If index argument is out of range.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function getStyleAt(index:int):CaptionStyle
		{
			if (_styles == null || index >= _styles.length)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			return _styles[index];
		}
		
		/**
		 * Add a caption object.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function addCaption(caption:Caption):void
		{
			if (_captions == null)
			{
				_captions = new Vector.<Caption>();
			}
			_captions.push(caption);
		} 

		/**
		 * Returns the number of caption objects in this class'
		 * internal collection.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function get numCaptions():int
		{
			var num:int = 0;
			
			if (_captions != null)
			{
				num = _captions.length;
			}
			
			return num;
		}
		
		/**
		 * Returns the caption object at the index specified.
		 * 
		 * @throws IllegalOperationError If index argument is out of range.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function getCaptionAt(index:int):Caption
		{
			if (_captions == null || index >= _captions.length)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			return _captions[index];
		}
		
		private var _title:String;
		private var _desc:String;
		private var _copyright:String;
		private var _captions:Vector.<Caption>;
		private var _styles:Vector.<CaptionStyle>;
	}
}
