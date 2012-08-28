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

package
{
	import flexunit.framework.Test;
	
	import org.osmf.net.TestPlaybackOptimizationManager;
	import org.osmf.net.TestPlaybackOptimizationMetrics;
	import org.osmf.player.chrome.hint.TestWidgetHint;
	import org.osmf.player.chrome.utils.TestFormatUtils;
	import org.osmf.player.chrome.widgets.*;
	import org.osmf.player.chrome.widgets.TestTimeViewWidget;
	import org.osmf.player.configuration.TestConfigurationLoader;
	import org.osmf.player.configuration.TestConfigurationXMLDeserializer;
	import org.osmf.player.configuration.TestPlayerConfiguration;
	import org.osmf.player.configuration.TestPluginConfiguration;
	import org.osmf.player.configuration.TestSkinParser;
	import org.osmf.player.elements.TestAlertDialogElement;
	import org.osmf.player.elements.TestAuthenticationDialogElement;
	import org.osmf.player.elements.TestControlBarElement;
	import org.osmf.player.elements.TestPlaylistElement;
	import org.osmf.player.errors.TestErrorTranslator;
	import org.osmf.player.media.TestStrobeMediaFactory;
	import org.osmf.player.media.TestStrobeMediaPlayer;
	import org.osmf.player.plugins.TestPluginLoader;
	import org.osmf.player.utils.TestVideoRenderingUtils;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class StrobeMediaPlaybackTests
	{
		public var testPlayerConfiguration:TestPlayerConfiguration;
		public var testVideoQualityUtils:TestVideoRenderingUtils;
		public var testPluginIntegration:TestPluginConfiguration;
		public var testControlBarElement:TestControlBarElement
		public var testAlertDialogElement:TestAlertDialogElement;
		public var testAuthenticationDialogElement:TestAuthenticationDialogElement;
		public var testStrobeMediaPlayback:TestStrobeMediaPlayback;
		public var testTimeViewWidget:TestTimeViewWidget;
		public var testPluginLoader:TestPluginLoader;
		//public var testStrobeMediaPlayer:TestStrobeMediaPlayer;
		public var testPlaylistElement:TestPlaylistElement;
		//public var testPlaybackOptimizationManager:TestPlaybackOptimizationManager;
		// public var testPlaybackOptimizationMetrics:TestPlaybackOptimizationMetrics;
		public var testStrobeMediaFactory:TestStrobeMediaFactory;
		public var testSkinParser:TestSkinParser;
		public var testErrorTranslator:TestErrorTranslator;
		public var testConfigurationLoader:TestConfigurationLoader;		
		
		
		// ChromeLibrary tests
		
		public var widgetHint:TestWidgetHint;
		public var timeHintWidget:TestTimeHintWidget;
		public var volumeWidget:TestVolumeWidget;
		public var muteButton:TestMuteButton;
		public var testFormatUtils:TestFormatUtils;
		public var testPlayButton:TestPlayButton;
		public var testPauseButton:TestPauseButton;
		public var testAlertDialog:TestAlertDialog;
		public var testAuthenticationDialog:TestAuthenticationDialog;
		public var testFullScreenEnterButton:TestFullScreenEnterButton;
		public var testAutoHideWidget:TestAutoHideWidget;
		public var testPlaybuttonOverlay:TestPlayButtonOverlay;
		// public var testBufferingOverlay:TestBufferingOverlay;
		
		public var testConfigurationXMLDeserializer:TestConfigurationXMLDeserializer;
	}
}