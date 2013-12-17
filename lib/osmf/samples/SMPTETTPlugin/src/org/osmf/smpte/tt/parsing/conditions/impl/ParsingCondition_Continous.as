package org.osmf.smpte.tt.parsing.conditions.impl
{
	import org.osmf.smpte.tt.model.TimedTextElementBase;
	import org.osmf.smpte.tt.parsing.conditions.ParsingCondition;
	
	public class ParsingCondition_Continous implements ParsingCondition
	{
		public function ParsingCondition_Continous()
		{
		}
		
		public function evaluate(timedTextElement:TimedTextElementBase):Boolean
		{
			return true;
		}
		
		public function setDuration(v:Number):void
		{
		}
		
		public function debugString():String
		{
			return this + "always true";
		}
	}
}