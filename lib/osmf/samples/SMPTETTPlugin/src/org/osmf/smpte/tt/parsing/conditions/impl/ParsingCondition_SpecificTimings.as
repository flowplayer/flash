package org.osmf.smpte.tt.parsing.conditions.impl
{
	import org.osmf.smpte.tt.model.TimedTextElementBase;
	import org.osmf.smpte.tt.parsing.conditions.ParsingCondition;
	
	public class ParsingCondition_SpecificTimings implements ParsingCondition
	{
		private var timings:Array /*durations in seconds */
		private var _debugOutput:String
		
		public function ParsingCondition_SpecificTimings(timings:Array/*durations in seconds*/ = null)
		{
			this.timings = (timings)? timings:[];
		}
		
		public function evaluate(timedTextElement:TimedTextElementBase):Boolean
		{
			var rtn:Boolean = false;
			var beginTime:Number = timedTextElement.begin.duration;
			if (timings.length > 0)
			{
				var nextRequestedTime:Number = timings[0];
				if (beginTime >= nextRequestedTime)
				{
					rtn = true;
					var lastTiming:Number =timings.shift();
					_debugOutput = String(lastTiming);
				}
			}
			return rtn;
		}
		
		public function setDuration(v:Number):void
		{
		}
		
		
		public function debugString():String
		{
			return this + "timing target=" +_debugOutput;
		}
	}
}