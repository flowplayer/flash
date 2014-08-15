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
package org.osmf.net.httpstreaming
{
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	
	import org.osmf.net.ABRUtils;
	import org.osmf.net.NetStreamSwitcher;
	import org.osmf.net.RuleSwitchManagerBase;
	import org.osmf.net.metrics.MetricBase;
	import org.osmf.net.metrics.MetricRepository;
	import org.osmf.net.metrics.MetricType;
	import org.osmf.net.metrics.MetricValue;
	import org.osmf.net.qos.QualityLevel;
	import org.osmf.net.rules.Recommendation;
	import org.osmf.net.rules.RuleBase;
	
	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
		import org.osmf.logging.Log;
	}
	
	/**
	 * Default implementation of SwitchManagerBase
	 * 
	 *  @see org.osmf.net.abr.MetricBase
	 *  @see org.osmf.net.abr.RuleBase
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class DefaultHTTPStreamingSwitchManager extends RuleSwitchManagerBase
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
		 * @param normalRules Array of normal rules to be used in the algorithm.
		 *        A normal rule can recommend both lower and higher bitrates than the current one.
		 * @param normalRuleWeights The weights of the normal rules (their importance in the algorithm)
		 * @param minReliability The minimum reliability for a quality level to be used
		 * @param maxReliabilityRecordSize The maximum length of the reliability record (how many switches to remember)
		 * @param minReliabilityRecordSize The minimum length of the reliability record below which reliability is not an issue
		 * @param climbFactor A factor to be applied when switching up. For example:<br />
		 *        currently playing 300kbps; new ideal bitrate = 1000kbps<br />
		 *        This means that: max bitrate = 300 + climbFactor x (1000 - 300)
		 * @param maxUpSwitchLimit The maximum difference between the indices of the old and new quality level when switching up.
		 *        Set this to -1 to disable the constraint.
		 *        This works in conjunction with the reliability constraint. If no reliable stream is available inside the
		 *        maxUpSwitchLimit, no switch will be performed.
		 * @param maxDownSwitchLimit The maximum difference between the indices of the old and new quality level when switching down.
		 *        Set this to -1 value to disable the constraint.
		 *        This works in conjunction with the reliability constraint. If no reliable stream is available inside the
		 *        maxDownSwitchLimit, no switch will be performed. The maxDownSwitchLimit constraint does not apply to 
		 *        emergency switches.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function DefaultHTTPStreamingSwitchManager
			( notifier:EventDispatcher
			, switcher:NetStreamSwitcher
			, metricRepository:MetricRepository
			, emergencyRules:Vector.<RuleBase> = null
			, autoSwitch:Boolean = true
			, normalRules:Vector.<RuleBase> = null
			, normalRuleWeights:Vector.<Number> = null
			, minReliability:Number = 0.85
			, minReliabilityRecordSize:uint = 5
			, maxReliabilityRecordSize:uint = 30
			, climbFactor:Number = 0.9
			, maxUpSwitchLimit:int = 1
			, maxDownSwitchLimit:int = 2
			)
		{
			super(notifier, switcher, metricRepository, emergencyRules, autoSwitch);
			
			setNormalRules(normalRules);
			this.normalRuleWeights = normalRuleWeights;
			this.minReliability = minReliability;
			this.minReliabilityRecordSize = minReliabilityRecordSize;
			this.maxReliabilityRecordSize = maxReliabilityRecordSize;
			this.climbFactor = climbFactor;
			this.maxUpSwitchLimit = maxUpSwitchLimit;
			this.maxDownSwitchLimit = maxDownSwitchLimit;
			
			decisionHistory = new Vector.<Switch>();
			
			pushToHistory(currentIndex);
			
			availableQualityLevelsMetric = metricRepository.getMetric(MetricType.AVAILABLE_QUALITY_LEVELS);
			actualBitrateMetric = metricRepository.getMetric(MetricType.ACTUAL_BITRATE, ACTUAL_BITRATE_MAX_FRAGMENTS);
		}
		
		/**
		 * Array of normal rules to be used in the algorithm.
		 * A normal rule can recommend both lower and higher bitrates than the current one
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get normalRules():Vector.<RuleBase>
		{
			return _normalRules;
		}
		
		/**
		 * The weights of the normal rules (their importance in the algorithm).<br />
		 * Valid values must obey the following rules:
		 * <ul>
		 *  <li>same number of weights as there are rules</li>
		 *  <li>all rules must be equal or greater than zero</li>
		 *  <li>at least one weight must be non-zero</li>
		 * </ul> 
		 * 
		 * @throws ArgumentError If the weights are not valid, 
		 *         by breaking at least one of the above criteria
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get normalRuleWeights():Vector.<Number>
		{
			return _normalRuleWeights;
		}
		
		public function set normalRuleWeights(value:Vector.<Number>):void
		{
			ABRUtils.validateWeights(value, normalRules.length);
			
			_normalRuleWeights = value.slice();
		}
		
		/**
		 * The minimum reliability for a quality level to be used.
		 * This value must be a number in the [0-1] interval (inclusive)
		 * 
		 * @throws ArgumentError If it is set to an invalid value
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get minReliability():Number
		{
			return _minReliability;
		}
		
		public function set minReliability(value:Number):void
		{
			if (isNaN(value) || value < 0 || value > 1)
			{
				throw new ArgumentError("The minReliability must be a number between 0 and 1.");
			}
			_minReliability = value;
		}
		
		/**
		 * The minimum length of the reliability record below which reliability is not an issue
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get minReliabilityRecordSize():uint
		{
			return _minReliabilityRecordSize;
		}
		
		public function set minReliabilityRecordSize(value:uint):void
		{
			if (value < 2)
			{
				throw new ArgumentError("The minReliabilityRecordSize must be equal or greater than 2.");
			}
			_minReliabilityRecordSize = value;
		}
		
		/**
		 * The maximum length of the reliability record (how many switches to remember)
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get maxReliabilityRecordSize():uint
		{
			return _maxReliabilityRecordSize;
		}
		
		public function set maxReliabilityRecordSize(value:uint):void
		{
			if (value < minReliabilityRecordSize)
			{
				_maxReliabilityRecordSize = minReliabilityRecordSize;
				CONFIG::LOGGING
				{
					logger.warn("Cannot set the maxReliabilityRecordSize to a lower value than minReliabilityRecordSize. Setting it to " + minReliabilityRecordSize);
				}
			}
			else
			{
				_maxReliabilityRecordSize = value;
			}
		}
		
		/**
		 * A factor to be applied when switching up. For example:<br />
		 * currently playing 300kbps; new ideal bitrate = 1000kbps<br />
		 * This means that: max bitrate = 300 + climbFactor x (1000 - 300)
		 * <p>It must be equal or greater than 0</p>
		 * 
		 * @throws ArgumentError If it is set to a negative value
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get climbFactor():Number
		{
			return _climbFactor;
		}
		
		public function set climbFactor(value:Number):void
		{
			if (isNaN(value) || value <= 0)
			{
				throw new ArgumentError("The climbFactor must be a number greater than 0.");
			}
			
			_climbFactor = value;
		}
		
		
		/**
		 * <p>The maximum difference between the indices of the old 
		 * and new quality level when switching up.
		 * Set this to a -1 to disable the constraint.</p>
		 *
		 * <p>This works in conjunction with the reliability constraint. 
		 * If no reliable stream is available inside the
		 * maxUpSwitchLlimit, no switch will be performed.</p>
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get maxUpSwitchLimit():int
		{
			return _maxUpSwitchLimit;
		}
		
		public function set maxUpSwitchLimit(value:int):void
		{
			if (value < 1)
			{
				_maxUpSwitchLimit = -1;
			}
			else
			{
				_maxUpSwitchLimit = value;
			}
		}
		
		/**
		 * <p>The maximum difference between the indices of the old 
		 * and new quality level when switching down. 
		 * Set this to a -1 to disable the constraint.</p>
		 * 
		 * <p>This works in conjunction with the reliability constraint. 
		 * If no reliable stream is available inside the
		 * maxDownSwitchLimit, no switch will be performed.
		 * The maxDownSwitchLimit constraint does not apply to emergency switches.</p>
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function get maxDownSwitchLimit():int
		{
			return _maxDownSwitchLimit;
		}
		
		public function set maxDownSwitchLimit(value:int):void
		{
			if (value < 1)
			{
				_maxDownSwitchLimit = -1;
			}
			else
			{
				_maxDownSwitchLimit = value;
			}
		}

		/**
		 * The current reliability of the specified index.
		 * 
		 * @return A number between 0 (most unreliable) and 1 (most reliable)
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function getCurrentReliability(index:uint):Number
		{
			var downSwitchesFrom:uint = 0;
			var switchesFrom:uint = 0;
			for (var i:uint = 0; i < decisionHistory.length - 1; i++)
			{
				// Count all the switch decisions
				if (decisionHistory[i].index == index)
				{
					switchesFrom++;
					
					// Count all the down switches
					if (decisionHistory[i + 1].index < decisionHistory[i].index)
					{
						// If we switched down due to an emergency, than the quality level is unreliable
						if (decisionHistory[i + 1].emergency == true)
						{
							return 0;
						}
						
						downSwitchesFrom++;
					}
				}
			}
			
			if (decisionHistory.length < _minReliabilityRecordSize)
			{
				return Number.NaN;
			}
			
			if (switchesFrom == 0)
			{
				return Number.NaN;
			}
			
			if (downSwitchesFrom == 0)
			{
				return 1;
			}
			
			return 1 - (downSwitchesFrom * downSwitchesFrom) / (switchesFrom * (Math.floor(decisionHistory.length / 2)));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function getNewIndex():uint
		{
			var index:uint = 0;
			var q:QualityLevel;
			
			var top:Number = 0;
			var bottom:Number = 0;
			
			var availableQualityLevelsMetricValue:MetricValue = availableQualityLevelsMetric.value;
			if (!availableQualityLevelsMetricValue.valid)
			{
				throw new Error("The available quality levels metric should always be valid");
			}
			
			var availableBitrates:Vector.<QualityLevel> = availableQualityLevelsMetricValue.value;
			
			for (var i:uint = 0; i < normalRules.length; i++)
			{
				var rec:Recommendation = normalRules[i].getRecommendation();
				var factor:Number = rec.confidence * normalRuleWeights[i];
				
				top += rec.bitrate * factor;
				bottom += factor;
			}
			
			if (bottom == 0)
			{
				index = actualIndex;
				
				CONFIG::LOGGING
				{
					logger.info("No information from the rules. Recommeding actual index (currently downloading): " + index);
				}
			}
			else
			{
				var idealBitrate:Number = top / bottom;

				var currentActualBitrate:Number = getCurrentActualBitrate();
				
				// If the computed desired bitrate is higher than the current actual one
				// we take some precautions
				if (idealBitrate > currentActualBitrate)
				{
					idealBitrate = currentActualBitrate + _climbFactor * (idealBitrate - currentActualBitrate);
				}
				
				index = getMaxIndex(idealBitrate);
			
				CONFIG::LOGGING
				{
					logger.info("Ideal bitrate: " + ABRUtils.roundNumber(idealBitrate) + "; Chosen index: " + index);
				}
			}
			
			pushToHistory(index);
			
			return index;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function getNewEmergencyIndex(maxBitrate:Number):uint
		{
			var index:uint = getMaxIndex(maxBitrate, true);
			
			pushToHistory(index, index < actualIndex);
			
			return index;
		}
		
		/**
		 * Array of normal rules to be used in the algorithm.
		 * A normal rule can recommend both lower and higher bitrates than the current one.
		 * 
		 * @see #normalRules
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		protected function setNormalRules(value:Vector.<RuleBase>):void
		{
			if (value == null || value.length == 0)
			{
				throw new ArgumentError("You must provide at least one normal rule");
			}
			_normalRules = value.slice();
		}
		
		/**
		 * Determines maximum available index whose declared bitrate is smaller than maxBitrate. <br />
		 * Only reliable indices (indices that pass the <code>isReliable()</code> function) are taken into consideration.
		 * 
		 * @param maxBitrate The maximum bitrate to which the index must comply
		 * 
		 * @return The index satisfying the aforementioned condition
		 * 
		 * @see #isReliable()
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		protected function getMaxIndex(maxBitrate:Number, emergencyFlag:Boolean = false):uint
		{
			var availableQualityLevelsMetricValue:MetricValue = availableQualityLevelsMetric.value;
			
			if (!availableQualityLevelsMetricValue.valid)
			{
				throw new Error("The available quality levels metric should always be valid");
			}
			
			var availableBitrates:Vector.<QualityLevel> = availableQualityLevelsMetricValue.value;
			
			CONFIG::LOGGING
			{
				logger.debug("Determining the index of the highest quality rendition that has a bitrate smaller or equal than: " + maxBitrate + " kbps");
				logSwitchHistory();
				logReliabilities(availableBitrates);
			}
			
			var newQuality:QualityLevel = availableBitrates[0];
			
			// Determine the highest quality level below maxBitrate that is reliable
			
			for (var i:uint = 0; i < availableBitrates.length; i++)
			{
				var q:QualityLevel = availableBitrates[i];
				
				if (q.bitrate > newQuality.bitrate && q.bitrate <= maxBitrate && isReliable(q.index))
				{
					newQuality = q;
				}
			}
			
			CONFIG::LOGGING
			{
				logger.debug("The quality level before applying switch constraints: index = " + newQuality.index + "; bitrate = " + newQuality.bitrate + " kbps");
			}
			
			var newIndex:uint = newQuality.index;
			if (!emergencyFlag && newIndex != actualIndex)
			{
				// Validate that the desired quality level satisfies the switch constraints
				// because this is a normal switch to a different quality level
				
				if (newIndex > actualIndex)
				{
					// This is an up switch
					if (maxUpSwitchLimit > 0)
					{
						while ((newIndex - actualIndex > maxUpSwitchLimit || !isReliable(newIndex)) && newIndex > actualIndex)
						{
							newIndex--;
						}
					}
				}
				else
				{
					// This is a down switch
					if (maxDownSwitchLimit > 0)
					{
						while ((actualIndex - newIndex > maxDownSwitchLimit || !isReliable(newIndex)) && newIndex < actualIndex)
						{
							newIndex++;
						}
					}
				}
				
				newQuality = availableBitrates[newIndex];
			}
			
			CONFIG::LOGGING
			{
				logger.info("The index to be played is: " + newQuality.index + " (" + newQuality.bitrate + " kbps)");
			}
			
			return newQuality.index;
		}
		
		/**
		 * Determines whether an index is reliable.<br />
		 * This is achieved by comparing the index's reliability with the <b>minimumReliability</b>
		 * 
		 * @see #minimumReliability
		 * @see #getCurrentReliability()
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		protected function isReliable(index:uint):Boolean
		{
			var reliability:Number = getCurrentReliability(index);
			if (isNaN(reliability))
			{
				return true;
			}
			
			return (reliability > _minReliability);
		}
		
		private function getCurrentActualBitrate():Number
		{
			var currentActualBitrate:Number = 0;
			
			var availableQualityLevelsMetricValue:MetricValue = availableQualityLevelsMetric.value;
			if (!availableQualityLevelsMetricValue.valid)
			{
				throw new Error("The available quality levels metric should always be valid");
			}
			var availableBitrates:Vector.<QualityLevel> = availableQualityLevelsMetricValue.value;
			
			var actualBitrateMetricValue:MetricValue = actualBitrateMetric.value;
			
			// Determine the currently downloading quality level's actual bitrate
			if (actualBitrateMetricValue.valid)
			{
				currentActualBitrate = actualBitrateMetricValue.value as Number;
			}
			// If it's not available, we are satisfied with the current quality level's declared bitrate
			else
			{
				for each (var q:QualityLevel in availableBitrates)
				{
					if (q.index == actualIndex)
					{
						currentActualBitrate = q.bitrate;
					}
				}
			}
			
			return currentActualBitrate;
		}
		
		private function pushToHistory(index:uint, emergency:Boolean = false):void
		{
			var newSwitch:Switch = new Switch();
			newSwitch.index = index;
			newSwitch.emergency = emergency;
			
			decisionHistory.push(newSwitch);
			if (decisionHistory.length > _maxReliabilityRecordSize)
			{
				decisionHistory.shift();
			}
		}
		
		CONFIG::LOGGING
		{
			private function logSwitchHistory():void
			{
				var switchHistoryString:String = "";
				for (var i:uint = 0; i < decisionHistory.length; i++)
				{
					switchHistoryString += decisionHistory[i].index;
					if (decisionHistory[i].emergency)
					{
						switchHistoryString += " (emergency)";
					}
					
					switchHistoryString += " -> ";
				}
				
				logger.debug("Current switch history: " + switchHistoryString);
			}
			
			private function logReliabilities(availableBitrates:Vector.<QualityLevel>):void
			{
				logger.debug("Current reliabilities are:");
				for each (var q:QualityLevel in availableBitrates)
				{
					logger.debug(" Index: " + q.index + "; Bitrate: " + q.bitrate + " kbps; Reliability: " + getCurrentReliability(q.index));
				}
			}
		}
		
		private var _minReliability:Number;
		private var _maxReliabilityRecordSize:uint;
		private var _minReliabilityRecordSize:uint;
		private var _normalRuleWeights:Vector.<Number>;
		private var _climbFactor:Number;
		private var _maxUpSwitchLimit:int;
		private var _maxDownSwitchLimit:int;
		
		private var decisionHistory:Vector.<Switch>;
		private var availableQualityLevelsMetric:MetricBase;
		private var actualBitrateMetric:MetricBase;
		
		private var _normalRules:Vector.<RuleBase>;
		
		private static const ACTUAL_BITRATE_MAX_FRAGMENTS:uint = 10;
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.httpstreaming.DefaultHTTPStreamingSwitchManager");
		}
	}
}

class Switch
{
	public var index:uint = 0;
	public var emergency:Boolean = false;
}