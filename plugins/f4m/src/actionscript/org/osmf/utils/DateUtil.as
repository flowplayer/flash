/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.utils
{
	[ExcludeClass]

	/**
	* @private
	* 
	* 	Class that contains static utility methods for manipulating and working
	*	with Dates.
	* 
	* 	@langversion ActionScript 3.0
	*	@playerversion Flash 9.0
	*	@tiptext
	*  
	*  @langversion 3.0
	*  @playerversion Flash 10
	*  @playerversion AIR 1.5
	*  @productversion OSMF 1.0
	*/	
	public class DateUtil
	{
		/**
		* Parses dates that conform to the W3C Date-time Format into Date objects.
		*
		* This function is useful for parsing RSS 1.0 and Atom 1.0 dates.
		*
		* @param str
		*
		* @returns
		*
		* @langversion ActionScript 3.0
		* @playerversion Flash 9.0
		* @tiptext
		*
		* @see http://www.w3.org/TR/NOTE-datetime
		*  
		*  @langversion 3.0
		*  @playerversion Flash 10
		*  @playerversion AIR 1.5
		*  @productversion OSMF 1.0
		*/		     
		public static function parseW3CDTF(str:String):Date 
		{
			var parsedDate:Date = null;	
			try 
			{
				parsedDate = parseW3CDTFInternal(str);
			}
			catch (e:Error) 
			{
				throw new Error("Unable to parse the string [" + str + "] into a date. " + "The internal error was: " + e.toString());
			}
			
			return parsedDate;
		}
		
		// Internals
		//

		private static function parseW3CDTFInternal(dateStr:String):Date 
		{
			var expression:RegExp = /^ (\d\d\d\d) (?: - (\d\d) (?: - (\d\d) (?: T (\d\d) (?: : (\d\d) (?: : (\d\d (?: \.\d* )? ) )? )? )?  (?: Z | ([+-]) (\d\d) : (\d\d) )? )? )? $/x;
			
			if (!dateStr) 
			{
				throw new Error(PARSING_ERROR_STR);
			}

			var matches:Object = expression.exec(dateStr);
			
			if (!matches) 
			{
				throw new Error(PARSING_ERROR_STR);
			}
			
			function getMatch(matchNo:Number, minAllowedValue:Number, maxAllowedValue:Number):Number 
			{
				var match:String = matches[matchNo];
				if (!match) 
				{
					return minAllowedValue;
				}
				
				var matchValue:Number = Number(match);
				if (matchValue < minAllowedValue || matchValue > maxAllowedValue) 
				{
					throw new Error(PARSING_ERROR_STR);
				}
				
				return matchValue;
			}
			
			// get date components
			var year:Number = getMatch(GROUP_INDEX_YEAR, 0, 9999);
			var month:Number = getMatch(GROUP_INDEX_MONTH, 1, 12);
			var lastDayInCurrentMonth:Number = getLastDayInMonth(year, month);
			var day:Number = getMatch(GROUP_INDEX_DAY, 1, lastDayInCurrentMonth);
			var hour:Number = getMatch(GROUP_INDEX_HOUR, 0, 23);
			var minutes:Number = getMatch(GROUP_INDEX_MINUTE, 0, 59);
			var secondsAndMilliseconds:Number = getMatch(GROUP_INDEX_SECOND, 0, 59.99999999999);
			var seconds:Number =  Math.floor(secondsAndMilliseconds);
			var milliseconds:Number = Math.floor(secondsAndMilliseconds * 1000 % 1000);
			var tzSign:String = matches[GROUP_INDEX_TZ];
			var offsetMilliseconds:Number = 0;
			
			// get the timezone offset
			if (tzSign) 
			{
				var offsetHours:Number = getMatch(GROUP_INDEX_OFFSET_HOURS, 0, 23);
				var offsetMinutes:Number = getMatch(GROUP_INDEX_OFFSET_MINUTES, 0, 59);
				
				offsetMilliseconds = (offsetHours * 60 + offsetMinutes) * 60 * 1000;
				if (tzSign == '-')
				{
					offsetMilliseconds = offsetMilliseconds * -1;
				}
			}
			
			// convert the date to milliseconds and adjust it using the timezone offset
			var utc:Number = Date.UTC(year, month - 1, day, hour, minutes, seconds, milliseconds);
			var parsedDate:Date = new Date(utc - offsetMilliseconds);
			
			// check the parsed date validity
			if (parsedDate.toString() == "Invalid Date")
			{
				throw new Error(PARSING_ERROR_STR);
			}
			
			return parsedDate;
		}
		
		private static function getLastDayInMonth(year:Number, month:Number):Number
		{
			var dt:Date = new Date(year, month, 0);
			
			return dt.date;
		}
		
		private static const PARSING_ERROR_STR:String = "This date does not conform to W3CDTF.";
		
		private static const GROUP_INDEX_YEAR:Number = 1;
		private static const GROUP_INDEX_MONTH:Number = 2;
		private static const GROUP_INDEX_DAY:Number = 3;
		private static const GROUP_INDEX_HOUR:Number = 4;
		private static const GROUP_INDEX_MINUTE:Number = 5;
		private static const GROUP_INDEX_SECOND:Number = 6;
		private static const GROUP_INDEX_TZ:Number = 7;

        //flowplayer additions - fixes to type bug
		private static const GROUP_INDEX_OFFSET_HOURS:Number = 8;
		private static const GROUP_INDEX_OFFSET_MINUTES:Number = 9;
	}
}
