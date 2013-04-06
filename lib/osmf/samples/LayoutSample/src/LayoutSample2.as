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
	
	import org.osmf.layout.LayoutMode;
	import org.osmf.layout.LayoutRenderer;
	import org.osmf.layout.LayoutTargetSprite;

	[SWF(backgroundColor="0xC0C0C0", frameRate="25", width="640", height="360")]
	public class LayoutSample2 extends Sprite
	{
		public function LayoutSample2()
		{
			// Construct a layout renderer:
			var renderer:LayoutRenderer = new LayoutRenderer();
			
			// Construct a red, green and blue ball:
			var ball1:LayoutTargetSprite = createBall(0xff0000);
			var ball2:LayoutTargetSprite = createBall(0x00ff00);
			var ball3:LayoutTargetSprite = createBall(0x0000ff);
			
			// Add each ball as a target to the renderer:
			renderer.addTarget(ball1);
			renderer.addTarget(ball2);
			renderer.addTarget(ball3);
			
			// Construct a layout target sprite that the renderer
			// can use as its container:
			var container:LayoutTargetSprite
				= new LayoutTargetSprite();
			renderer.container = container;
			addChild(container);
			
			// Set the container to operate in VERTICAL layoutMode:
			container.layoutMetadata.layoutMode = LayoutMode.VERTICAL;
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
			
			return result;
		}
	}
}