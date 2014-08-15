package org.osmf.smpte.tt.parsing.conditions
{
	import org.osmf.smpte.tt.parsing.conditions.impl.ParsingCondition_Continous;
	import org.osmf.smpte.tt.parsing.conditions.impl.ParsingCondition_PercentageIntervalByTime;
	import org.osmf.smpte.tt.parsing.conditions.impl.ParsingCondition_SpecificTimings;

	public class ParsingConditionFactory
	{
		public static function getCondition():ParsingCondition
		{
			return atDefinedDurations();
		}

		private static function every10PercentDuration():ParsingCondition
		{
			return new ParsingCondition_PercentageIntervalByTime(10);
		}

		private static function atDefinedDurations():ParsingCondition
		{
			var definedDurationsInSeconds:Array=[100,200,300,400,500,600,700,800,900,1000,1100,1200,1300,1400,1500,1600,1700,1800,1900,2000,2100,2200,2300,2400,2500,2600,2700,2800,2900,3000,3100,3200,3300,3400,3500,3600,3700,3800,3900,4000,4100,4200,4300,4400,4500,4600,4700,4800,4900,5000,5100,5200,5300,5400,5500,5600,5700,5800,5900,6000,6100,6200,6300,6400,6500,6600,6700,6800,6900,7000,7100,7200];
			return new ParsingCondition_SpecificTimings(definedDurationsInSeconds);
		}

		private static function continously():ParsingCondition
		{
			return new ParsingCondition_Continous();
		}
	}
}
