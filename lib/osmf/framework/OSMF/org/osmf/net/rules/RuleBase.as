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
package org.osmf.net.rules
{
	import flash.errors.IllegalOperationError;
	
	import org.osmf.net.metrics.MetricRepository;

	/**
	 * <p>RuleBase is a base class for rules used for Adaptive Bitrate.<br />
	 * A rule recommends a bitrate to the switch manager and a 
	 * confidence in the recommended bitrate.<br />
	 * A rule's value is computed based on the values of the metrics.</p>
	 * 
	 *  @see org.osmf.net.abr.Recommendation
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 2.0
	 */
	public class RuleBase
	{
		/**
		 * Constructor.
		 * 
		 * @param metricRepository The metric repository from which to retrieve the necessary metrics
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function RuleBase(metricRepository:MetricRepository)
		{
			_metricRepository = metricRepository;
		}
		
		/**
		 * The metric repository. Required metrics are obtained from it.
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
		 * Returns the recommendation of this rule
		 * (ideal bitrate, confidence, weight)
		 * <br />
		 * Subclasses must implement this method.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 2.0
		 */
		public function getRecommendation():Recommendation
		{
			throw new IllegalOperationError("The getRecommendation() method must be overridden by the derived class.");
		}

		protected var _metricRepository:MetricRepository;
	}
}