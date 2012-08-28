/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 *  The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 *  (the "License"); you may not use this file except in
 *  compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 **********************************************************/

package org.osmf.net
{
	import flash.net.NetStream;
	
	import org.osmf.net.PlaybackOptimizationManager;
	import org.osmf.net.PlaybackOptimizationMetrics;
	import org.osmf.player.configuration.PlayerConfiguration;
	
	public class MockPlaybackOptimizationManager extends PlaybackOptimizationManager
	{
		public function MockPlaybackOptimizationManager(configuration:PlayerConfiguration, metricsCreationFunction:Function)
		{
			super(configuration);	
			if (metricsCreationFunction != null)
			{
				this.metricsCreationFunction = metricsCreationFunction;
			}
		}
		
		override protected function createPlaybackOptimizationMetrics(netStream:NetStream):PlaybackOptimizationMetrics
		{
			if (metricsCreationFunction != null)
			{
				return metricsCreationFunction(netStream);
			}
			else
			{
				return new PlaybackOptimizationMetrics(netStream);
			}
		}
		
		// Internals
		//
		
		private var metricsCreationFunction:Function;
	}
}