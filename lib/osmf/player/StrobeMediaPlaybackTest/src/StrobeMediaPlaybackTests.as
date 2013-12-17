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
						
			import org.osmf.player.utils.TestVideoRenderingUtils;
			import org.osmf.player.utils.TestStrobeUtils;
			import org.osmf.player.plugins.TestPluginWhitelist;
			import org.osmf.player.plugins.TestPluginLoader;
			import org.osmf.player.media.TestStrobeMediaPlayer;
			import org.osmf.player.media.TestStrobeMediaFactory;
			import org.osmf.player.errors.TestErrorTranslator;
			import org.osmf.player.elements.TestPlaylistElement;
			import org.osmf.player.elements.TestControlBarElement;
			import org.osmf.player.elements.TestAuthenticationDialogElement;
			import org.osmf.player.elements.TestAlertDialogElement;
			import org.osmf.player.configuration.TestSkinParser;
			import org.osmf.player.configuration.TestPluginConfiguration;
			import org.osmf.player.configuration.TestPlayerConfiguration;
			import org.osmf.player.configuration.TestConfigurationXMLDeserializer;
			import org.osmf.player.configuration.TestConfigurationLoader;
			import org.osmf.player.chrome.widgets.TestVolumeWidget;
			import org.osmf.player.chrome.widgets.TestTimeViewWidget;
			import org.osmf.player.chrome.widgets.TestTimeHintWidget;
			import org.osmf.player.chrome.widgets.TestScrubBar;
			import org.osmf.player.chrome.widgets.TestPlayButtonOverlay;
			import org.osmf.player.chrome.widgets.TestPlayButton;
			import org.osmf.player.chrome.widgets.TestPauseButton;
			import org.osmf.player.chrome.widgets.TestMuteButton;
			import org.osmf.player.chrome.widgets.TestFullScreenEnterButton;
			import org.osmf.player.chrome.widgets.TestBufferingOverlay;
			import org.osmf.player.chrome.widgets.TestAutoHideWidget;
			import org.osmf.player.chrome.widgets.TestAuthenticationDialog;
			import org.osmf.player.chrome.widgets.TestAlertDialog;
			import org.osmf.player.chrome.utils.TestFormatUtils;
			import org.osmf.player.chrome.hint.TestWidgetHint;
			import org.osmf.net.TestPlaybackOptimizationMetrics;
			import org.osmf.net.TestPlaybackOptimizationManager;
			
			public class StrobeMediaPlaybackTests
			{
				public static var testsToRun:Array = new Array();
				
				public static function currentRunTestSuite():Array
				{
					
					testsToRun.push(TestStrobeMediaPlayback);
					testsToRun.push(org.osmf.net.TestPlaybackOptimizationManager);
					testsToRun.push(org.osmf.net.TestPlaybackOptimizationMetrics);
					testsToRun.push(org.osmf.player.chrome.hint.TestWidgetHint);
					testsToRun.push(org.osmf.player.chrome.utils.TestFormatUtils);
					testsToRun.push(org.osmf.player.chrome.widgets.TestAlertDialog);
					testsToRun.push(org.osmf.player.chrome.widgets.TestAuthenticationDialog);
					testsToRun.push(org.osmf.player.chrome.widgets.TestAutoHideWidget);
					testsToRun.push(org.osmf.player.chrome.widgets.TestBufferingOverlay);
					testsToRun.push(org.osmf.player.chrome.widgets.TestFullScreenEnterButton);
					testsToRun.push(org.osmf.player.chrome.widgets.TestMuteButton);
					testsToRun.push(org.osmf.player.chrome.widgets.TestPauseButton);
					testsToRun.push(org.osmf.player.chrome.widgets.TestPlayButton);
					testsToRun.push(org.osmf.player.chrome.widgets.TestPlayButtonOverlay);
					testsToRun.push(org.osmf.player.chrome.widgets.TestScrubBar);
					testsToRun.push(org.osmf.player.chrome.widgets.TestTimeHintWidget);
					testsToRun.push(org.osmf.player.chrome.widgets.TestTimeViewWidget);
					testsToRun.push(org.osmf.player.chrome.widgets.TestVolumeWidget);
					testsToRun.push(org.osmf.player.configuration.TestConfigurationLoader);
					testsToRun.push(org.osmf.player.configuration.TestConfigurationXMLDeserializer);
					testsToRun.push(org.osmf.player.configuration.TestPlayerConfiguration);
					testsToRun.push(org.osmf.player.configuration.TestPluginConfiguration);
					testsToRun.push(org.osmf.player.configuration.TestSkinParser);
					testsToRun.push(org.osmf.player.elements.TestAlertDialogElement);
					testsToRun.push(org.osmf.player.elements.TestAuthenticationDialogElement);
					testsToRun.push(org.osmf.player.elements.TestControlBarElement);
					testsToRun.push(org.osmf.player.elements.TestPlaylistElement);
					testsToRun.push(org.osmf.player.errors.TestErrorTranslator);
					testsToRun.push(org.osmf.player.media.TestStrobeMediaFactory);
					testsToRun.push(org.osmf.player.media.TestStrobeMediaPlayer);
					testsToRun.push(org.osmf.player.plugins.TestPluginLoader);
					testsToRun.push(org.osmf.player.plugins.TestPluginWhitelist);
					testsToRun.push(org.osmf.player.utils.TestStrobeUtils);
					testsToRun.push(org.osmf.player.utils.TestVideoRenderingUtils);
					
					return testsToRun;
					
				}
			}
}