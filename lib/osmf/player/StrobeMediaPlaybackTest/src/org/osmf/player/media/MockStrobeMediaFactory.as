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
 * 
 **********************************************************/

package org.osmf.player.media
{
	import flash.sampler.NewObjectSample;
	
	import org.osmf.net.MockHTTPStreamingNetLoaderAdapter;
	import org.osmf.net.MockPlaybackOptimizationManager;
	import org.osmf.net.MockRTMPDynamicStreamingNetLoaderAdapter;
	import org.osmf.net.NetLoader;
	import org.osmf.net.PlaybackOptimizationManager;
	import org.osmf.player.configuration.PlayerConfiguration;

	public class MockStrobeMediaFactory extends StrobeMediaFactory
	{	
		public var rtmpDynamicStreamingNetLoaderAdapterCount:int = 0;
		public var playbackOptimizationManagerCount:int = 0;
		public var httpStreamingNetLoaderAdapter:int = 0;
		
		public function MockStrobeMediaFactory(configuration:PlayerConfiguration)
		{
			super(configuration);
		}
		
		// Protected
		//
		
		override protected function createPlaybackOptimizationManager(configuration:PlayerConfiguration):PlaybackOptimizationManager
		{
			playbackOptimizationManagerCount ++;
			return new MockPlaybackOptimizationManager(configuration, null);
		}
		
		override protected function createRTMPDynamicStreamingNetLoaderAdapter(playbackOptimizationManager:PlaybackOptimizationManager):NetLoader
		{
			rtmpDynamicStreamingNetLoaderAdapterCount ++;
			return new MockRTMPDynamicStreamingNetLoaderAdapter(playbackOptimizationManager);
		}
		CONFIG::FLASH_10_1
		{
		override protected function createHTTPStreamingNetLoaderAdapter(playbackOptimizationManager:PlaybackOptimizationManager):NetLoader
		{
			httpStreamingNetLoaderAdapter ++;
			return new MockHTTPStreamingNetLoaderAdapter(playbackOptimizationManager);
		}
		}
	}
}