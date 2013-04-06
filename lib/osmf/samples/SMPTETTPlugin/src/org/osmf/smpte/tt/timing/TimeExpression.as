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
	import org.osmf.smpte.tt.errors.SMPTETTException;
	import org.osmf.smpte.tt.utilities.StringUtils;

	public class TimeExpression
	{
		
		/**
		 * clock-time
		 *   : hours ":" minutes ":" seconds ( fraction | ":" frames ( "." sub-frames )? )?
		 */ 
		public static const clockTimeRegex:RegExp = /^(?P<hrs>\d+):(?P<mins>[0-5]\d):(?P<secs>[0-5]\d)((?P<subsecs>\.\d+)|:(?P<frames>\d\d+(?P<subframes>\.\d+)?))?$/;
		
		/**
		 * offset-time
		 *   : time-count fraction? metric
		 */
		public static const offsetTimeRegex:RegExp = /^(?P<value>\d+(\.\d+)?)(?P<units>ms|[hmsft])$/;
		
		/**
		 * Global clock mode for the current parse session.
		 */	
		public static var CurrentClockMode:ClockMode;
		
		/**
		 * Global time base for the current parse session.
		 */		
		public static var CurrentTimeBase:TimeBase;
		
		/**
		 * Global smpte mode for the current parse session.
		 */
		public static var CurrentSmpteMode:SmpteMode;
		
		/**
		 * Global framerate for the current parse session
		 */
		public static var CurrentFrameRate:Number;
		
		/**
		 * Global sub frame rate for the current parse session
		 */
		public static var CurrentSubFrameRate:Number;
		
		/**
		 * Global frame rate nominator for the current parse session
		 */
		public static var CurrentFrameRateNominator:Number;
		
		/**
		 * Global frame rate denominator for the current parse session
		 */
		public static var CurrentFrameRateDenominator:Number;

		
		/**
		 * Global tick rate for the current parse session
		 */
		public static var CurrentTickRate:uint;
		
		
		/**
		 * Global Smpte timecode to use for the current parse session
		 */
		public static function get CurrentSmpteFrameRate():SmpteFrameRate
		{
			if (TimeExpression.CurrentFrameRateDenominator == 0) TimeExpression.CurrentFrameRateDenominator = 1;
			var framerate:Number = TimeExpression.CurrentFrameRate * (TimeExpression.CurrentFrameRateNominator / TimeExpression.CurrentFrameRateDenominator);
			var s:SmpteFrameRate = SmpteFrameRate.UNKNOWN;
			switch (TimeExpression.CurrentTimeBase)
			{
				case TimeBase.SMPTE:
					switch (TimeExpression.CurrentSmpteMode)
					{
						case SmpteMode.DROP_NTSC:
						case SmpteMode.DROP_PAL:
							s = SmpteFrameRate.SMPTE_2997_DROP;
						case SmpteMode.NON_DROP:
							s = TimeCode.parseFramerate(framerate);
					}
					break;
				case TimeBase.MEDIA:
					s = SmpteFrameRate.SMPTE_30;
					break;
				case TimeBase.CLOCK:
					s = SmpteFrameRate.UNKNOWN;
					break;
			}
			return s;
		}
		
		/**
		 * Initialize global parameters for the next parse session
		 */
		public static function initializeParameters():void
		{
			TimeExpression.CurrentTimeBase = TimeBase.MEDIA;
			TimeExpression.CurrentTickRate = 1;
			TimeExpression.CurrentSubFrameRate = 1;
			TimeExpression.CurrentSmpteMode = SmpteMode.NON_DROP;
			TimeExpression.CurrentFrameRate = 30;
			TimeExpression.CurrentFrameRateDenominator = 1;
			TimeExpression.CurrentFrameRateNominator = 1;
			TimeExpression.CurrentClockMode = ClockMode.LOCAL;
		}
		
		/// <summary>
		/// Convert a timed text time expression into a TimeCode. 
		/// Where the current global framerate and tickrate apply
		/// </summary>
		/// <param name="timeExpression">Time expression</param>
		/// <returns>TimeSpan duration equal to time expression (ignored)</returns>
		public static function parse(p_timeExpression:String):TimeCode
		{
			var hours:uint = 0,
				minutes:uint = 0,
				seconds:uint = 0,
				frames:uint = 0,
				// subframes = 0,
				subseconds:Number = 0,
				m:Array;
			
			var input:String = StringUtils.trim( p_timeExpression );
			var framerate:Number = TimeExpression.CurrentFrameRate * (TimeExpression.CurrentFrameRateNominator / TimeExpression.CurrentFrameRateDenominator);
			
			var validTimeExpression:Boolean = (TimeExpression.clockTimeRegex.test(input) || TimeExpression.offsetTimeRegex.test(input));
			if (!validTimeExpression)
			{
				throw new SMPTETTException("Invalid time expression " + p_timeExpression);
			}
			
			if (input.indexOf(":")!=-1)
			{
				// its a clock-time
				m = input.match(TimeExpression.clockTimeRegex);
				
				hours = parseInt(m["hrs"]);
				minutes = parseInt(m["mins"]);
				seconds = parseInt(m["secs"]);
				if(m["subsecs"] && m["subsecs"].length>0)
				{
					subseconds = parseFloat("0" + m["subsecs"]);
					frames = Math.floor(framerate * subseconds);
				}
				if(m["frames"] && m["frames"].length>0)
				{
					frames = Math.floor(parseFloat(m["frames"]));
				}
				if (TimeExpression.CurrentSmpteFrameRate != SmpteFrameRate.UNKNOWN)
				{
					return new TimeCode(hours, minutes, seconds, frames, CurrentSmpteFrameRate);
				}
				else
				{
					return new TimeCode(hours, minutes, seconds, frames, framerate);
				}
			}
			else
			{
				// its a clock-time
				m = input.match(TimeExpression.offsetTimeRegex);
								
				// work out hours etc..
				var multiplier:Number = TimeExpression.getMetricMultiplier(m["units"], framerate, TimeExpression.CurrentTickRate) * 10000;
				var value:Number = parseFloat(m["value"]);
				
				// A tick is 100 nanosec (10^-7) of a second.
				// A millisecond is 1000 of a sec (10^-3)
				// A millisecond is 10000 ticks.
				var ms:Number = Math.floor(value * multiplier);
				//ms += (long)Math.Floor(subdigits * multiplier);
				//var newtime = new TimeSpan(ms);
				var newtime:TimeCode = new TimeCode(new TimeSpan(ms), framerate);
				return newtime;
			}
		}
		
		/**
		 * Returns the number needed to convert a time expression to milliseconds
		 * if the time expression is defined in times of a time metric
		 * 
		 * @param p_timeexpression
		 * @param p_framerate
		 * @param p_tickrate
		 */
		public static function getMetricMultiplier(p_timeexpression:String, p_framerate:Number, p_tickrate:Number):Number
		{
			if (p_timeexpression.indexOf("h")!=-1)
				return 1000 * 60 * 60;
			if (p_timeexpression.indexOf("ms")!=-1)
				return 1;
			if (p_timeexpression.indexOf("m")!=-1)
				return 1000 * 60;
			if (p_timeexpression.indexOf("s")!=-1)
				return 1000;
			if (p_timeexpression.indexOf("f")!=-1)
				return 1000 / p_framerate;
			if (p_timeexpression.indexOf("t")!=-1)
				return 1000 / p_tickrate;
			return 0;
		}
		
		/**
		 * Test the time parser. Not comprehensive at this point
		 */
		public static function UnitTests():Boolean
		{
			// reference is a 60 second timespan.
			// parse applies a default tickrate and framerate of 30 unless
			// otherwise specified.
			TimeExpression.initializeParameters();
			trace("reference: ");
			var reference:TimeCode = new TimeCode(new TimeSpan(0, 1, 00), TimeExpression.CurrentFrameRate);
			var pass:int = 1;
			
			trace('TimeExpression.parse("60s"): ');
			pass &= TimeExpression.parse("60s").equalTo(reference) as int;
			trace('TimeExpression.parse("1m"): ');
			pass &= TimeExpression.parse("1m").equalTo(reference) as int;
			trace('TimeExpression.parse("60000ms"): ');
			pass &= TimeExpression.parse("60000ms").equalTo(reference) as int;
			trace('TimeExpression.parse("1800f"): ');
			pass &= TimeExpression.parse("1800f").equalTo(reference) as int;
			TimeExpression.CurrentFrameRate = 10;
			trace('TimeExpression.parse("600f") @ 10fps: ');
			pass &= TimeExpression.parse("600f").equalTo(reference) as int;
			TimeExpression.CurrentFrameRate = 30;
			trace('TimeExpression.parse("00:01:00"): ');
			pass &= TimeExpression.parse("00:01:00").equalTo(reference) as int;
			trace('TimeExpression.parse("00:01:00:00"): ');
			pass &= TimeExpression.parse("00:01:00:00").equalTo(reference) as int;
			TimeExpression.CurrentFrameRate = 25;
			trace('TimeExpression.parse("00:00:59:25") @25fps: ');
			pass &= TimeExpression.parse("00:00:59:25").equalTo(reference) as int;
			
			TimeExpression.CurrentFrameRate = 30;
			reference = new TimeCode(new TimeSpan(1, 0, 0), TimeExpression.CurrentFrameRate);
			pass &=  TimeExpression.parse("3600s").equalTo(reference) as int;
			pass &=  TimeExpression.parse("01:00:00").equalTo(reference) as int;
			pass &=  TimeExpression.parse("00:59:60:00").equalTo(reference) as int;
			TimeExpression.CurrentFrameRate = 25;
			pass &=  TimeExpression.parse("00:59:59:25").equalTo(reference) as int;
			return Boolean((pass & 1) == 0);
		}
	}
}