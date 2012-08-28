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

package org.osmf.player.elements
{
	import flexunit.framework.Assert;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.flexunit.asserts.assertTrue;
	import org.osmf.player.chrome.widgets.AuthenticationDialog;
	import org.osmf.player.chrome.widgets.Widget;
	import org.osmf.elements.VideoElement;
	import org.osmf.player.chrome.ChromeProvider;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitType;
	
	public class TestAuthenticationDialogElement
	{		
		[Before]
		public function setUp():void
		{
			var cp:ChromeProvider = ChromeProvider.getInstance();
			if (cp.loaded == false)
			{
				cp.load(null);
			}
			
			testVideoElement = new VideoElement();
			authenticationDialogElement = new AuthenticationDialogElement();
			
			viewable = authenticationDialogElement.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
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
		public function testAuthenticationDialogElement():void
		{
			assertTrue(viewable.displayObject is AuthenticationDialog);
		}
		
		[Test]
		public function testSet_target():void
		{
			authenticationDialogElement.target = testVideoElement;
			
			assertStrictlyEquals(testVideoElement, (viewable.displayObject as AuthenticationDialog).media);
		}
		
		[Test]
		public function testSet_tintColor():void
		{
			authenticationDialogElement.tintColor = TINT_COLOR;
			
			assertEquals(TINT_COLOR, (viewable.displayObject as Widget).tintColor);			
		}
		
		private var authenticationDialogElement:AuthenticationDialogElement;
		private var viewable:DisplayObjectTrait;
		private var testVideoElement:VideoElement;
		
		/* static */
		private static const TINT_COLOR:uint = 0x435612;
	}
}