package org.osmf.smpte.tt.parsing.conditions.impl
{
	import org.osmf.smpte.tt.model.TimedTextElementBase;
	import org.osmf.smpte.tt.parsing.conditions.ParsingCondition;
	
	public class ParsingCondition_PercentageIntervalByTime implements ParsingCondition
	{
		private var _duration:Number;
		private var _percentageInterval:Number;
		private var _debugOutput:String
		private var _lastPercentage:Number = 0;
		
		public function ParsingCondition_PercentageIntervalByTime(percentageIntervalAsInt:Number=10)
		{
			_percentageInterval = percentageIntervalAsInt;
			
		}
		
		public function evaluate(timedTextElement:TimedTextElementBase):Boolean
		{
			var endTime:Number = timedTextElement.end.duration;
			var pct:Number = Math.round(endTime/_duration*100);
			_debugOutput = String(pct);
			var condition:Boolean = pct % _percentageInterval == 0
			if (condition && pct != _lastPercentage)
			{
				_lastPercentage = pct;
				return condition;
			}
			return false;
		}
		
		public function setDuration(v:Number):void
		{
			_duration = v;
		}
		
		
		public function debugString():String
		{
			return this + "pct=" +_debugOutput;
		}
	}
}