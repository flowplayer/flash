package org.osmf.smpte.tt.parsing
{
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import org.osmf.smpte.tt.captions.CaptionElement;
	import org.osmf.smpte.tt.captions.CaptionRegion;
	import org.osmf.smpte.tt.events.ParseEvent;
	import org.osmf.smpte.tt.model.PElement;
	import org.osmf.smpte.tt.model.RegionElement;
	import org.osmf.smpte.tt.model.TimedTextAttributeBase;
	import org.osmf.smpte.tt.model.TimedTextElementBase;
	import org.osmf.smpte.tt.model.TtElement;
	import org.osmf.smpte.tt.parsing.conditions.ParsingCondition;
	import org.osmf.smpte.tt.parsing.conditions.ParsingConditionFactory;
	import org.osmf.smpte.tt.timing.TimeExpression;
	import org.osmf.smpte.tt.timing.TreeType;
	import org.osmf.smpte.tt.utilities.AsyncThread;
	
	[Event(name="partial", type="org.osmf.smpte.tt.events.ParseEvent")]
	
	public class SMPTETTParserAsync extends SMPTETTParser
	{
		private var partialCriteriaMet:Boolean = false;
		private var partialEventFired:Boolean = false;
		
		private var totalNodeCount:int;
		private var documentDuration:Number;
		private var _parsingCondition:ParsingCondition
		
		
		public function SMPTETTParserAsync()
		{
			super();
			//trace("SMPTETTParserByNode");
		}
		
		
		public function get parsingCondition():ParsingCondition
		{
			if (! _parsingCondition)
			{
				_parsingCondition = ParsingConditionFactory.getCondition();
				_parsingCondition.setDuration(documentDuration);
			}
			return _parsingCondition;
		}

		public function set parsingCondition(value:ParsingCondition):void
		{
			_parsingCondition = value;
		}

		protected override function buildRegions(document:TtElement):void
		{
			super.buildRegions(document);
			totalNodeCount = document.totalNodeCount;
			documentDuration = document.body.duration.duration
		}

		
		protected override function buildCaptions(timedTextElement:TimedTextElementBase, regionElementsHash:Dictionary, captionRegionsHash:Dictionary, timelineEventsHash:Dictionary):void
		{	
			var pElement:PElement = timedTextElement as PElement;
			if (pElement != null)
			{	
				buildCaptionWithPElement(timedTextElement,pElement,regionElementsHash,captionRegionsHash,timelineEventsHash);
			}
			else if (timedTextElement.children)
			{
				buildCaptionWithChildren(timedTextElement,regionElementsHash,captionRegionsHash,timelineEventsHash);
			}
			
			determineBuildCaptionProgress(timedTextElement,regionElementsHash,captionRegionsHash,timelineEventsHash);
		}

		private function buildCaptionWithPElement(timedTextElement:TimedTextElementBase, pElement:PElement, regionElementsHash:Dictionary, captionRegionsHash:Dictionary, timelineEventsHash:Dictionary):void
		{
			//trace ("buildCaptionWithPElement: Start" + getTimer())
			var regionNameAttribute:TimedTextAttributeBase;
			
			//For each loop, looks like it has 5 nodes, and region is the first
			for each(var i:TimedTextAttributeBase in timedTextElement.attributes)
			{
				if(i.localName=="region"){
					regionNameAttribute = i;
					break;
				}
			}			
			
			//get Computed Style has recursion
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
		
				//Map to Caption is the offender (2ms execution time)
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
		
				//trace("buildCaptionWithPElement: end:" + getTimer());
			}
		}

		private function buildCaptionWithChildren(timedTextElement:TimedTextElementBase, regionElementsHash:Dictionary, captionRegionsHash:Dictionary, timelineEventsHash:Dictionary):void
		{
			//trace("buildCaptionWithChildren:" + timedTextElement.children.length)
			var count:uint = 0;
			var children:Vector.<TreeType> = timedTextElement.children;
			var j:TimedTextElementBase;
			for each(j in children)
			{
				AsyncThread.queue(buildCaptions, [ j, regionElementsHash, captionRegionsHash, timelineEventsHash ] );
			}
		}

		private function determineBuildCaptionProgress(timedTextElement:TimedTextElementBase, regionElementsHash:Dictionary, captionRegionsHash:Dictionary, timelineEventsHash:Dictionary):void
		{
			var parseEvent:ParseEvent;
			if(isAllNodesProcessed())
			{
				parseEvent = new ParseEvent(ParseEvent.PROGRESS);
				parseEvent.data = createParseEventData(null, regionElementsHash, captionRegionsHash, timelineEventsHash);

			} 
			else if (isPartiallyProcessed(timedTextElement))
			{
				// trace("determineBuildCaptionProgress: PARTIAL " + parsingCondition.debugString() + " @ " + (getTimer()-parseTime)/1000+"s")
				parseEvent = new ParseEvent(ParseEvent.PARTIAL);
				parseEvent.data = _document;
			}
			
			if (parseEvent)
			{
				dispatchEvent(parseEvent);
			}
		}

		private function isAllNodesProcessed():Boolean
		{
			return remainingNodeCount<=0;
		}
		
		private function isPartiallyProcessed(timedTextElement:TimedTextElementBase):Boolean
		{
			var rtn:Boolean = false;
			
			//Parsing conditions are only relevant to PElements
			//All other incoming elements are structural, and not relevant to captions
			if (timedTextElement is PElement)
			{
				rtn =  parsingCondition.evaluate(timedTextElement);
			}
			return rtn;
		}
		
	}
}
