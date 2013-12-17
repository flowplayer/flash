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
package org.osmf.smpte.tt.timing
{	
	import flash.utils.Dictionary;
	
	import org.osmf.smpte.tt.model.TimedTextAttributeBase;
	
	public class TreeType 
	{	
		//{ region Constructor
		public function TreeType(p_attributes:Vector.<TimedTextAttributeBase>=null, p_children:Vector.<TreeType>=null)
		{
			if(!p_attributes || !p_children){
				_children = new Vector.<TreeType>();
				_attributes = new Vector.<TimedTextAttributeBase>();
			} else {
				_children = p_children;
				_attributes = p_attributes;
			}
			
		}
		//} endregion
		
		//{ region Variables and Properties
		private var _timing:Dictionary = new Dictionary();
		/**
		 * The begin, end and dur times for this node
		 */
		public function get timing():Dictionary
		{
			return _timing;
		}
		
		private var _timeSemantics:TimeContainer = TimeContainer.PAR;
		/**
		 * Specifies whether children are sequential or parallel in time. 
		 * unless an element overrides, the default is par.
		 */
		public function get timeSemantics():TimeContainer
		{
			return _timeSemantics;
		}
		public function set timeSemantics(value:TimeContainer):void
		{
			_timeSemantics = value;
		}
		
		private var _startTime:TimeCode;
		private var _endTime:TimeCode;
		
		/**
		 * Get the time at which this element becomes active
		 */
		public function get begin():TimeCode
		{
			return _startTime;
		}
		
		/**
		 * Get the time at which this element is no longer active
		 */
		public function get end():TimeCode
		{
			return _endTime;
		}
		
		/**
		 * Get the time at which this element is no longer active
		 */
		public function get duration():TimeCode
		{
			return _endTime.minus(_startTime);
		}
		//} endregion
		
		//{ region time container semantics
		/**
		 * Test if the tree is active at the given time
		 * 
		 * @param time time of test
		 * @returns true if active
		 */
		public function temporallyActive(time:TimeCode):Boolean
		{
			return (begin.lessThanOrEqualTo(time) && time.lessThan(end));
		}
		
		/**
		 * Apply function to all elements in the tree and return a flattened list
		 * 
		 * @param function
		 * @returns
		 */		
		private function reduce(p_func:Function):Vector.<TimeCode>
		{
			var result:Vector.<TimeCode> = new Vector.<TimeCode>();
			result = result.concat( p_func(this as TreeType) );
			for each (var c:TreeType in children)
			{
				result = result.concat( c.reduce(p_func) );
			}
			return result;
		}
		
		private var _events:Vector.<TimeCode>;
		/** 
		 * return an ordered list of the significant time events 
		 * in the time tree.
		 */ 
		public function get events():Vector.<TimeCode>
		{   
			if (!_events)
			{
				var reduceQuery:Function = function(tree:TreeType):Vector.<TimeCode>
				{
					var t:Vector.<TimeCode> = new Vector.<TimeCode>();
					t.push(tree.begin);
					t.push(tree.end);
					return t;
				}
				_events = distinctTimeCodeVector( this.reduce(reduceQuery) );
			} 
			return _events;
		}
		
		private function distinctTimeCodeVector(pv:Vector.<TimeCode>):Vector.<TimeCode>
		{
			var dict:Dictionary = new Dictionary();
			var i:uint = 0, tc:TimeCode;
			var unique:Vector.<TimeCode> = new Vector.<TimeCode>();
			for each(tc in pv)
			{
				if(!dict[tc.totalFrames])
				{
					dict[tc.totalFrames] = true;
					unique[unique.length] = tc;
				}
			}
			return unique.sort(TimeCode.Compare);
		}
		
		/**
		 * Walk the tree to determine the absolute start and end times of all the elements.
		 * the reference times passed in are absolute times, the result of calling this is to set the local start time 
		 * and end time to absolute times between these two reference times, based on the begin, end and dur attributes 
		 * and to recursively set all of the children.
		 */
		public function computeTimeIntervals(context:TimeContainer, referenceStart:TimeCode, referenceEnd:TimeCode):void
		{			
			var referenceDur:TimeCode,
				locBegin:TimeCode,
				locDur:TimeCode, 
				locEnd:TimeCode;
				
			_startTime = new TimeCode(0, TimeExpression.CurrentSmpteFrameRate);
			_endTime = new TimeCode(0, TimeExpression.CurrentSmpteFrameRate);
			
			// compute the beginning of my interval.
			locBegin = (timing["begin"]) ? TimeCode(timing["begin"]) : new TimeCode(0, TimeExpression.CurrentSmpteFrameRate);
			_startTime = referenceStart.plus(locBegin);
			
			// compute the simple duration of the interval,  
			// par children have indefinite default duration, seq children have zero default duration.
			// (we dont support indefinite here but  truncate to the outer container)
			// does end work here?  surely it truncates the active duration, 
			if (!timing["dur"] && !timing["end"] && context == TimeContainer.SEQ)
			{
				referenceDur = new TimeCode(0, TimeExpression.CurrentSmpteFrameRate);
			}
			else
			{
				if (_startTime.lessThan(referenceEnd))
				{
					referenceDur = referenceEnd.minus(_startTime);
				}
				else
				{
					referenceDur = new TimeCode(0, TimeExpression.CurrentSmpteFrameRate);
				}
			}
			
			var containsDur:Boolean = false;
			if (timing["dur"])
			{
				containsDur = true;
				locDur = TimeCode(timing["dur"]);
				if (locDur.greaterThan(referenceDur))
				{
					locDur = referenceDur;
				}
			}
			else
			{
				locDur = referenceDur;
			}
			_endTime = _startTime.plus(locDur);
			
			// end can truncate the simple duration.
			var offsetEnd:TimeCode = new TimeCode(0, TimeExpression.CurrentSmpteFrameRate);
			offsetEnd = offsetEnd.plus(referenceStart);

			if (timing["end"])
			{
				locEnd = referenceStart.plus(TimeCode(timing["end"]));
			}
			else
			{
				// Original code:
				//
				// end = referenceEnd;
				//
				// NOTE: This logic was changed from original TimedText library to properly handle 
				//       Sequential time containers when the duration is indefinite.
				if (context == TimeContainer.PAR)
				{
					locEnd = referenceEnd;
				}
				else
				{
					locEnd = _startTime.plus(referenceDur);
				}
			}
			//end = (Timing.ContainsKey("end")) ? (m_startTime.Add((TimeSpan)Timing["end"])) : referenceEnd;
			if (!containsDur)
			{
				_endTime = locEnd;
			}
			else
			{
				_endTime = (locEnd.lessThan(_endTime)) ? locEnd : _endTime;
			}
			
			// trace("\t"+this+((this.hasOwnProperty("text")&&this["text"]!=null)?" \""+this["text"]+"\"":"")+"\n\t.computeTimeIntervals()={begin:"+begin+",duration:"+duration+",end:"+end+"}");
			
			var child:TreeType;
			var i:uint = 0;
			var len:uint = children.length;
			if (timeSemantics == TimeContainer.PAR)
			{
				for (i = 0; i<len; i++)
				{
					child = children[i] as TreeType;
					child.computeTimeIntervals(timeSemantics, _startTime, _endTime);
				}
			}
			else
			{
				var s:TimeCode = _startTime;
				for (i = 0; i<len; i++)
				{
					child = children[i] as TreeType;
					child.computeTimeIntervals(timeSemantics, s, _endTime);
					s = child.end;
				}
			}
		}
		
		//}endregion
		private var _metadata:Dictionary = new Dictionary();
		/**
		 * Metadata associated with this node
		 */
		public function get metadata():Dictionary
		{
			return _metadata;
		}
		
		private var _children:Vector.<TreeType>;
		private var _attributes:Vector.<TimedTextAttributeBase>;
		private var _parent:TreeType;
		
		/**
		 * tree node which is the unique parent of this node
		 */
		public function get parent():TreeType
		{
			return _parent;
			
		}
		public function set parent(value:TreeType):void
		{
			_parent = value;
		}
		
		/**
		 * List of time trees that are contained within this node
		 */
		public function get children():Vector.<TreeType>
		{
			return _children;
		}
		
		/**
		 * List of attributes associated with this node
		 */
		public function get attributes():Vector.<TimedTextAttributeBase>
		{
			return _attributes;
		}
		//} endregion
		
	}
}