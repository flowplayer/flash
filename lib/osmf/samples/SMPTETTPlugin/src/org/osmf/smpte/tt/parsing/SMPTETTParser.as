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
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import org.osmf.smpte.tt.captions.CaptionElement;
	import org.osmf.smpte.tt.captions.CaptionRegion;
	import org.osmf.smpte.tt.captions.CaptioningDocument;
	import org.osmf.smpte.tt.captions.TimedTextAnimation;
	import org.osmf.smpte.tt.captions.TimedTextElement;
	import org.osmf.smpte.tt.captions.TimedTextElementType;
	import org.osmf.smpte.tt.errors.SMPTETTException;
	import org.osmf.smpte.tt.events.ParseEvent;
	import org.osmf.smpte.tt.formatting.Animation;
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
	import org.osmf.smpte.tt.utilities.DictionaryUtils;
	import org.osmf.smpte.tt.vocabulary.Namespaces;

	[Event(name="begin", type="org.osmf.smpte.tt.events.ParseEvent")]
	[Event(name="progress", type="org.osmf.smpte.tt.events.ParseEvent")]
	[Event(name="complete", type="org.osmf.smpte.tt.events.ParseEvent")]
	
	public class SMPTETTParser extends EventDispatcher 
		implements IEventDispatcher, ISMPTETTParser
	{
		
		
		
		
		public static var ns:Namespace;
		public static var ttm:Namespace;
		public static var tts:Namespace;
		public static var ttp:Namespace;
		public static var smpte:Namespace;
		public static var m608:Namespace;
		public static var rootNamespace:Namespace;
		
		private var _document:CaptioningDocument;
		private var _sprite:Sprite;

		private function get sprite():Sprite
		{
			if(!_sprite){
				_sprite = new Sprite();
			}
			return _sprite;
		}

		public function get document():CaptioningDocument
		{
			return _document;
		}
		
		public function SMPTETTParser(){
		}
		
		private var _startTime:TimeCode = null;
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
		
		private var _captionElements:Vector.<CaptionElement>;
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
		
		public function parse(i_rawData:String):CaptioningDocument
		{			
			_document = new CaptioningDocument();
			
			// if global time parameters for this session haven't been established, we should set them
			if(!TimeExpression.CurrentTimeBase){
				TimeExpression.initializeParameters();
			}
				
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
				addEventListener(ParseEvent.PROGRESS, handleComputeTimeIntervals);
				
				_ttElement = e.data as TtElement;
				computeTimeIntervals(e.data as TtElement, _startTime, _endTime);
			}
		}
		
		private function handleComputeTimeIntervals(e:ParseEvent):void
		{
			
			if(e.data && e.data is TtElement){
				//trace(this+".handleComputeTimeIntervals("+e+")");
				removeEventListener(ParseEvent.PROGRESS, handleComputeTimeIntervals);
				var parseTree:TtElement =  e.data as TtElement;
				_ttElement = parseTree;
				//trace(_ttElement.serialize());
				addEventListener(ParseEvent.PROGRESS, handleBuildDocumentTimeInterval);
				buildRegions(parseTree);
			}
		}
		
		private var asyncThread:AsyncThread;		
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
						
						if(!asyncThread){
							asyncThread =AsyncThread.create( buildCaptions, [ ped.timedTextElement,ped.regionElementsHash,ped.captionRegionsHash,ped.timelineEventsHash ] );
							asyncThread.runEachFrame(100);
						} else {
							AsyncThread.queue( buildCaptions, [ ped.timedTextElement,ped.regionElementsHash,ped.captionRegionsHash,ped.timelineEventsHash ] );
						}
						
					} else
					{
						removeEventListener(ParseEvent.PROGRESS, handleBuildDocumentTimeInterval);
						
						var keys:Array = DictionaryUtils.getKeys(ped.timelineEventsHash).sort();
						
						_captionElements = new Vector.<CaptionElement>;
						for each(var k:String in keys)
						{
							_captionElements.push(ped.timelineEventsHash[k]);
						} 
						
						this._regionElementsHash = ped.regionElementsHash;
						this._captionRegionsHash =  ped.captionRegionsHash;
						
						dispatchEvent(new ParseEvent(ParseEvent.COMPLETE, true, false, _document));
					}
				}
			}
		}
		
		private function repairNamespaces(xml:XML):Namespace {
			var newDefaultNS:Namespace = xml.namespace();
			if (newDefaultNS.uri.length==0)
			{
				var nsDeclarations:Array = xml.namespaceDeclarations();
				for each(var ns:Namespace in nsDeclarations)
				{
					if(ns.uri.match(/^http\:\/\/www\.w3\.org\/2006\/(?:02|04|10)\/ttaf1/)
						|| ns.uri.indexOf("http://www.w3.org/ns/ttml")==0)
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
			
			return 	newDefaultNS;	
		}
		
		private function parseTtElement(rawData:String):TtElement
		{
			var parsetree:TtElement = null;
			
			// cache our original XML.ignoreWhitespace and XML.prettyPrinting settings
			var saveXMLIgnoreWhitespace:Boolean = XML.ignoreWhitespace;
			var saveXMLPrettyPrinting:Boolean = XML.prettyPrinting; 
			
			// Remove line ending whitespaces
			var xmlStr:String = rawData.replace(/\s+$/, "");
			
			// Remove whitespaces between tags
			xmlStr = xmlStr.replace(/>\s+</g, "><");
			
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

				// rewrite xml with corrected namespace
				xml = new XML(xmlStr);
								
				default xml namespace = new Namespace( "" );
				
				parsetree = TimedTextElementBase.parse(xml) as TtElement;
								
			} catch (e:SMPTETTException) {
				SMPTETTLogging.debugLog("Unhandled exception in TimedTextParser : "+e.message);
				throw e;				
			} finally {
				// restore our original XML.ignoreWhitespace and XML.prettyPrinting settings from cache
				XML.ignoreWhitespace = saveXMLIgnoreWhitespace;
				XML.prettyPrinting = saveXMLPrettyPrinting;
			}
			
			if (parsetree == null)
			{
				trace("No Parse tree returned");
				throw new SMPTETTException("No Parse tree returned");
			}
			if (!parsetree.valid())
			{
				trace("Document is Well formed XML, but invalid Timed Text");
				throw new SMPTETTException("Document is Well formed XML, but invalid Timed Text");
			}
			dispatchEvent(new ParseEvent(ParseEvent.PROGRESS, true, false, parsetree) );
			return parsetree;
		}
		
		private function computeTimeIntervals(parsetree:TtElement, i_startTime:TimeCode=null, i_endTime:TimeCode=null):TtElement
		{	
			var startTime:TimeCode = (i_startTime) ? i_startTime : TimeExpression.parse("00:00:00:00");
			var endTime:TimeCode = (i_endTime) ? i_endTime : TimeExpression.parse("12:00:00:00");
			
			parsetree.computeTimeIntervals(TimeContainer.PAR, startTime, endTime);	
			
			//XML.ignoreWhitespace = true;
			//XML.prettyPrinting = false;
			// trace(XML(parsetree.serialize()).toXMLString());
			
			dispatchEvent(new ParseEvent(ParseEvent.PROGRESS, true, false, parsetree) );
			return parsetree;
		}
		
		// private var regionElementsHash:Dictionary;
		// private var captionRegionsHash:Dictionary; 
		
		private var remainingNodeCount:int = 0;
		private function buildRegions(document:TtElement):void
		{
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
			for each(var k:RegionElement in regionElementsHash){
				var captionRegion:CaptionRegion = mapToCaptionRegion(k) as CaptionRegion;
				captionRegionsHash[captionRegion.id] = captionRegion;
				_document.addCaptionRegion(captionRegion);
			}
			
			var timelineEventsHash:Dictionary = new Dictionary();
			
			
			// trace((++this._taskId) + " build Regions");
			if (document.body != null)
			{
				remainingNodeCount = document.totalNodeCount;
				
				trace("totalNodeCount: "+document.totalNodeCount);
				
				var parseEvent:ParseEvent = new ParseEvent(ParseEvent.PROGRESS);
					parseEvent.data = new ParseEventData(document.body
						,regionElementsHash
						,captionRegionsHash
						,timelineEventsHash
					);
				dispatchEvent( parseEvent );
			}
			
			//return regions;
		}
		
		private var parseTime:uint;
		private function buildCaptions(timedTextElement:TimedTextElementBase, regionElementsHash:Dictionary, captionRegionsHash:Dictionary, timelineEventsHash:Dictionary):void
		{	
			if(!parseTime) parseTime=flash.utils.getTimer();
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
				var regionName:String = (regionNameAttribute != null) 
					? regionNameAttribute.value 
					: ((computedRegionName && computedRegionName!="") 
						? computedRegionName 
						: RegionElement.DEFAULT_REGION_NAME);
				var regionElement:RegionElement;
				if (DictionaryUtils.containsKey(regionElementsHash,regionName))
				{	
					regionElement =  regionElementsHash[regionName];
					var captionElement:CaptionElement = mapToCaption(pElement, regionElement) as CaptionElement;
					
					var captionRegion:CaptionRegion;
					if (DictionaryUtils.containsKey(captionRegionsHash, regionName))
					{
						captionRegion = captionRegionsHash[regionName];
						captionElement.index = captionRegion.children.length;
						
						captionRegion.children.push(captionElement);
						
						var timecode:String = TimeExpression.parse(captionElement.begin+"s").toString();
						if(timelineEventsHash[timecode] is CaptionElement){
							(timelineEventsHash[timecode] as CaptionElement).siblings.push(captionElement);
						} else {
							timelineEventsHash[timecode] = captionElement;
							// trace("new timeline event at "+timecode);
						}
						
						_document.addCaptionElement(captionElement);
						_document.captionRegionsHash[regionName].children.push(captionElement);
					}
				}
			}
			else if (timedTextElement.children != null)
			{
				//trace((++this._taskId) + " build Captions");
				var count:uint = 0;
				var children:Vector.<TreeType> = timedTextElement.children;
				var j:TimedTextElementBase;
				for each(j in children)
				{
					//j = children[k] as TimedTextElementBase;
					
					//trace(j)
					
					/* green-threading */
					/*
					if(getTimer()-parseTime<100){
						buildCaptions(j, regionElementsHash, captionRegionsHash, timelineEventsHash);
					} else {
						parseTime = getTimer();
						
						parseEvent = new ParseEvent(ParseEvent.PROGRESS);
						parseEvent.data = new ParseEventData(j, regionElementsHash, captionRegionsHash, timelineEventsHash);
						dispatchEvent( parseEvent );
					}
					*/
					AsyncThread.queue(buildCaptions, [ j, regionElementsHash, captionRegionsHash, timelineEventsHash ] );
				}
			}
			if(remainingNodeCount<=0)
			{
				parseEvent = new ParseEvent(ParseEvent.PROGRESS);
				parseEvent.data = new ParseEventData(null, regionElementsHash, captionRegionsHash, timelineEventsHash);
				
				dispatchEvent( parseEvent );
			} else {
				// trace(remainingNodeCount);
			}
		}
		
		private function mapToCaptionRegion(regionElement:RegionElement):CaptionRegion
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
				
				if (child != null && child.captionElementType == TimedTextElementType.Animation)
				{
					captionRegion.animations.push(child as TimedTextAnimation);
				}
			} 
			return captionRegion;
		}
		
		private function mapToCaption(pElement:PElement, region:RegionElement):CaptionElement
		{	
			var captionElement:CaptionElement = buildTimedTextElements(pElement, region) as CaptionElement;
			captionElement.id = (pElement.id) ? pElement.id : flash.utils.getTimer().toString(); //GUID.create();
			return captionElement;
		}
		
		private function buildTimedTextElements(element:TimedTextElementBase, region:RegionElement):TimedTextElement
		{
			// trace(region.id+" buildTimedTextElements: "+ element+" "+(element.hasOwnProperty("text") ? element["text"]:""));
			
			var timedTextElement:TimedTextElement = createTimedTextElement(element, region);
			var captionElement:CaptionElement = timedTextElement as CaptionElement;
			
			for each (var c:TimedTextElementBase in element.children)
			{
				var child:TimedTextElement = buildTimedTextElements(c, region);
				if (child is TimedTextAnimation)
				{
					timedTextElement.animations.push(TimedTextAnimation(child));
				} else if (captionElement != null && child is CaptionElement)
				{
					(child as CaptionElement).index = captionElement.children.length;
					captionElement.children.push(child as CaptionElement);
				}
			}
			return timedTextElement;
		}
		
		private function createTimedTextElement(element:TimedTextElementBase, region:RegionElement):TimedTextElement
		{
			var captionElement:TimedTextElement = (element is SetElement)
				? TimedTextElement(buildCaptionAnimationElement(element))
				: new CaptionElement(element.begin.totalSeconds, element.end.totalSeconds) as TimedTextElement;
			
			if(captionElement is CaptionElement && region) {
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
				
				var styledElement:TimedTextElementBase = (element.parent is SpanElement) ? TimedTextElementBase(element.parent) : element;
				
				captionElement.style = TimedTextStyleParser.mapStyle(styledElement, region);
				
				remainingNodeCount--;
			}
			/*
			else if (element is SpanElement
				&& element.children.length==1 
				&& element.children[0] is AnonymousSpanElement)
			{
				var span:SpanElement = element as SpanElement;
				var child:AnonymousSpanElement = span.children[0] as AnonymousSpanElement;				
				captionElement.captionElementType = TimedTextElementType.Text;
				captionElement.content = child.text;
				captionElement.style = TimedTextStyleParser.mapStyle(span as TimedTextElementBase, region);
				//remainingNodeCount--;
			}
			*/
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
	}
}

class ParseEventData
{
	import org.osmf.smpte.tt.model.TimedTextElementBase;
	import flash.utils.Dictionary;
	
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
