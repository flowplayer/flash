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
	import org.osmf.smpte.tt.utilities.IComparable;
	import org.osmf.smpte.tt.utilities.IEquals;
	import org.osmf.smpte.tt.utilities.StringUtils;

	/**
	 * Represents an interval of time 
	 */     
	public class TimeSpan implements IComparable, IEquals
	{
		protected var _value:Number;
		
		// Constructors.
		public function TimeSpan(...args)
		{
			switch(args.length)
			{
				case 1:
					_value = args[0];
					break;
				case 3:
					// this(0, args[0], args[1], args[2], 0);
					args.unshift(0);
				case 4:
					// this(args[0], args[1], args[2], args[3], 0);
					args.push(0);
				case 5:
					try
					{
						_value = args[0] * TimeSpan.TICKS_PER_DAY +
							args[1] * TimeSpan.TICKS_PER_HOUR +
							args[2] * TimeSpan.TICKS_PER_MINUTE +
							args[3] * TimeSpan.TICKS_PER_SECOND +
							args[4] * TimeSpan.TICKS_PER_MILLISECOND;
					} catch(err:RangeError)
					{
						throw new RangeError("TimeSpan argument out of range");
					}
					break;
			}
		}
		
		/**
		 * Compares this TimeSpan with the specified TimeSpan for order. Returns a negative integer, zero, or a positive
		 * integer as this TimeSpan is less than, equal to, or greater than the specified TimeSpan.
		 *
		 * @param  the other TimeSpan to be compared
		 * @return a negative integer, zero, or a positive integer as this TimeSpan is less than, equal to, or greater than the specified TimeSpan.
		 */
		public function compareTo(p_value:Object):int 
		{
			if(p_value!=null)
			{
				if(!(p_value is TimeSpan)) {
					throw new ArgumentError("object must TimeSpan for comparison");
				}
				var value2:Number = TimeSpan(p_value)._value;
				if(_value<value2){
					return -1;
				} else if(_value==value2){
					return 0;
				} else if(_value>value2){
					return 1;
				}
			}
			return 1;
		}
		
		// Convert an integer value into two digits.
		private static function twoDigits(p_value:int):String
		{
			var result:Array = [];
			result[0] = ((p_value / 10) + int('0')).toString(16);
			result[1] = ((p_value % 10) + int('0')).toString(16);
			return result.join('');
		}
		
		public function toString():String
		{
			var d:int = Math.abs(days),
				h:int = Math.abs(hours),
				m:int = Math.abs(minutes),
				s:int = Math.abs(seconds),
				fractional:int =Math.abs(_value) % TICKS_PER_SECOND,
				result:String;
			
			if(_value<0)
			{
				result="-";
			}else
			{
				result = "";
			}
			
			if(d != 0)
			{
				result += String(d)+ ".";
			}
			
			result = result +
				twoDigits(h) + ":" +
				twoDigits(m) + ":" + 
				twoDigits(s);
			if(fractional != 0)
			{
				var test:int = (TICKS_PER_SECOND / 10);
				var digit:int;
				result = result + ".";
				while(fractional != 0)
				{
					digit = fractional / test;
					result = result + (digit + int('0')).toString(16);
					fractional %= test;
					test /= 10;
				}
			}
			return result;
		}
		
		/**
		 * Add a given TimeSpan to another
		 */
		public function add(ts:TimeSpan):TimeSpan 
		{
			return new TimeSpan(_value + ts._value);
		}
		
		/**
		 * Add a given TimeSpan to another
		 */
		public function plus(ts:TimeSpan):TimeSpan 
		{
			return this.add(ts);
		}
		
		/**
		 * Compare two TimeSpan values.
		 *
		 * @param t1 the first TimeSpan to compare
		 * @param t2 the second TimeSpan to compare
		 */
		public static function Compare(t1:TimeSpan, t2:TimeSpan):int
		{
			if(t1._value < t2._value)
			{
				return -1;
			}
			else if(t1._value > t2._value)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
		
		/**
		 * Return the absolute duration of a TimeSpan value.
		 */ 
		public function duration():TimeSpan
		{
			return new TimeSpan(Math.abs(_value));
		}
		
		/**
		 * Tests equality for TimeSpan values
		 *
		 * @param p_value the TimeSpan to compare to this TimeSpan for equality
		 */
		public function equals(p_value:Object):Boolean 
		{
			if(p_value!=null)
			{
				if(!(p_value is TimeSpan)) {
					throw new SMPTETTException("object must TimeSpan for comparison");
				}
				var value2:Number = TimeSpan(p_value)._value;
				return Boolean(_value==value2);
			} else
			{
				return false;	
			}
		}
		
		/**
		 * Determine if two TimeSpan values are equal.
		 * 
		 * @param t1 the first TimeSpan to compare
		 * @param t2 the second TimeSpan to compare
		 */ 
		public static function Equals(t1:TimeSpan, t2:TimeSpan):Boolean
		{
			return (t1._value == t2._value);
		}
		
		/**
		 * Creates a TimeSpan from the specified number of days
		 * @param value The number of days in the timespan
		 * @return A TimeSpan that represents the specified value
		 */ 
		public static function fromDays(value:Number):TimeSpan
		{
			if(isNaN(value))
			{
				throw new ArgumentError(value + " is not a number");
			}
			else if(value == Number.NEGATIVE_INFINITY)
			{
				return TimeSpan.MAX_VALUE;
			}
			else if(value == Number.POSITIVE_INFINITY)
			{
				return TimeSpan.MIN_VALUE;
			}
			return new TimeSpan(value * TimeSpan.TICKS_PER_DAY);
		}
		
		/**
		 * Creates a TimeSpan from the specified number of hours
		 * @param value The number of hours in the timespan
		 * @return A TimeSpan that represents the specified value
		 */  
		public static function fromHours(value:Number):TimeSpan
		{
			if(isNaN(value))
			{
				throw new ArgumentError(value + " is not a number");
			}
			else if(value == Number.NEGATIVE_INFINITY)
			{
				return TimeSpan.MAX_VALUE;
			}
			else if(value == Number.POSITIVE_INFINITY)
			{
				return TimeSpan.MIN_VALUE;
			}
			return new TimeSpan(value * TimeSpan.TICKS_PER_HOUR);
		}
		
		/**
		 * Creates a TimeSpan from the specified number of milliseconds
		 * @param value The number of milliseconds in the timespan
		 * @return A TimeSpan that represents the specified value
		 */  
		public static function fromMilliseconds(value:Number):TimeSpan
		{
			if(isNaN(value))
			{
				throw new ArgumentError(value + " is not a number");
			}
			else if(value == Number.NEGATIVE_INFINITY)
			{
				return TimeSpan.MAX_VALUE;
			}
			else if(value == Number.POSITIVE_INFINITY)
			{
				return TimeSpan.MIN_VALUE;
			}
			return new TimeSpan(value * TimeSpan.TICKS_PER_MILLISECOND);
		}
		
		/**
		 * Creates a TimeSpan from the specified number of minutes
		 * @param value The number of minutes in the timespan
		 * @return A TimeSpan that represents the specified value
		 */  
		public static function fromMinutes(value:Number):TimeSpan
		{
			if(isNaN(value))
			{
				throw new ArgumentError(value + " is not a number");
			}
			else if(value == Number.NEGATIVE_INFINITY)
			{
				return TimeSpan.MAX_VALUE;
			}
			else if(value == Number.POSITIVE_INFINITY)
			{
				return TimeSpan.MIN_VALUE;
			}
			return new TimeSpan(value * TimeSpan.TICKS_PER_MINUTE);
		}
		
		/**
		 * Creates a TimeSpan from the specified number of seconds
		 * @param value The number of seconds in the timespan
		 * @return A TimeSpan that represents the specified value
		 */ 
		public static function fromSeconds(value:Number):TimeSpan
		{
			if(isNaN(value))
			{
				throw new ArgumentError(value + " is not a number");
			}
			else if(value == Number.NEGATIVE_INFINITY)
			{
				return TimeSpan.MAX_VALUE;
			}
			else if(value == Number.POSITIVE_INFINITY)
			{
				return TimeSpan.MIN_VALUE;
			}
			return new TimeSpan(value * TimeSpan.TICKS_PER_SECOND);
		}
		
		/**
		 * Creates a TimeSpan from the specified number of ticks
		 * @param ticks The number of ticks in the timespan
		 * @return A TimeSpan that represents the specified value
		 */ 
		public static function fromTicks(ticks:Number):TimeSpan
		{
			return new TimeSpan(ticks);
		}
		
		/**
		 * Get the hash code for this instance.
		 */
		public function getHashCode():int
		{
			return (_value ^ (_value >> 16));
		}
		
		/**
		 * Negate a TimeSpan value.
		 */
		public function negate():TimeSpan
		{
			if(_value != Number.MIN_VALUE)
			{
				return new TimeSpan(-_value);
			}
			else
			{
				throw new Error("Overflow_NegateTwosCompNum");
			}
		}
		
		/**
		 * Parse a string into a TimeSpan value.
		 */
		public static function parse(p_expression:String):TimeSpan
		{
			var numberofticks:Number = 0;
			var d:int = 0,
				h:int,
				m:int,
				s:int,
				fractions:Number,
				fractionslength:int = 0,
				fractionss:String = '',
				tempstringarray:Array,
				minus:Boolean = false;
			
			//Precheck for null reference
			if (p_expression == null)
			{
				throw new ArgumentError("p_expression must not be null");
			}
			
			try
			{
				
				//Cut of whitespace and check for minus specifier 
				p_expression = StringUtils.trim(p_expression);
				minus = (p_expression.indexOf("-") == 0);
				
				//Get days if present
				if ((p_expression.indexOf(".") < p_expression.indexOf(":")) && (p_expression.indexOf(".") != -1))
				{
					d = Math.abs(parseInt(p_expression.substring(0, p_expression.indexOf("."))));
					p_expression = p_expression.substring(p_expression.indexOf(".") + 1);
				}
				
				//Get fractions if present
				if ((p_expression.indexOf(".") > p_expression.indexOf(":")) && (p_expression.indexOf(".") != -1))
				{
					fractionss = p_expression.substring(p_expression.indexOf(".") + 1);
					fractionslength = fractionss.length;
					p_expression = p_expression.substring(0, p_expression.indexOf("."));
				}
				
				//Parse the hh:mm:ss string
				tempstringarray = p_expression.split(':');
				h = parseInt(tempstringarray[0]);
				m = parseInt(tempstringarray[1]);
				s = parseInt(tempstringarray[2]);
				
				
			}
			catch(err:Error)
			{
				err.message = "Exception_Format";
				throw err;
			}
			
			//Check for overflows
			if ( ((h > 23) || (h < 0)) ||
				((m > 59) || (m < 0)) ||
				((s > 59) || (s < 0)) ||
				((fractionslength > 7) || (fractionslength < 1)) )
			{
				throw new RangeError("Arg_DateTimeRange");
			}
			
			//Calculate the fractions expressed in a second
			if(fractionss != '')
			{
				fractions = parseInt(fractionss) * TICKS_PER_SECOND;
				while(fractionslength > 0)
				{
					fractions /= 10;
					--fractionslength;
				}
			}
			else
			{
				fractions = 0;
			}
			
			//Calculate the numberofticks
			numberofticks += (d * TICKS_PER_DAY);
			numberofticks += (h * TICKS_PER_HOUR);
			numberofticks += (m * TICKS_PER_MINUTE);
			numberofticks += (s * TICKS_PER_SECOND);
			numberofticks += fractions;
			
			//Apply the minus specifier
			if (minus == true) numberofticks = 0 - numberofticks;
			
			//Last check
			if ((numberofticks < TimeSpan.MIN_VALUE.ticks) || (numberofticks > TimeSpan.MAX_VALUE.ticks))
			{
				throw new RangeError("Arg_DateTimeRange");
			}
			
			//Return
			return new TimeSpan(numberofticks);
		}
		/**
		 * Subtract TimeSpan values.
		 */
		public function subtract(ts:TimeSpan):TimeSpan
		{
			return new TimeSpan((_value - ts._value));
		}
		
		/**
		 * Subtract a given TimeSpan from another.
		 */
		public function minus(ts:TimeSpan):TimeSpan
		{
			return this.subtract(ts);
		}
		
		/**
		 * Gets the number of whole days
		 * 
		 * @example In a TimeSpan created from TimeSpan.fromHours(25), 
		 *                      totalHours will be 1.04, but hours will be 1 
		 * @return A number representing the number of whole days in the TimeSpan
		 */
		public function get days():int
		{
			return int(_value / TICKS_PER_DAY);
		}
		
		/**
		 * Gets the number of whole hours (excluding entire days)
		 * 
		 * @example In a TimeSpan created from TimeSpan.fromMinutes(1500), 
		 *                      totalHours will be 25, but hours will be 1 
		 * @return A number representing the number of whole hours in the TimeSpan
		 */
		public function get hours():int
		{
			return int(_value / TICKS_PER_HOUR) % 24;
		}
		
		/**
		 * Gets the number of whole minutes (excluding entire hours)
		 * 
		 * @example In a TimeSpan created from TimeSpan.fromMilliseconds(65500), 
		 *                      totalSeconds will be 65.5, but seconds will be 5 
		 * @return A number representing the number of whole minutes in the TimeSpan
		 */
		public function get minutes():int
		{
			return int(_value / TICKS_PER_MINUTE) % 60; 
		}
		
		/**
		 * Gets the number of whole seconds (excluding entire minutes)
		 * 
		 * @example In a TimeSpan created from TimeSpan.fromMilliseconds(65500), 
		 *                      totalSeconds will be 65.5, but seconds will be 5 
		 * @return A number representing the number of whole seconds in the TimeSpan
		 */
		public function get seconds():int
		{
			return int(_value / TICKS_PER_SECOND) % 60;
		}
		
		/**
		 * Gets the number of whole milliseconds (excluding entire seconds)
		 * 
		 * @example In a TimeSpan created from TimeSpan.fromMilliseconds(2123), 
		 *                      totalMilliseconds will be 2001, but milliseconds will be 123 
		 * @return A number representing the number of whole milliseconds in the TimeSpan
		 */
		public function get milliseconds():int
		{
			return int(_value / TICKS_PER_MILLISECOND) % 1000;
		}
		
		/**
		 * Gets the number of ticks
		 * 
		 * @return A number representing the number of ticks in the TimeSpan
		 */
		public function get ticks():Number
		{
			return _value;
		}
		
		/**
		 * Gets the total number of days.
		 * 
		 * @example In a TimeSpan created from TimeSpan.fromHours(25), 
		 *                      totalHours will be 1.04, but hours will be 1 
		 * @return A number representing the total number of days in the TimeSpan
		 */
		public function get totalDays():Number
		{
			return _value / TICKS_PER_DAY;
		}
		
		/**
		 * Gets the total number of hours.
		 * 
		 * @example In a TimeSpan created from TimeSpan.fromMinutes(1500), 
		 *                      totalHours will be 25, but hours will be 1 
		 * @return A number representing the total number of hours in the TimeSpan
		 */
		public function get totalHours():Number
		{
			return _value / TICKS_PER_HOUR;
		}
		
		/**
		 * Gets the total number of minutes.
		 * 
		 * @example In a TimeSpan created from TimeSpan.fromMilliseconds(65500), 
		 *                      totalSeconds will be 65.5, but seconds will be 5 
		 * @return A number representing the total number of minutes in the TimeSpan
		 */
		public function get totalMinutes():Number
		{
			return _value / TICKS_PER_MINUTE;
		}
		
		/**
		 * Gets the total number of seconds.
		 * 
		 * @example In a TimeSpan created from TimeSpan.fromMilliseconds(65500), 
		 *                      totalSeconds will be 65.5, but seconds will be 5 
		 * @return A number representing the total number of seconds in the TimeSpan
		 */
		public function get totalSeconds():Number
		{
			return _value / TICKS_PER_SECOND;
		}
		
		/**
		 * Gets the total number of milliseconds.
		 * 
		 * @example In a TimeSpan created from TimeSpan.fromMilliseconds(2123), 
		 *                      totalMilliseconds will be 2001, but milliseconds will be 123 
		 * @return A number representing the total number of milliseconds in the TimeSpan
		 */
		public function get totalMilliseconds():Number
		{
			var temp:Number = _value / TICKS_PER_MILLISECOND;
			
			if(temp > 922337203685477.0)
			{
				return 922337203685477.0;
			}
			else if(temp < -922337203685477.0)
			{
				return -922337203685477.0;
			}
			return temp;
		}
		
		/**
		 * Adds the timespan represented by this instance to the date provided and returns a new date object.
		 * @param date The date to add the timespan to
		 * @return A new Date with the offseted time
		 */             
		public function addDate(date:Date):Date
		{
			var temp:Date = new Date(date.time);
			temp.milliseconds += totalMilliseconds;
			
			return temp;
		}
		
		/**
		 * Creates a TimeSpan from the different between two dates
		 * 
		 * Note that start can be after end, but it will result in negative values. 
		 *  
		 * @param start The start date of the timespan
		 * @param end The end date of the timespan
		 * @return A TimeSpan that represents the difference between the dates
		 * 
		 */             
		public static function fromDates(start:Date, end:Date):TimeSpan
		{
			return new TimeSpan((end.time - start.time) * TICKS_PER_MILLISECOND);
		}
		
		/**
		 * The number of milliseconds in one day
		 */     
		public static const MILLISECONDS_PER_DAY:Number = 86400000;
		
		/**
		 * The number of milliseconds in one hour
		 */     
		public static const MILLISECONDS_PER_HOUR:Number = 3600000;
		
		/**
		 * The number of milliseconds in one minute
		 */     
		public static const MILLISECONDS_PER_MINUTE:Number = 60000;
		
		/**
		 * The number of milliseconds in one second
		 */     
		public static const MILLISECONDS_PER_SECOND:Number = 1000;
		
		/**
		 * The number of ticks in one millisecond
		 */ 
		public static const TICKS_PER_MILLISECOND:Number = 10000;
		
		/**
		 * The number of ticks in one second
		 */
		public static const TICKS_PER_SECOND:Number = 10000000;
		
		/**
		 * The number of ticks in one minute
		 */
		public static const TICKS_PER_MINUTE:Number = 600000000;
		
		/**
		 * The number of ticks in one hour
		 */
		public static const TICKS_PER_HOUR:Number = 36000000000;
		
		/**
		 * The number of ticks in one day
		 */
		public static const TICKS_PER_DAY:Number = 864000000000;

		public static const MIN_VALUE:TimeSpan = new TimeSpan(-0x8000000000000000);
		public static const MAX_VALUE:TimeSpan = new TimeSpan(0x7FFFFFFFFFFFFFFF);
		public static const ZERO:TimeSpan = new TimeSpan(0);
	}
}