/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
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
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package
{
	import org.osmf.containers.TestHTMLMediaContainer;
	import org.osmf.containers.TestMediaContainer;
	import org.osmf.events.TestMediaError;
	import org.osmf.events.TestMediaErrorAsSubclass;
	import org.osmf.layout.TestAbsoluteLayoutMetadata;
	import org.osmf.layout.TestAnchorLayoutMetadata;
	import org.osmf.layout.TestBinarySearch;
	import org.osmf.layout.TestBoxAttributesMetadata;
	import org.osmf.layout.TestGenericLayout;
	import org.osmf.layout.TestLayoutAttributesMetadata;
	import org.osmf.layout.TestLayoutMetadata;
	import org.osmf.layout.TestLayoutRenderer;
	import org.osmf.layout.TestLayoutRendererBase;
	import org.osmf.layout.TestLayoutTargetEvent;
	import org.osmf.layout.TestLayoutTargetRenderers;
	import org.osmf.layout.TestLayoutTargetSprite;
	import org.osmf.layout.TestMediaElementLayoutTarget;
	import org.osmf.layout.TestOverlayLayoutMetadata;
	import org.osmf.layout.TestPaddingLayoutMetadata;
	import org.osmf.layout.TestRelativeLayoutMetadata;
	import org.osmf.layout.TestScaleModeUtils;
	import org.osmf.logging.TestLog;
	import org.osmf.media.MediaTraitResolverBaseTestCase;
	import org.osmf.media.TestDefaultMediaFactory;
	import org.osmf.media.TestDefaultTraitResolver;
	import org.osmf.media.TestLoadableElementBase;
	import org.osmf.media.TestMediaElement;
	import org.osmf.media.TestMediaElementAsSubclass;
	import org.osmf.media.TestMediaFactory;
	import org.osmf.media.TestMediaFactoryItem;
	import org.osmf.media.TestMediaPlayer;
	import org.osmf.media.TestMediaPlayerSprite;
	import org.osmf.media.TestMediaPlayerWithAudioElement;
	import org.osmf.media.TestMediaPlayerWithAudioElementWithSoundLoader;
	import org.osmf.media.TestMediaPlayerWithBeaconElement;
	import org.osmf.media.TestMediaPlayerWithDurationElement;
	import org.osmf.media.TestMediaPlayerWithDynamicStreamingVideoElement;
	import org.osmf.media.TestMediaPlayerWithDynamicStreamingVideoElementSubclip;
	import org.osmf.media.TestMediaPlayerWithLightweightVideoElement;
	import org.osmf.media.TestMediaPlayerWithProxyElement;
	import org.osmf.media.TestMediaPlayerWithSerialElementWithDurationElements;
	import org.osmf.media.TestMediaPlayerWithVideoElement;
	import org.osmf.media.TestMediaPlayerWithVideoElementSubclip;
	import org.osmf.media.TestMediaTraitResolver;
	import org.osmf.media.TestMediaType;
	import org.osmf.media.TestMediaTypeUtil;
	import org.osmf.media.TestPluginInfo;
	import org.osmf.media.TestURLResource;
	import org.osmf.media.pluginClasses.TestDynamicPluginLoader;
	import org.osmf.media.pluginClasses.TestPluginElement;
	import org.osmf.media.pluginClasses.TestPluginLoadingState;
	import org.osmf.media.pluginClasses.TestPluginManager;
	import org.osmf.media.pluginClasses.TestStaticPluginLoader;
	import org.osmf.metadata.TestCuePoint;
	import org.osmf.metadata.TestMetadata;
	import org.osmf.metadata.TestMetadataWatcher;
	import org.osmf.metadata.TestTimelineMarker;
	import org.osmf.metadata.TestTimelineMetadata;
	import org.osmf.net.TestDynamicStreamingItem;
	import org.osmf.net.TestDynamicStreamingResource;
	import org.osmf.net.TestSwitchManager;
	import org.osmf.net.drm.TestDRMServices;
	import org.osmf.net.metrics.TestActualBitrateMetric;
	import org.osmf.net.metrics.TestAvailableQualityLevelsMetric;
	import org.osmf.net.metrics.TestBandwidthMetric;
	import org.osmf.net.metrics.TestBufferFragmentsMetric;
	import org.osmf.net.metrics.TestBufferLengthMetric;
	import org.osmf.net.metrics.TestBufferOccupationRatioMetric;
	import org.osmf.net.metrics.TestCurrentStatusMetric;
	import org.osmf.net.metrics.TestDefaultMetricFactory;
	import org.osmf.net.metrics.TestDroppedFPSMetric;
	import org.osmf.net.metrics.TestEmptyBufferInterruptionMetric;
	import org.osmf.net.metrics.TestFPSMetric;
	import org.osmf.net.metrics.TestFragmentCountMetric;
	import org.osmf.net.metrics.TestMetricBase;
	import org.osmf.net.metrics.TestMetricFactory;
	import org.osmf.net.metrics.TestMetricFactoryItem;
	import org.osmf.net.metrics.TestMetricRepository;
	import org.osmf.net.metrics.TestMetricValue;
	import org.osmf.net.metrics.TestRecentSwitchMetric;
	import org.osmf.net.qos.TestQoSInfoHistory;
	import org.osmf.net.rules.TestAfterUpSwitchBufferBandwidthRule;
	import org.osmf.net.rules.TestBandwidthRule;
	import org.osmf.net.rules.TestBufferBandwidthRule;
	import org.osmf.net.rules.TestDroppedFPSRule;
	import org.osmf.net.rules.TestEmptyBufferRule;
	import org.osmf.net.rules.TestRecommendation;
	import org.osmf.net.rules.TestRuleUtils;
	import org.osmf.traits.TestAudioTrait;
	import org.osmf.traits.TestBufferTrait;
	import org.osmf.traits.TestBufferTraitAsSubclass;
	import org.osmf.traits.TestDRMTrait;
	import org.osmf.traits.TestDVRTrait;
	import org.osmf.traits.TestDisplayObjectTrait;
	import org.osmf.traits.TestDisplayObjectTraitAsSubclass;
	import org.osmf.traits.TestDynamicStreamTrait;
	import org.osmf.traits.TestLoadTrait;
	import org.osmf.traits.TestLoadTraitAsSubclass;
	import org.osmf.traits.TestLoaderBase;
	import org.osmf.traits.TestPlayTrait;
	import org.osmf.traits.TestPlayTraitAsSubclass;
	import org.osmf.traits.TestSeekTrait;
	import org.osmf.traits.TestTimeTrait;
	import org.osmf.traits.TestTimeTraitAsSubclass;
	import org.osmf.traits.TestTraitEventDispatcher;
	import org.osmf.utils.OSMFUtilTestSettings;
	import org.osmf.utils.OSMFUtilTestStrings;
	import org.osmf.utils.OSMFUtilTestTime;
	import org.osmf.utils.OSMFUtilTestURL;
	import org.osmf.utils.TestURL;
	
	public class OSMFTests
	{
		public static function currentRunTestSuite():Array
		{
			var testsToRun:Array = new Array();
			
			testsToRun.push(org.osmf.containers.TestHTMLMediaContainer);
			testsToRun.push(org.osmf.containers.TestMediaContainer);
			testsToRun.push(org.osmf.events.TestMediaError);
			testsToRun.push(org.osmf.events.TestMediaErrorAsSubclass);
			testsToRun.push(org.osmf.layout.TestAbsoluteLayoutMetadata);
			testsToRun.push(org.osmf.layout.TestAnchorLayoutMetadata);
			testsToRun.push(org.osmf.layout.TestBinarySearch);
			testsToRun.push(org.osmf.layout.TestBoxAttributesMetadata);
			testsToRun.push(org.osmf.layout.TestGenericLayout);
			testsToRun.push(org.osmf.layout.TestLayoutAttributesMetadata);
			testsToRun.push(org.osmf.layout.TestLayoutMetadata);
			testsToRun.push(org.osmf.layout.TestLayoutRenderer);
			testsToRun.push(org.osmf.layout.TestLayoutRendererBase);
			testsToRun.push(org.osmf.layout.TestLayoutTargetEvent);
			testsToRun.push(org.osmf.layout.TestLayoutTargetRenderers);
			testsToRun.push(org.osmf.layout.TestMediaElementLayoutTarget);
			testsToRun.push(org.osmf.layout.TestLayoutTargetSprite);
			testsToRun.push(org.osmf.layout.TestOverlayLayoutMetadata);
			testsToRun.push(org.osmf.layout.TestPaddingLayoutMetadata);
			testsToRun.push(org.osmf.layout.TestRelativeLayoutMetadata);
			testsToRun.push(org.osmf.layout.TestScaleModeUtils);
			testsToRun.push(org.osmf.logging.TestLog);
			testsToRun.push(org.osmf.media.MediaTraitResolverBaseTestCase);
			testsToRun.push(org.osmf.media.TestDefaultMediaFactory);
			testsToRun.push(org.osmf.media.TestDefaultTraitResolver);
			testsToRun.push(org.osmf.media.TestLoadableElementBase);
			testsToRun.push(org.osmf.media.TestMediaElement);
			testsToRun.push(org.osmf.media.TestMediaElementAsSubclass);
			testsToRun.push(org.osmf.media.TestMediaFactory);
			testsToRun.push(org.osmf.media.TestMediaFactoryItem);
			testsToRun.push(org.osmf.media.TestMediaPlayer);
			testsToRun.push(org.osmf.media.TestMediaPlayerSprite);
			testsToRun.push(org.osmf.media.TestMediaPlayerWithAudioElement);
			testsToRun.push(org.osmf.media.TestMediaPlayerWithAudioElementWithSoundLoader);
			testsToRun.push(org.osmf.media.TestMediaPlayerWithBeaconElement);
			testsToRun.push(org.osmf.media.TestMediaPlayerWithDurationElement);
			testsToRun.push(org.osmf.media.TestMediaPlayerWithDynamicStreamingVideoElement);
			testsToRun.push(org.osmf.media.TestMediaPlayerWithDynamicStreamingVideoElementSubclip);
			testsToRun.push(org.osmf.media.TestMediaPlayerWithLightweightVideoElement);
			testsToRun.push(org.osmf.media.TestMediaPlayerWithProxyElement);
			testsToRun.push(org.osmf.media.TestMediaPlayerWithSerialElementWithDurationElements);
			testsToRun.push(org.osmf.media.TestMediaPlayerWithVideoElement);
			testsToRun.push(org.osmf.media.TestMediaPlayerWithVideoElementSubclip);
			testsToRun.push(org.osmf.media.TestMediaTraitResolver);
			testsToRun.push(org.osmf.media.TestMediaType);
			testsToRun.push(org.osmf.media.TestMediaTypeUtil);
			testsToRun.push(org.osmf.media.TestPluginInfo);
			testsToRun.push(org.osmf.media.TestURLResource);
			testsToRun.push(org.osmf.media.pluginClasses.TestDynamicPluginLoader);
			testsToRun.push(org.osmf.media.pluginClasses.TestPluginElement);
			testsToRun.push(org.osmf.media.pluginClasses.TestPluginLoadingState);
			testsToRun.push(org.osmf.media.pluginClasses.TestPluginManager);
			testsToRun.push(org.osmf.media.pluginClasses.TestStaticPluginLoader);
			testsToRun.push(org.osmf.metadata.TestCuePoint);
			testsToRun.push(org.osmf.metadata.TestMetadata);
			testsToRun.push(org.osmf.metadata.TestMetadataWatcher);
			testsToRun.push(org.osmf.metadata.TestTimelineMarker);
			testsToRun.push(org.osmf.metadata.TestTimelineMetadata);
			testsToRun.push(org.osmf.net.drm.TestDRMServices);
			testsToRun.push(org.osmf.net.TestDynamicStreamingItem);
			testsToRun.push(org.osmf.net.TestDynamicStreamingResource);
			testsToRun.push(org.osmf.net.TestSwitchManager);
			testsToRun.push(org.osmf.net.metrics.TestActualBitrateMetric);
			testsToRun.push(org.osmf.net.metrics.TestAvailableQualityLevelsMetric);
			testsToRun.push(org.osmf.net.metrics.TestBandwidthMetric);
			testsToRun.push(org.osmf.net.metrics.TestBufferFragmentsMetric);
			testsToRun.push(org.osmf.net.metrics.TestBufferLengthMetric);
			testsToRun.push(org.osmf.net.metrics.TestBufferOccupationRatioMetric);
			testsToRun.push(org.osmf.net.metrics.TestCurrentStatusMetric);
			testsToRun.push(org.osmf.net.metrics.TestDefaultMetricFactory);
			testsToRun.push(org.osmf.net.metrics.TestDroppedFPSMetric);
			testsToRun.push(org.osmf.net.metrics.TestEmptyBufferInterruptionMetric);
			testsToRun.push(org.osmf.net.metrics.TestFPSMetric);
			testsToRun.push(org.osmf.net.metrics.TestFragmentCountMetric);
			testsToRun.push(org.osmf.net.metrics.TestMetricBase);
			testsToRun.push(org.osmf.net.metrics.TestMetricFactory);
			testsToRun.push(org.osmf.net.metrics.TestMetricFactoryItem);
			testsToRun.push(org.osmf.net.metrics.TestMetricRepository);
			testsToRun.push(org.osmf.net.metrics.TestMetricValue);
			testsToRun.push(org.osmf.net.metrics.TestRecentSwitchMetric);
			testsToRun.push(org.osmf.net.qos.TestQoSInfoHistory);
			testsToRun.push(org.osmf.net.rules.TestAfterUpSwitchBufferBandwidthRule);
			testsToRun.push(org.osmf.net.rules.TestBandwidthRule);
			testsToRun.push(org.osmf.net.rules.TestBufferBandwidthRule);
			testsToRun.push(org.osmf.net.rules.TestDroppedFPSRule);
			testsToRun.push(org.osmf.net.rules.TestEmptyBufferRule);
			testsToRun.push(org.osmf.net.rules.TestRecommendation);
			testsToRun.push(org.osmf.net.rules.TestRuleUtils);
			testsToRun.push(org.osmf.traits.TestAudioTrait);
			testsToRun.push(org.osmf.traits.TestBufferTrait);
			testsToRun.push(org.osmf.traits.TestBufferTraitAsSubclass);
			testsToRun.push(org.osmf.traits.TestDisplayObjectTrait);
			testsToRun.push(org.osmf.traits.TestDisplayObjectTraitAsSubclass);
			testsToRun.push(org.osmf.traits.TestDRMTrait);
			testsToRun.push(org.osmf.traits.TestDVRTrait);
			testsToRun.push(org.osmf.traits.TestDynamicStreamTrait);
			testsToRun.push(org.osmf.traits.TestLoaderBase);
			testsToRun.push(org.osmf.traits.TestLoadTrait);
			testsToRun.push(org.osmf.traits.TestLoadTraitAsSubclass);
			testsToRun.push(org.osmf.traits.TestPlayTrait);
			testsToRun.push(org.osmf.traits.TestPlayTraitAsSubclass);
			testsToRun.push(org.osmf.traits.TestSeekTrait);
			testsToRun.push(org.osmf.traits.TestTimeTrait);
			testsToRun.push(org.osmf.traits.TestTimeTraitAsSubclass);
			testsToRun.push(org.osmf.traits.TestTraitEventDispatcher);
			testsToRun.push(org.osmf.utils.OSMFUtilTestSettings);
			testsToRun.push(org.osmf.utils.OSMFUtilTestStrings);
			testsToRun.push(org.osmf.utils.OSMFUtilTestTime);
			testsToRun.push(org.osmf.utils.OSMFUtilTestURL);
			testsToRun.push(org.osmf.utils.TestURL);
			
			return testsToRun;
		}
	}
}