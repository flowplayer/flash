/*****************************************************
 *  
 *  Copyright 2011 Adobe Systems Incorporated.  All Rights Reserved.
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
 *  Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems 
 *  Incorporated. All Rights Reserved. 
 *  
 *****************************************************/

/*
AdobePatentID="2278US01"
*/

package org.osmf.net
{
    import flash.errors.IllegalOperationError;
    import flash.events.EventDispatcher;

    import org.osmf.events.HTTPStreamingEvent;
    import org.osmf.net.metrics.MetricRepository;
    import org.osmf.net.rules.Recommendation;
    import org.osmf.net.rules.RuleBase;
    import org.osmf.utils.OSMFStrings;

    CONFIG::LOGGING
        {
        import org.osmf.logging.Log;
        import org.osmf.logging.Logger;
    }
	
	/**
	 * <p>SwitchManger manages the Adaptive Bitrate experience.<br />
	 * It is responsible with putting all the required components together.</p>
	 * 
	 *  @see org.osmf.net.abr.MetricBase
	 *  @see org.osmf.net.abr.RuleBase
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class RuleSwitchManagerBase extends NetStreamSwitchManagerBase
	{
		/**
		 * Constructor.
		 * 
		 * @param notifier An object that dispatches the HTTPStreamingEvent.RUN_ALGORITHM event
		 * @param switcher The NetStreamSwitcher to use for switching
		 * @param metricRepository The repository responsible with providing metrics
		 * @param emergencyRules Array of rules to be used in the algorithm.
		 *        An emergency rule can only recommend lower bitrates than the current one.
		 * @param autoSwitch Flag deciding whether autoSwitch should be enabled
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function RuleSwitchManagerBase
			( notifier:EventDispatcher
			, switcher:NetStreamSwitcher
			, metricRepository:MetricRepository
			, emergencyRules:Vector.<RuleBase> = null
			, autoSwitch:Boolean = true
			)
		{
			super();
			
			if (notifier == null)
			{
				throw new ArgumentError("Invalid netStream");
			}
			
			if (switcher == null)
			{
				throw new ArgumentError("Invalid switcher");
			}
			
			if (metricRepository == null)
			{
				throw new ArgumentError("Invalid metric repository");
			}
			
			this.notifier = notifier;
			this.switcher = switcher;
			_metricRepository = metricRepository;
			
			if (emergencyRules != null)
			{
				_emergencyRules = emergencyRules.slice();
			}
			
			this.autoSwitch = autoSwitch;
		}
		
		override public function set autoSwitch(value:Boolean):void
		{
			super.autoSwitch = value;
			
			if (value)
			{
				notifier.addEventListener(HTTPStreamingEvent.RUN_ALGORITHM, onRunAlgorithm);
			}
			else
			{
				notifier.removeEventListener(HTTPStreamingEvent.RUN_ALGORITHM, onRunAlgorithm);
			}
		}
		
		/**
		 * The index of the currently downloading quality level
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get actualIndex():int
		{
			return switcher.actualIndex;
		}
		
		/**
		 * The metric repository responsible with providing the metrics
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get metricRepository():MetricRepository
		{
			return _metricRepository;
		}
		
		/**
		 * Array of normal rules to be used in the algorithm.
		 * An emergency rule can only recommend lower bitrates than the current one.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get emergencyRules():Vector.<RuleBase>
		{
			return _emergencyRules;
		}

		/**
		 * Computes the necessary rules and metrics and determines the index to switch to.
		 * The index must be a valid one (it can be higher than maxAllowedIndex, but it should be
		 * a real index that is available)
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function getNewIndex():uint
		{
			throw new IllegalOperationError("The getNewIndex() function must be overriden by the subclass.");
		}
		
		/**
		 * Returns an index that satisfies the maxBitrate constraint
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function getNewEmergencyIndex(maxBitrate:Number):uint
		{
			throw new IllegalOperationError("The getNewEmergencyIndex() function must be overriden by the subclass.");
		}
		
		override public function get currentIndex():uint
		{
			return switcher.currentIndex;
		}

        //flowplayer addition - set the current index
        override public function set currentIndex(index:uint):void {
            switcher.currentIndex = index;
        }
		
		override public function switchTo(index:int):void
		{
			if (!_autoSwitch)
			{
				if (index < 0 || index > maxAllowedIndex)
				{
					throw new RangeError(OSMFStrings.getString(OSMFStrings.STREAMSWITCH_INVALID_INDEX));
				}
				else
				{
					CONFIG::LOGGING
					{
						logger.debug("switchTo() - manually switching to index: " + index);
					}
					
					switcher.switchTo(index);
				}
			}
			else
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.STREAMSWITCH_STREAM_NOT_IN_MANUAL_MODE));
			}
		}
		
		private function onRunAlgorithm(event:HTTPStreamingEvent):void
		{
			var minEmergencyBitrate:Number = Number.POSITIVE_INFINITY;
			
			for each (var rule:RuleBase in _emergencyRules)
			{
				var rec:Recommendation = rule.getRecommendation();

				// Only consider rules that are sure
				if (rec.confidence == 1)
				{
					minEmergencyBitrate = rec.bitrate;
				}
			}
			
			var newIndex:uint = 0;
			
			if (minEmergencyBitrate < Number.POSITIVE_INFINITY)
			{
				newIndex = getNewEmergencyIndex(minEmergencyBitrate);
			}
			else
			{
				newIndex = getNewIndex();
			}
			
			// if the rules recommended a new bitrate index
			// then make sure we respect the maximum allowed index
			if (newIndex != switcher.actualIndex)
			{
				newIndex = Math.min(newIndex, maxAllowedIndex);
			}
			// if no change was recommended then make sure that
			// the current index is still respecting the maximum 
			// allowed index
			else
			{
				if (switcher.actualIndex > maxAllowedIndex)
				{
					newIndex = maxAllowedIndex;
				}
			}
			
			// The newIndex may have been changed due to the previous conditions
			// Check that it's still different than the actual index and that 
			// the switcher isn't switching at the moment
			if (newIndex != switcher.actualIndex && !switcher.switching)
			{
				CONFIG::LOGGING
				{
					logger.info("Automatically switching to new index: " + newIndex);
				}
				
				switcher.switchTo(newIndex);
			}
		}

		private var _metricRepository:MetricRepository;
		private var _emergencyRules:Vector.<RuleBase> = null;
		private var switcher:NetStreamSwitcher;
		private var notifier:EventDispatcher;
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.RuleSwitchManagerBase");
		}
	}
}