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

package org.osmf.player.chrome.widgets
{
	import flash.events.MouseEvent;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.osmf.MockDRMTrait;
	import org.osmf.MockLoadTrait;
	import org.osmf.MockMediaElement;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.events.DRMEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.net.NetLoader;
	import org.osmf.traits.DRMState;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	
	public class TestAuthenticationDialog
	{		
		[Before]
		public function setUp():void
		{
			authenticationDialog = new AuthenticationDialog();
			
			var submitButton:ButtonWidget = new ButtonWidget();
			submitButton.id = "submitButton";
			authenticationDialog.addChildWidget(submitButton);
					
			var cancelButton:ButtonWidget = new ButtonWidget();
			cancelButton.id = "cancelButton";
			authenticationDialog.addChildWidget(cancelButton);

			var username:LabelWidget = new LabelWidget();
			username.id = "username";
			authenticationDialog.addChildWidget(username);

			var password:LabelWidget = new LabelWidget();
			password.id = "password";
			authenticationDialog.addChildWidget(password);

			authenticationDialog.configure(<default />, new AssetsManager());
			
			encryptedMedia = new MockMediaElement();
			encryptedMedia.addSomeTrait(new MockLoadTrait());
			encryptedMedia.addSomeTrait(new PlayTrait);
			encryptedMedia.addSomeTrait(new MockDRMTrait());
			
			plainMedia = new MockMediaElement();
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test]
		public function testAuthenticationDialog():void
		{
			assertFalse(authenticationDialog.visible);
		}


		[Test]
		public function testNoDRMMedia():void
		{
			authenticationDialog.media = plainMedia;
			assertFalse(authenticationDialog.visible);
		}
		
		[Test]
		public function testDRMMedia():void
		{
			authenticationDialog.media = encryptedMedia;
			assertFalse(authenticationDialog.visible);
		}
		
		[Test]
		public function testDRMAuthenticationNeeded():void
		{
			authenticationDialog.media = encryptedMedia;
			(encryptedMedia.getTrait(MediaTraitType.DRM) as MockDRMTrait).drmState = DRMState.AUTHENTICATION_NEEDED;
			
			assertTrue(authenticationDialog.visible);
		}
		
		
		
		[Test]
		public function testDRMAuthenticationComplete():void
		{
			authenticationDialog.media = encryptedMedia;
			(encryptedMedia.getTrait(MediaTraitType.DRM) as MockDRMTrait).drmState = DRMState.AUTHENTICATION_NEEDED;
			(encryptedMedia.getTrait(MediaTraitType.DRM) as MockDRMTrait).drmState = DRMState.AUTHENTICATION_COMPLETE;
			
			assertFalse(authenticationDialog.visible)
		}
		
		[Test]
		public function testSubmitClicked():void
		{
			authenticationDialog.media = encryptedMedia;
			(encryptedMedia.getTrait(MediaTraitType.DRM) as MockDRMTrait).drmState = DRMState.AUTHENTICATION_NEEDED;
			(authenticationDialog.getChildWidget("submitButton") as ButtonWidget)
				.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			
			assertFalse(authenticationDialog.visible);
		}

		[Test]
		public function testDRMAuthenticationError():void
		{
			authenticationDialog.media = encryptedMedia;
			(authenticationDialog.getChildWidget("submitButton") as ButtonWidget)
				.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			
			(encryptedMedia.getTrait(MediaTraitType.DRM) as MockDRMTrait).drmState = DRMState.AUTHENTICATION_ERROR;
			
			assertTrue(authenticationDialog.visible);
		}

		[Test]
		public function testDRMAuthenticationSuccess():void
		{
			// simulate authentication
			authenticationDialog.media = encryptedMedia;
			(authenticationDialog.getChildWidget("submitButton") as ButtonWidget)
				.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			
			//simulate success
			(encryptedMedia.getTrait(MediaTraitType.DRM) as MockDRMTrait).drmState = DRMState.AUTHENTICATION_COMPLETE;
			
			assertFalse(authenticationDialog.visible);
		}
		
		[Test]
		public function testResumePlayback():void
		{
		
			authenticationDialog.media = encryptedMedia;
			authenticationDialog.playAfterAuthentication = true;
		
			// simulate successful authentication	
			(authenticationDialog.getChildWidget("submitButton") as ButtonWidget)
				.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
				
			(encryptedMedia.getTrait(MediaTraitType.DRM) as MockDRMTrait).drmState = DRMState.AUTHENTICATION_COMPLETE;
			
			//simulate stream restart
			(encryptedMedia.getTrait(MediaTraitType.LOAD) as MockLoadTrait).loadState = LoadState.READY;
			
			//check if playing
			assertTrue(PlayState.PLAYING, (encryptedMedia.getTrait(MediaTraitType.PLAY) as PlayTrait).playState);
		}
		
		[Test]
		public function testResumePlaybackNoPlayTrait():void
		{
			authenticationDialog.media = encryptedMedia;
			
			encryptedMedia.removeSomeTrait(MediaTraitType.PLAY);

			authenticationDialog.playAfterAuthentication = true;
			
			// simulate successful authentication	
			(authenticationDialog.getChildWidget("submitButton") as ButtonWidget)
			.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			
			(encryptedMedia.getTrait(MediaTraitType.DRM) as MockDRMTrait).drmState = DRMState.AUTHENTICATION_COMPLETE;
			
			//simulate stream restart
			(encryptedMedia.getTrait(MediaTraitType.LOAD) as MockLoadTrait).loadState = LoadState.READY;

			assertFalse(encryptedMedia.hasTrait(MediaTraitType.PLAY));
		}
		
		[Test]
		public function testResumePlaybackUnableToReload():void
		{
			authenticationDialog.media = encryptedMedia;
						
			authenticationDialog.playAfterAuthentication = true;
			
			// simulate successful authentication	
			(authenticationDialog.getChildWidget("submitButton") as ButtonWidget)
			.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			
			(encryptedMedia.getTrait(MediaTraitType.DRM) as MockDRMTrait).drmState = DRMState.AUTHENTICATION_COMPLETE;
						
			assertFalse(PlayState.PLAYING == (encryptedMedia.getTrait(MediaTraitType.PLAY) as PlayTrait).playState);
		}

		[Test]
		public function testResumePlaybackNoLoadTrait():void
		{
			authenticationDialog.media = encryptedMedia;
			authenticationDialog.playAfterAuthentication = true;

			encryptedMedia.removeSomeTrait(MediaTraitType.LOAD);
						
			// simulate successful authentication	
			(authenticationDialog.getChildWidget("submitButton") as ButtonWidget)
			.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			
			(encryptedMedia.getTrait(MediaTraitType.DRM) as MockDRMTrait).drmState = DRMState.AUTHENTICATION_COMPLETE;

			
			assertFalse(PlayState.PLAYING == (encryptedMedia.getTrait(MediaTraitType.PLAY) as PlayTrait).playState);
		}

				
		[Test]
		public function testCancelClick():void
		{
			
			authenticationDialog.media = encryptedMedia;
			
			(encryptedMedia.getTrait(MediaTraitType.DRM) as MockDRMTrait).drmState = DRMState.AUTHENTICATION_NEEDED;

			// simulate cancel click
			(authenticationDialog.getChildWidget("cancelButton") as ButtonWidget)
				.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			
			assertFalse(authenticationDialog.visible);
		}
		
		private var authenticationDialog:AuthenticationDialog;
		private var plainMedia:MockMediaElement;
		private var encryptedMedia:MockMediaElement;
	}
}