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

package org.osmf.player.chrome.hint
{
	import flash.errors.IllegalOperationError;
	
	import flashx.textLayout.debug.assert;
	
	import flexunit.framework.Assert;
	import flexunit.framework.AssertionFailedError;
	
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.asserts.fail;
	import org.osmf.player.chrome.configuration.WidgetsParser;
	import org.osmf.player.chrome.widgets.LabelWidget;
	import org.osmf.player.chrome.widgets.Widget;
	
	public class TestWidgetHint
	{		
		[Before]
		public function setUp():void
		{
			parentWidget = new Widget();
			childWidget = new LabelWidget();
		}
		
		[After]
		public function tearDown():void
		{
			parentWidget = null;
			childWidget = null;
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
		public function testGetInstance():void
		{
			Assert.assertTrue(WidgetHint.getInstance(parentWidget) is WidgetHint);
		}

		[Test]
		public function testGetInstanceTwice():void
		{
			Assert.assertStrictlyEquals
				( WidgetHint.getInstance(parentWidget)
				, WidgetHint.getInstance(new Widget())
				);
		}

		
		[Test]
		public function testSetAndGet_widget():void
		{
			WidgetHint.getInstance(parentWidget).widget = childWidget;
			Assert.assertStrictlyEquals(WidgetHint.getInstance(parentWidget).widget, childWidget);
		}
		
		[Test]
		public function testWidgetHint():void
		{
			try
			{
				var widgetHint:WidgetHint = new WidgetHint(null);
				Assert.fail("WidgetHint constructor should not succeed since is a singleton");
			}
			catch (e:*)
			{
				Assert.assertTrue(e is IllegalOperationError);
			}
		}
		
		[Test]
		public function testWidgetHintHide():void
		{
			WidgetHint.getInstance(parentWidget).widget = childWidget;
			WidgetHint.getInstance(parentWidget).hide();
			
			assertNull(WidgetHint.getInstance(parentWidget).widget);
		}
		
		
		private var parentWidget:Widget;
		private var childWidget:Widget;
		
	}
}