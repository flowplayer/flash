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
package org.osmf.syndication.model.extensions.mrss
{
	import org.osmf.syndication.model.extensions.mrss.MediaRSSTitle
	
	/**
	 * Represents a Media RSS Content element.
	 **/
	public class MediaRSSContent extends MediaRSSElementBase
	{
		/**
		 * Constructor. Sets any default values
		 * defined by the MRSS spec.
		 * 
		 * @see http://video.search.yahoo.com/mrss
		 **/
		public function MediaRSSContent():void
		{
			super();
			_expression = MediaRSSExpressionType.FULL;
		}
		
		/**
		 * The URL of the media element.
		 **/
		public function get url():String
		{
			return _url;
		}
		
		public function set url(value:String):void
		{
			_url = value;
		}
		
		/**
		 * Height of the content in pixels.
		 **/
		public function get height():int
		{
			return _height;
		}
		
		public function set height(value:int):void
		{
			_height = value;
		} 
		
		/**
		 * Width of the content in pixels.
		 **/
		public function get width():int
		{
			return _width;
		}
		
		public function set width(value:int):void
		{
			_width = value;
		}
		
		/**
		 * The number of bytes of the media object.
		 **/
		public function get fileSize():Number
		{
			return _fileSize;
		}
		
		public function set fileSize(value:Number):void
		{
			_fileSize = value;
		}
		
		/**
		 * The standard MIME type of the object.
		 **/
		public function get type():String
		{
			return _type;
		}
		
		public function set type(value:String):void
		{
			_type = value;
		}
		
		/**
		 * The type of object (image | audio | video | document | executable). 
		 * <p>
		 * While this attribute can at times seem redundant if type is supplied, 
		 * it is included because it simplifies decision making on the reader side, 
		 * as well as flushes out any ambiguities between MIME type and object type.
		 * </p>
		 * 
		 * @see MediaMediumType
		 **/
		public function get medium():String
		{
			return _medium;
		}
		
		public function set medium(value:String):void
		{
			_medium = value;
		}
		
		/**
		 * Determines if this is the default object that should be used for the media:group. 
		 * There should only be one default object per media:group.
		 **/
		public function get isDefault():String
		{
			return _isDefault;
		}
		
		public function set isDefault(value:String):void
		{
			_isDefault = value;
		}
		
		/**
		 * Determines if the object is a sample or the full 
		 * version of the object, or even if it is a continuous 
		 * stream (sample | full | nonstop). Default value is 'full'.
		 * 
		 * @see MediaExpressionType
		 **/
		public function get expression():String
		{
			return _expression;
		}
		
		public function set expression(value:String):void
		{
			_expression = value;
		}
		
		/**
		 * The kilobits per second rate of the media.
		 **/
		public function get bitrate():Number
		{
			return _bitrate;
		}
		
		public function set bitrate(value:Number):void
		{
			_bitrate = value;
		}
		
		/**
		 * The number of frames per second for the media object.
		 **/
		public function get framerate():int
		{
			return _framerate;	
		}
		
		public function set framerate(value:int):void
		{
			_framerate = value;
		}
		
		/**
		 * The number of samples per second taken to create 
		 * the media object. It is expressed in thousands 
		 * of samples per second (kHz).
		 **/
		public function get samplingRate():Number
		{
			return _samplingRate;
		}
		
		public function set samplingRate(value:Number):void
		{
			_samplingRate = value;
		}
		
		/**
		 * The number of audio channels in the media object.
		 **/
		public function get channels():int
		{
			return _channels;
		}
		
		public function set channels(value:int):void
		{
			_channels = value;
		}
		
		/**
		 * The number of seconds the media object plays.
		 **/
		public function get duration():Number
		{
			return _duration;
		}
		
		public function set duration(value:Number):void
		{
			_duration = value;
		}
		
		/**
		 * The primary language encapsulated in the media object. 
		 * Language codes possible are detailed in RFC 3066. 
		 * This attribute is used similar to the xml:lang attribute 
		 * detailed in the XML 1.0 Specification (Third Edition)
		 **/
		public function get language():String
		{
			return _language;
		}
		
		public function set language(value:String):void
		{
			_language = value;
		}
		
		private var _url:String;
		private var _height:int;
		private var _width:int;
		private var _fileSize:Number;
		private var _type:String;
		private var _medium:String;
		private var _isDefault:String;
		private var _expression:String;
		private var _bitrate:Number;
		private var _framerate:int;
		private var _samplingRate:Number;
		private var _channels:int;
		private var _duration:Number;
		private var _language:String;
	}
}
