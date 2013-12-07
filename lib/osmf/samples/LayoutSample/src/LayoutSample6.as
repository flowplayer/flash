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
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.PerspectiveProjection;
	import flash.utils.Timer;
	
	import org.osmf.layout.LayoutMode;
	import org.osmf.layout.LayoutRenderer;
	import org.osmf.layout.LayoutTargetSprite;

	[SWF(backgroundColor="0xC0C0C0", frameRate="25", width="640", height="360")]
	public class LayoutSample6 extends Sprite
	{
		private var t:Timer;
		private var ball1:LayoutTargetSprite;
		private var ball2:LayoutTargetSprite;
		private var ball3:LayoutTargetSprite;
		private var ball4:LayoutTargetSprite;
		private var renderer:LayoutRenderer;
		
		public function LayoutSample6()
		{
			// Construct a layout renderer:
			renderer = new LayoutRenderer();
			
			// Construct a red, green and blue ball:
			ball1 = createBall(0xeeddee);
			ball2 = createBall(0xccff00);
			ball3 = createBall(0xff0000);
			ball4 = createBall(0x333333);
			
			// Add each ball as a target to the renderer:
			renderer.addTarget(ball1);
			renderer.addTarget(ball2);
			renderer.addTarget(ball3);
			renderer.addTarget(ball4);
			
			// Construct a layout target sprite that the renderer
			// can use as its container:
			var container:LayoutTargetSprite
				= new LayoutTargetSprite();
			renderer.container = container;
			addChild(container);
			
			// Set the container to operate in VERTICAL layoutMode:
			container.layoutMetadata.layoutMode = LayoutMode.NONE;
			
			
			t = new Timer(2500, 0);
			t.start();
			t.addEventListener(TimerEvent.TIMER, onTimer);
			
		}
		
		private function onTimer(e:TimerEvent):void
		{
			var tmp:int = ball1.layoutMetadata.index;
			ball1.layoutMetadata.index= ball2.layoutMetadata.index ;
			ball2.layoutMetadata.index = ball3.layoutMetadata.index ;	
			ball3.layoutMetadata.index = ball4.layoutMetadata.index ;	
			ball4.layoutMetadata.index = tmp;
		}
		
		private function createBall(color:uint):LayoutTargetSprite
		{
			// Construct a layout target sprite (a Sprite that implements
			// the ILayoutTarget interface):
			var result:LayoutTargetSprite = new LayoutTargetSprite();
			
			// Draw a circle: 
			result.graphics.beginFill(color);
			result.graphics.drawCircle(50,50,50);
			result.graphics.endFill();
			
			// Inform the layout system that this layout target is a
			// 100x100 pixels in size:
			result.layoutMetadata.width = 100;
			result.layoutMetadata.height = 100;
			
			// Derive from color the RED component of the color 
			// and index from the GREEN component 
			result.layoutMetadata.percentX = (((color & 0xff0000) >> 16) / 255) * 100;
			result.layoutMetadata.percentY = ((color & 0x0000ff) / 255) * 100;
			result.layoutMetadata.index = (((color & 0x00ff00)  >> 8) / 255) * 100;
			
			return result;
		}
	}
}