/***********************************************************
 * 
 * Copyright 2011 Adobe Systems Incorporated. All Rights Reserved.
 *
 * *********************************************************
 * The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 * (the "License"); you may not use this file except in
 * compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems
 * Incorporated. All Rights Reserved.
 **********************************************************/
package org.osmf.smpte.tt.captions
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	
	import org.osmf.utils.OSMFStrings;
	
	public class CaptioningDocument
	{
		
		/**
		 * The title, if it was found in the metadata in the header.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.6
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
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.6
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
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.6
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
		 * Returns a vector of CaptionElements, one for each unique timeline event in the file.
		 * <p>Additional CaptionsElements that occur at the same TimelineMarker are stored in each CaptionElements siblings Vector.<CaptionElements>.</p>
		 *  
		 * @return 
		 * 
		 */
		public function get captionElements():Vector.<CaptionElement>
		{
			return _captionElements;
		}
		
		/**
		 * Returns a dictionary of CaptionElements indexed by a TimeCode string in the format &quot;00:00:00:00&quot;, one for each unique timeline event in the file.
		 * <p>Additional CaptionsElements that occur at the same TimelineMarker are stored in each CaptionElements siblings Vector.<CaptionElements>.</p>
		 *  
		 * @return 
		 * 
		 */
		public function get captionElementsHash():Dictionary
		{
			return _captionElementsHash;
		}
		
		/**
		 * Add a caption object.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.6
		 */
		public function addCaptionElement(caption:CaptionElement):void
		{
			if (_captionElements == null)
			{
				_captionElements = new Vector.<CaptionElement>();
				_captionElementsHash = new Dictionary();
			}
			var timeString:String = caption.begin+"s";
			if(!_captionElementsHash[timeString])
			{
				_captionElementsHash[timeString] = caption;
				_captionElements.push(caption);
			} 
			else if(_captionElementsHash[timeString].siblings.indexOf(caption as TimedTextElement)==-1)
			{
				_captionElementsHash[timeString].siblings.push(caption);
			}
		}
		
		/**
		 * Returns the caption object at the index specified.
		 * 
		 * @throws IllegalOperationError If index argument is out of range.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.6
		 */
		public function getCaptionElementAt(index:int):CaptionElement
		{
			if (_captionElements == null || index >= _captionElements.length)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			return _captionElements[index];
		}
		
		/**
		 * Returns the number of root TimelineMarker events in this class'
		 * internal collection.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.6
		 */
		public function get numTimelineMarkerEvents():int
		{
			var num:int = 0;
			
			if (_captionElements != null)
			{
				num = _captionElements.length;
			}
			
			return num;
		}
		
		/**
		 * Returns the total number of root CaptionElements from the internal collection,
		 * including captions that are triggered by the same TimelineMarker event. 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.6
		 */
		public function get totalCaptionElements():int
		{
			var num:int = 0;
			
			if (_captionElements != null)
			{
				for each(var c:CaptionElement in _captionElements){
					num += (c.siblings.length+1);
				}
			}
			
			return num;
		}
		
		/**
		 * Returns a flattened Vector.<CaptionElement> of root CaptionElements active at a given time.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.6
		 */
		public function getActiveCaptionsElements(time:Number):Vector.<CaptionElement>
		{
			var i:uint,
				j:uint,
				c:CaptionElement,
				s:CaptionElement,
				cc:Vector.<CaptionElement> = new Vector.<CaptionElement>();
			for(i=0; i<numTimelineMarkerEvents; i++)
			{
				c = _captionElements[i];
				if(c.begin<=time && (c.end)>time)
				{
					cc.push(c);
					for each(s in c.siblings)
					{
						if(s.begin<=time && (s.end)>time)
						{
							cc.push(s);
						}
					} 
				} 
			}
			return cc;
		}
		
		/**
		 * Returns a vector of CaptionRegions indexed by integer.
		 *  
		 * @return 
		 * 
		 */
		public function get captionRegions():Vector.<CaptionRegion>
		{
			return _captionRegions;
		}
		
		/**
		 * Returns a dictionary of CaptionRegions indexed by region id.
		 * 
		 * @return 
		 * 
		 */
		public function get captionRegionsHash():Dictionary
		{
			return _captionRegionsHash;
		}
		
		/**
		 * Add a region object.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.6
		 */
		public function addCaptionRegion(region:CaptionRegion):void
		{
			if (_captionRegions == null)
			{
				_captionRegions = new Vector.<CaptionRegion>();
				_captionRegionsHash = new Dictionary();
			}
			if(!_captionRegionsHash[region.id]){
				_captionRegionsHash[region.id] = region;
				_captionRegions.push(region);
			}
		}
		
		public function CaptioningDocument()
		{
		}
		
		private var _title:String;
		private var _desc:String;
		private var _copyright:String;
		private var _captionElements:Vector.<CaptionElement>;
		private var _captionElementsHash:Dictionary;
		private var _captionRegions:Vector.<CaptionRegion>;
		private var _captionRegionsHash:Dictionary;
	}
}