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
package org.osmf.elements.f4mClasses
{
	import org.osmf.elements.f4mClasses.utils.F4MUtils;
	import org.osmf.events.ParseEvent;
	import org.osmf.utils.OSMFStrings;
	import org.osmf.utils.URL;

	[ExcludeClass]

	[Event(name="parseComplete", type="org.osmf.events.ParseEvent")]
	[Event(name="parseError", type="org.osmf.events.ParseEvent")]

	/**
	 * @private
	 *
	 * Parses BestEffortFetch info XML.
	 */
	public class BestEffortFetchInfoParser extends BaseParser
	{
		/**
		 * Constructor.
		 */
		public function BestEffortFetchInfoParser()
		{

		}

		/**
		 * @private
		 */
		override public function parse(value:String, baseURL:String=null, idPrefix:String = ""):void
		{
			var root:XML = new XML(value);
			
			if (!root)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_PARSE_VALUE_MISSING));
			}
			
			var majorVersion:Number = F4MUtils.getVersion(value).major as Number;
			
			var bestEffortFetchInfo:BestEffortFetchInfo = new BestEffortFetchInfo();
			
			var v:Number;
			
			// segmentDuration is mandatory
			if (root.attribute('segmentDuration').length() > 0)
			{
				v = Math.round(parseFloat(root.@segmentDuration) * 1000.0);
				if (isNaN(v) || v <= 0)
				{
					throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_PARSE_ERROR));
				}
				bestEffortFetchInfo.segmentDuration = uint(v);
			}
			else
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_PARSE_VALUE_MISSING));
			}
			
			// fragmentDuration is mandatory
			if (root.attribute('fragmentDuration').length() > 0)
			{
				v = Math.round(parseFloat(root.@fragmentDuration) * 1000.0);
				if (isNaN(v) || v <= 0)
				{
					throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_PARSE_ERROR));
				}
				bestEffortFetchInfo.fragmentDuration = uint(v);
			}
			else
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_PARSE_VALUE_MISSING));
			}
			
			// maxForwardFetches is optional
			if (root.attribute("maxForwardFetches").length() > 0)
			{
				v = parseInt(root.@maxForwardFetches);
				if (!isNaN(v) && v > 0)
				{
					// Only accept strictly positive integers
					bestEffortFetchInfo.maxForwardFetches = uint(v);
				}
			}
			
			// maxBackwardFetches is optional
			if (root.attribute("maxBackwardFetches").length() > 0)
			{
				v = parseInt(root.@maxBackwardFetches);
				if (!isNaN(v) && v >= 0)
				{
					// Only accept positive integers
					bestEffortFetchInfo.maxBackwardFetches = uint(v);
				}
			}
			
			finishLoad(bestEffortFetchInfo);
		}

		/**
		 * Finishes loading a parsed object.
		 *
		 * @param info The completed <code>BestEffortFetchnfo</code> object.
		 *
		 * @private
		 * In protected scope so that subclasses have an opportunity to do
		 * stuff before loading finishes.
		 */
		protected function finishLoad(info:BestEffortFetchInfo):void
		{
			dispatchEvent(new ParseEvent(ParseEvent.PARSE_COMPLETE, false, false, info));
		}
	}
}