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
package org.osmf.smpte.tt.parsing
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import org.osmf.smpte.tt.captions.CaptionElement;
	import org.osmf.smpte.tt.captions.CaptionRegion;
	import org.osmf.smpte.tt.captions.CaptioningDocument;
	import org.osmf.smpte.tt.captions.TimedTextAnimation;
	import org.osmf.smpte.tt.captions.TimedTextElement;
	import org.osmf.smpte.tt.captions.TimedTextElementType;
	import org.osmf.smpte.tt.errors.SMPTETTException;
	import org.osmf.smpte.tt.events.ParseEvent;
	import org.osmf.smpte.tt.logging.SMPTETTLogging;
	import org.osmf.smpte.tt.model.AnonymousSpanElement;
	import org.osmf.smpte.tt.model.BrElement;
	import org.osmf.smpte.tt.model.LayoutElement;
	import org.osmf.smpte.tt.model.PElement;
	import org.osmf.smpte.tt.model.RegionElement;
	import org.osmf.smpte.tt.model.SetElement;
	import org.osmf.smpte.tt.model.SpanElement;
	import org.osmf.smpte.tt.model.TimedTextAttributeBase;
	import org.osmf.smpte.tt.model.TimedTextElementBase;
	import org.osmf.smpte.tt.model.TtElement;
	import org.osmf.smpte.tt.model.metadata.CopyrightElement;
	import org.osmf.smpte.tt.model.metadata.DescElement;
	import org.osmf.smpte.tt.model.metadata.TitleElement;
	import org.osmf.smpte.tt.timing.TimeCode;
	import org.osmf.smpte.tt.timing.TimeContainer;
	import org.osmf.smpte.tt.timing.TimeExpression;
	import org.osmf.smpte.tt.timing.TimeSpan;
	import org.osmf.smpte.tt.timing.TreeType;
	import org.osmf.smpte.tt.utilities.AsyncThread;
	import org.osmf.smpte.tt.vocabulary.Namespaces;

	[Event(name="begin", type="org.osmf.smpte.tt.events.ParseEvent")]
	[Event(name="progress", type="org.osmf.smpte.tt.events.ParseEvent")]
	[Event(name="complete", type="org.osmf.smpte.tt.events.ParseEvent")]
	
	public class SMPTETTParser extends EventDispatcher 
		implements IEventDispatcher, ISMPTETTParser
	{
		
		private static const DEBUG:Boolean = true;
		
		public static var ns:Namespace;
		public static var ttm:Namespace;
		public static var tts:Namespace;
		public static var ttp:Namespace;
		public static var smpte:Namespace;
		public static var m608:Namespace;
		public static var rootNamespace:Namespace;
		public static var ASYNC_THREAD:AsyncThread;
		public static var REMAINING_NODE_COUNT:uint;
		
		protected var _document:CaptioningDocument;

		public function get document():CaptioningDocument
		{
			return _document;
		}
		
		public function SMPTETTParser(){
		}
		
		private var _taskId:uint=0;
		
		private var _ttElement:TtElement;

		public function get ttElement():TtElement
		{
			return _ttElement;
		}
		
		private var _regionElementsHash:Dictionary;

		public function get regionElementsHash():Dictionary
		{
			return _regionElementsHash;
		}
		
		private var _captionRegionsHash:Dictionary;

		public function get captionRegionsHash():Dictionary
		{
			return _captionRegionsHash;
		}
		
		protected var _captionElements:Vector.<CaptionElement>;
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
		
		private var _startTime:TimeCode = null;
		public function get startTime():TimeCode
		{
			return _startTime;
		}

		public function set startTime(value:TimeCode):void
		{
			_startTime = value;
		}

		private var _endTime:TimeCode = null;
		public function get endTime():TimeCode
		{
			return _endTime;
		}

		public function set endTime(value:TimeCode):void
		{
			_endTime = value;
		}
		
		protected function set remainingNodeCount(v:int):void
		{
			SMPTETTParser.REMAINING_NODE_COUNT = v;
		}
		
		protected function get remainingNodeCount():int
		{
			return SMPTETTParser.REMAINING_NODE_COUNT
		}
		
		public function parse(i_rawData:String):CaptioningDocument
		{   
            if (ASYNC_THREAD)
            {
                // clean-up any running threads
                debug("ASYNC_THREAD.stop()");
                ASYNC_THREAD.stop();
                ASYNC_THREAD = null;
            }
            
            _document = new CaptioningDocument();
			
			// if global time parameters for this session haven't been established, we should set them
			if(!TimeExpression.CurrentTimeBase)
				TimeExpression.initializeParameters();
			
				
			var parseTree:TtElement = null;
			
			dispatchEvent(new ParseEvent(ParseEvent.BEGIN, true, false, parseTree) );
			addEventListener(ParseEvent.PROGRESS, handleParseTtElement);
			parseTree = parseTtElement(i_rawData);
			
			return _document;
		}
		
		
		private function handleParseTtElement(e:ParseEvent):void
		{
			if(e.data && e.data is TtElement){
				//trace(this+".handleParseTtElement("+e+")");
				removeEventListener(ParseEvent.PROGRESS, handleParseTtElement);
				addEventListener(ParseEvent.PROGRESS, handleValitateTtElement);
				
				_ttElement = e.data as TtElement;
				validateTtElement(_ttElement);
			}
		}
		
		private function handleValitateTtElement(e:ParseEvent):void
		{
			if(e.data && e.data is TtElement){
				//trace(this+".handleParseTtElement("+e+")");
				removeEventListener(ParseEvent.PROGRESS, handleValitateTtElement);
				addEventListener(ParseEvent.PROGRESS, handleComputeTimeIntervals);
				
				_ttElement = e.data as TtElement;
				computeTimeIntervals(_ttElement, _startTime, _endTime);
			}
		}
		
		private function handleComputeTimeIntervals(e:ParseEvent):void
		{
			if(e.data && e.data is TtElement){
				//trace(this+".handleComputeTimeIntervals("+e+")");
				removeEventListener(ParseEvent.PROGRESS, handleComputeTimeIntervals);
				addEventListener(ParseEvent.PROGRESS, handleBuildDocumentTimeInterval);

				_ttElement = e.data as TtElement;
				buildRegions(_ttElement);
			}
		}
		
		private function handleBuildDocumentTimeInterval(e:ParseEvent):void
		{
			if(e.data)
			{
				//trace(this+".handleBuildDocumentTimeInterval("+e+")");
				//removeEventListener(ParseEvent.PROGRESS, handleBuildDocumentTimeInterval);
				//addEventListener(ParseEvent.PROGRESS, handleBuildCaptionsTimeInterval);
				if(e.data is ParseEventData)
				{
					var ped:ParseEventData = ParseEventData(e.data);
					if(e.data.timedTextElement != null)
					{
						// buildCaptions( ped.timedTextElement, ped.regionElementsHash, ped.captionRegionsHash, ped.timelineEventsHash );
						
						if(!ASYNC_THREAD)
						{
							parseTime = getTimer();
                            _captionElements = new Vector.<CaptionElement>();	
							ASYNC_THREAD = AsyncThread.create( buildCaptions, 
															  [ ped.timedTextElement,
																ped.regionElementsHash,
																ped.captionRegionsHash,
																ped.timelineEventsHash ] );
							ASYNC_THREAD.addEventListener(Event.COMPLETE, asyncThread_completeHandler, false, 0, true);
							ASYNC_THREAD.runEachFrame(50);
						} else
						{
                            if (!_captionElements)
                                _captionElements = new Vector.<CaptionElement>();
							AsyncThread.queue( buildCaptions, 
											   [ ped.timedTextElement,
												 ped.regionElementsHash,
												 ped.captionRegionsHash,
												 ped.timelineEventsHash ] );
						}
						
					} else
					{
						removeEventListener(ParseEvent.PROGRESS, handleBuildDocumentTimeInterval);

						_regionElementsHash = ped.regionElementsHash;
						_captionRegionsHash =  ped.captionRegionsHash;
						
						var localParseTime:uint = parseTime;
						debug(this+" handleBuildDocumentTimeInterval: "+(getTimer()-parseTime)/1000+"s");
					}
				}
			}
		}
		
		private function asyncThread_completeHandler(event:Event):void
		{
			debug(event.target+" asyncThread_completeHandler: "+(getTimer()-parseTime)/1000+"s");
			ASYNC_THREAD.removeEventListener(Event.COMPLETE, asyncThread_completeHandler);
			ASYNC_THREAD = null;
			
			_captionRegionsHash = null;
			_regionElementsHash = null;
			_captionElements = null;
			startTime = null;
			endTime = null;
			
			dispatchEvent(new ParseEvent(ParseEvent.COMPLETE, true, false, _document));
		}
		
		private function repairNamespaces(xml:XML):Namespace
		{
			
			Namespaces.useLegacyNamespace(Namespaces.DEFAULT_TTML_NS);
			
			var newDefaultNS:Namespace = xml.namespace();
			if (newDefaultNS.uri.length==0)
			{
				var nsDeclarations:Array = xml.namespaceDeclarations();
				for each(var ns:Namespace in nsDeclarations)
				{
					if(ns.uri.match(Namespaces.TTML_NS_REGEXP))
					{ 
						newDefaultNS = new Namespace(ns.uri.split("#")[0]);
						break;
					}
				}
				if(newDefaultNS.uri.length==0)
				{
					newDefaultNS = Namespaces.TTML_NS;
				}
			}
			
			xml.setNamespace(newDefaultNS);
			
			return 	newDefaultNS;	
		}
		
		private function stripSMPTETTNodes(xml:XML):XML
		{
			if(xml.namespace("smpte"))
			{
				var xmlList:XMLList = xml..smpte::*;
				var len:uint = xmlList.length();
				for each(var node:XML in xmlList)
				{
					delete node.parent().*[node.childIndex()];
				}
			}
			return xml;
		}
		
		private function parseTtElement(rawData:String):TtElement
		{
			parseTime = getTimer();
			
			var parsetree:TtElement = null;
			
			// cache our original XML.ignoreWhitespace and XML.prettyPrinting settings
			var saveXMLIgnoreWhitespace:Boolean = XML.ignoreWhitespace;
			var saveXMLPrettyPrinting:Boolean = XML.prettyPrinting; 
			
			// Remove line ending whitespaces
			var xmlStr:String = rawData; //.replace(/\s+$/, "");
			
			// Remove whitespaces between tags
			xmlStr = xmlStr.replace(/(?<!span)>\s+<(?!$1)|(?<=span)>\s*[\n\r\t]\s*</g, "><");
			
			// Tell the XML class to show white space in text nodes		
			XML.ignoreWhitespace = false;
			// Tell the XML class not to normalize white space for toString() method calls
			XML.prettyPrinting = false;
			
			try {
				var xml:XML = new XML(xmlStr);
				
				// this cleans up some namespace wierdness with legacy dfxp 
				// or ttml that omits the default namespace
				var newNS:Namespace = repairNamespaces(xml);
								
				default xml namespace = newNS;
				ns = xml.namespace();
				tts = xml.namespace("tts");
				ttm = xml.namespace("ttm");
				ttp = xml.namespace("ttp");
				smpte = xml.namespace("smpte");
				m608 = xml.namespace("m608");
				xml.addNamespace(Namespaces.XML_NS);

				// rewrite xml with corrected namespace
				// xml = new XML(xmlStr);
				// xml = stripSMPTETTNodes(xml);
												
				//parsetree = TimedTextElementBase.parse(xml) as TtElement;
				//parsetree = XMLToTTElementParser.parse(xml) as TtElement;
				var asyncParser:XMLToTTElementParser = XMLToTTElementParser.parse(xml);
				asyncParser.addEventListener(ParseEvent.COMPLETE, onXMLToTTElementComplete);
				
			} catch (e:SMPTETTException) {
				SMPTETTLogging.debugLog("Unhandled exception in TimedTextParser : "+e.message);
				throw e;				
			} finally {
				// restore our original XML.ignoreWhitespace and XML.prettyPrinting settings from cache
				default xml namespace = Namespaces.XML_NS;
				XML.ignoreWhitespace = saveXMLIgnoreWhitespace;
				XML.prettyPrinting = saveXMLPrettyPrinting;
			}
			
			return parsetree;
		}

		private function onXMLToTTElementComplete(event:ParseEvent):void
		{
			var parsetree:TtElement = event.data as TtElement;
			if (parsetree == null)
			{
				debug("No Parse tree returned");
				throw new SMPTETTException("No Parse tree returned");
			}
			
			debug(this+" parseTTElement: "+(getTimer()-parseTime)/1000+"s");
			
			dispatchEvent(new ParseEvent(ParseEvent.PROGRESS, true, false, parsetree) );
		}
		
		private function validateTtElement(parsetree:TtElement):TtElement
		{	
			parseTime = getTimer();
			
			var isValid:Boolean = parsetree.valid();
			if (!isValid)
			{
				debug("Document is Well formed XML, but invalid Timed Text");
				throw new SMPTETTException("Document is Well formed XML, but invalid Timed Text");
			}
			
			debug(this+" validateTTElement(): "+isValid+ " "+(getTimer()-parseTime)/1000+"s");
			
			dispatchEvent(new ParseEvent(ParseEvent.PROGRESS, true, false, parsetree) );
			return parsetree;
		}
		
		private function computeTimeIntervals(parsetree:TtElement, i_startTime:TimeCode=null, i_endTime:TimeCode=null):TtElement
		{	
			parseTime = getTimer();
			
			if(!TimeExpression.CurrentTimeBase)
				TimeExpression.initializeParameters();
									
			var st:TimeCode = (i_startTime) ? i_startTime : new TimeCode(0,TimeExpression.CurrentSmpteFrameRate);
			var et:TimeCode = (i_endTime) ? i_endTime : new TimeCode(TimeCode.maxValue(TimeExpression.CurrentSmpteFrameRate),TimeExpression.CurrentSmpteFrameRate);
			
			parsetree.computeTimeIntervals(TimeContainer.PAR, st, et);

			debug(this+" computeTimeIntervals("+st+", "+et+"): "+(getTimer()-parseTime)/1000+"s\n"/* +parsetree.events.toString() */);
			
			dispatchEvent(new ParseEvent(ParseEvent.PROGRESS, true, false, parsetree) );
			return parsetree;
		}
		
		// private var regionElementsHash:Dictionary;
		// private var captionRegionsHash:Dictionary; 
		
		protected function buildRegions(document:TtElement):void
		{
			parseTime = getTimer();
			
			var regionElementsHash:Dictionary = new Dictionary();
			var regionElements:Vector.<RegionElement> = new Vector.<RegionElement>();
			if(document.head != null)
			{
				for each(var i:TreeType in document.head.children)
				{
					if(i is LayoutElement)
					{
						for each(var r:RegionElement in i.children)
						{
							regionElementsHash[r.id] = r;
							// trace(r.id);
						}						
					} else if(i is TitleElement)
					{
						_document.title = TitleElement(i).text;
					} else if(i is CopyrightElement)
					{
						_document.copyright = CopyrightElement(i).text;
					} else if(i is DescElement)
					{
						_document.description = DescElement(i).text;
					}
				}
			}
			
			var captionRegionsHash:Dictionary = new Dictionary();
			for each(var k:RegionElement in regionElementsHash)
			{
				var captionRegion:CaptionRegion = mapToCaptionRegion(k) as CaptionRegion;
				captionRegionsHash[captionRegion.id] = captionRegion;
				_document.addCaptionRegion(captionRegion);
			}
			
			var timelineEventsHash:Dictionary = new Dictionary();
			
			
			// trace((++this._taskId) + " build Regions");
			if (document.body != null)
			{
				remainingNodeCount = document.totalNodeCount;
				
				debug(this+" buildRegions: "+(getTimer()-parseTime)/1000+"s");
				debug(this+" totalNodeCount: "+remainingNodeCount);
				
				var parseEvent:ParseEvent = new ParseEvent(ParseEvent.PROGRESS);
					parseEvent.data = createParseEventData(document.body
						,regionElementsHash
						,captionRegionsHash
						,timelineEventsHash
					);
				dispatchEvent( parseEvent );
			}
			
			//return regions;
		}
		
		protected var parseTime:uint;
		protected function buildCaptions(timedTextElement:TimedTextElementBase, regionElementsHash:Dictionary, captionRegionsHash:Dictionary, timelineEventsHash:Dictionary):void
		{	
			var parseEvent:ParseEvent;
			var pElement:PElement = timedTextElement as PElement;
			if (pElement != null)
			{	
				var regionNameAttribute:TimedTextAttributeBase;
				for each(var i:TimedTextAttributeBase in timedTextElement.attributes)
				{
					if(i.localName=="region"){
						regionNameAttribute = i;
						break;
					}
				}
				var computedRegionName:String = pElement.getComputedStyle("region",null);
				var regionName:String = (regionNameAttribute) 
					? regionNameAttribute.value 
					: ((computedRegionName && computedRegionName!="") 
						? computedRegionName 
						: RegionElement.DEFAULT_REGION_NAME);
				var regionElement:RegionElement;
				if (regionElementsHash[regionName] && captionRegionsHash[regionName])
				{	
					regionElement = regionElementsHash[regionName];
					
					var captionElement:CaptionElement = mapToCaption(pElement, regionElement) as CaptionElement;
					var captionRegion:CaptionRegion = captionRegionsHash[regionName];
					
					captionElement.index = captionRegion.children.length;
					
					captionRegion.children.push(captionElement);
					
					var timecode:String = timedTextElement.begin.toString();
					if(timelineEventsHash[timecode]){
						CaptionElement(timelineEventsHash[timecode]).siblings.push(captionElement);
					} else {
						timelineEventsHash[timecode] = captionElement;
						_captionElements.push(captionElement); 
					}
						
					_document.addCaptionElement(captionElement);
					_document.captionRegionsHash[regionName].children.push(captionElement);
					
				}
			}
			else if (timedTextElement.children)
			{
				var count:uint = 0;
				var children:Vector.<TreeType> = timedTextElement.children;
				var j:TimedTextElementBase;
				for each(j in children)
				{
					AsyncThread.queue(buildCaptions, [ j, regionElementsHash, captionRegionsHash, timelineEventsHash ] );
				}
			}
			if(remainingNodeCount<=0)
			{
				parseEvent = new ParseEvent(ParseEvent.PROGRESS);
				parseEvent.data = createParseEventData(null, regionElementsHash, captionRegionsHash, timelineEventsHash);
				
				dispatchEvent( parseEvent );
			} else {
				// trace(SMPTETTParser.REMAINING_NODE_COUNT);
			}
		}
		
		protected function mapToCaptionRegion(regionElement:RegionElement):CaptionRegion
		{
			var endTime:Number = (regionElement.end.totalSeconds >= TimeSpan.MAX_VALUE.totalSeconds)
				? TimeSpan.MAX_VALUE.totalSeconds
				: regionElement.end.totalSeconds;
			
			var captionRegion:CaptionRegion = new CaptionRegion(regionElement.begin.totalSeconds, endTime, regionElement.id);
			captionRegion.id = regionElement.id;
			captionRegion.style = TimedTextStyleParser.mapStyle(regionElement, regionElement);
			
			for each (var element:TimedTextElementBase in regionElement.children)
			{
				
				var child:TimedTextElement = buildTimedTextElements(element, regionElement);
				
				if (child && child is TimedTextAnimation)
				{
					captionRegion.animations.push(child);
				}
			} 
			return captionRegion;
		}
		
		protected function mapToCaption(pElement:PElement, region:RegionElement):CaptionElement
		{	
			var captionElement:CaptionElement = buildTimedTextElements(pElement, region) as CaptionElement;
			captionElement.id = (pElement.id) ? pElement.id : getTimer().toString();
			return captionElement;
		}
		
		private function buildTimedTextElements(element:TimedTextElementBase, region:RegionElement):TimedTextElement
		{
			// trace(region.id+" buildTimedTextElements: "+ element+" "+(element.hasOwnProperty("text") ? element["text"]:""));
			
			var timedTextElement:TimedTextElement = createTimedTextElement(element, region);
			
			for each (var c:TimedTextElementBase in element.children)
			{
				var child:TimedTextElement = buildTimedTextElements(c, region);
				if (!child) continue;
				
				child.parentElement = timedTextElement;
				
				if (child is TimedTextAnimation)
				{
					timedTextElement.animations.push(child);
				} else if (child is CaptionElement)
				{
					CaptionElement(child).index = timedTextElement.children.length;
					timedTextElement.children.push(child);
				}
			}
			return timedTextElement;
		}
		
		private function createTimedTextElement(element:TimedTextElementBase, region:RegionElement):TimedTextElement
		{
			var captionElement:TimedTextElement = (element is SetElement)
				? TimedTextElement(buildCaptionAnimationElement(element))
				: new CaptionElement(element.begin.totalSeconds, element.end.totalSeconds) as TimedTextElement;
			
			if (captionElement is CaptionElement && region)
			{
				CaptionElement(captionElement).regionId = region.id;
			}
			
			// captionElement.end = element.end.totalSeconds;
			// captionElement.begin = element.begin.totalSeconds;
			
			if (element is BrElement)
			{
				captionElement.captionElementType = TimedTextElementType.LineBreak;
			} else if (element is AnonymousSpanElement)
			{
				var aSpan:AnonymousSpanElement = element as AnonymousSpanElement;
				captionElement.captionElementType = TimedTextElementType.Text;
				captionElement.content = aSpan.text;
				
				if (element.parent is SpanElement)
					captionElement.style = TimedTextStyleParser.mapStyle(TimedTextElementBase(element.parent), region);
				
				remainingNodeCount--;
			}
			else if (!(element is SetElement))
			{
				captionElement.captionElementType = (element is SpanElement) ? TimedTextElementType.SupParagraphGroupElement : TimedTextElementType.Container;
				captionElement.style = TimedTextStyleParser.mapStyle(element, region);
			}
			return captionElement;
		}
		
		private function buildCaptionAnimationElement(element:TimedTextElementBase):TimedTextAnimation
		{
			var propertyName:String;
			
			for each(var i:TimedTextAttributeBase in element.attributes) {
				if(TimedTextStyleParser.isValidAnimationPropertyName(i.localName)){
					propertyName = i.localName;
					break;
				}
			}
			if(propertyName && propertyName.length>0) {
				var tta:TimedTextAnimation = new TimedTextAnimation(element.begin.totalSeconds,element.end.totalSeconds);
				tta.captionElementType = TimedTextElementType.Animation;
				tta.propertyName = propertyName;
				tta.style = TimedTextStyleParser.mapStyle(element, null);
				return tta;
			} else {
				return null;
			}
		}
		
		protected function createParseEventData(i_timedTextElement:TimedTextElementBase=null, i_regionElementsHash:Dictionary=null, i_captionRegionsHash:Dictionary=null, i_timelineEventsHash:Dictionary=null):ParseEventData
		{
			return new ParseEventData(i_timedTextElement,i_regionElementsHash, i_captionRegionsHash, i_timelineEventsHash);
		}
		
		/**
		 * @private
		 */
		private function debug(msg:String):void
		{
			if (DEBUG)
			{	
				trace(msg);
				if (ExternalInterface.available)
					ExternalInterface.call("function(msg){ if (console && console.log) console.log(msg); }",msg);
			}
		}
	}
}

class ParseEventData
{
	import flash.utils.Dictionary;
	
	import org.osmf.smpte.tt.model.TimedTextElementBase;
	
	public var timedTextElement:TimedTextElementBase=null;
	public var regionElementsHash:Dictionary=null;
	public var captionRegionsHash:Dictionary=null;
	public var timelineEventsHash:Dictionary=null;
	
	public function ParseEventData(i_timedTextElement:TimedTextElementBase=null, i_regionElementsHash:Dictionary=null, i_captionRegionsHash:Dictionary=null, i_timelineEventsHash:Dictionary=null)
	{
		if(i_timedTextElement) timedTextElement = i_timedTextElement;
		if(i_regionElementsHash) regionElementsHash = i_regionElementsHash;
		if(i_captionRegionsHash) captionRegionsHash = i_captionRegionsHash;
		if(i_timelineEventsHash) timelineEventsHash = i_timelineEventsHash;
	}
}
