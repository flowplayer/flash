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
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.osmf.player.chrome.widgets.AlertDialog;
	import org.osmf.player.chrome.widgets.LabelWidget;
	import org.osmf.player.chrome.widgets.Widget;
	import org.osmf.player.chrome.ChromeProvider;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitType;
	
	public class TestAlertDialogElement
	{		
		[Before]
		public function setUp():void
		{
			var cp:ChromeProvider = ChromeProvider.getInstance();
			if (cp.loaded == false)
			{
				cp.load(null);
			}
			alertDialogElement = new AlertDialogElement();
			
			viewable = alertDialogElement.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
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
		public function testAlertText():void
		{
			alertDialogElement.alert(CAPTION, MESSAGE);
			
			assertEquals(CAPTION, ((viewable.displayObject as AlertDialog).getChildWidget("captionLabel") as LabelWidget).text);
			assertEquals(MESSAGE, ((viewable.displayObject as AlertDialog).getChildWidget("messageLabel") as LabelWidget).text);
		}

		[Test]
		public function testAlertNotVisible():void
		{
			assertFalse((viewable.displayObject as AlertDialog).visible);
		}


		[Test]
		public function testAlertVisible():void
		{
			alertDialogElement.alert(CAPTION, MESSAGE);
			assertTrue((viewable.displayObject as AlertDialog).visible);
		}

		
		[Test]
		public function testAlertDialogElement():void
		{
			assertTrue(viewable.displayObject is AlertDialog);
		}
		
		[Test]
		public function testSet_tintColor():void
		{
			alertDialogElement.tintColor = TINT_COLOR;
			
			assertEquals(TINT_COLOR, (viewable.displayObject as Widget).tintColor);
		}
		
		private var alertDialogElement:AlertDialogElement;
		private var viewable:DisplayObjectTrait;

		/* static */
		private static const TINT_COLOR:uint = 0x11aa22;
		private static const CAPTION:String = "Message:"; 
		private static const MESSAGE:String = "Thins is the message to be displayed"; 
	}
}