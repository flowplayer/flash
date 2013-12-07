package org.osmf.smpte.tt.parsing.conditions
{
	import org.osmf.smpte.tt.model.TimedTextElementBase;

	public interface ParsingCondition
	{
		function evaluate(timedTextElement:TimedTextElementBase):Boolean;
		function setDuration(v:Number):void;
		function debugString():String;
	}
}