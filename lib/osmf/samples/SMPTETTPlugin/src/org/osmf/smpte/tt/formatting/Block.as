/***********************************************************
 * 
 * Copyright 2011 Adobe Systems Incorporated. All Rights Reserved.
 *
 * *********************************************************
 * The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 * (the "License"); you may not use this file except in
 * compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems
 * Incorporated. All Rights Reserved.
 **********************************************************/
package org.osmf.smpte.tt.formatting
{
	import flash.geom.Rectangle;
	
	import org.osmf.smpte.tt.model.TimedTextElementBase;
	import org.osmf.smpte.tt.rendering.IRenderObject;
	import org.osmf.smpte.tt.styling.ColorExpression;
	import org.osmf.smpte.tt.styling.Colors;
	import org.osmf.smpte.tt.styling.WritingMode;

	public class Block extends FormattingObject
	{
		public function Block(p_element:TimedTextElementBase)
		{
			element = p_element;
		}
		
		public override function referenceArea():Rectangle
		{
			var fo:FormattingObject = this.parent as FormattingObject;
			
			return fo.referenceArea();
		}
		
		public override function actualArea():Rectangle
		{
			return actualDrawing;
		}
		
		/**
		 * Return a formatting function for this element.
		 */
		public override function createFormatter():Function
		{
			var func:Function = function(renderObject:IRenderObject):void
				{
					computeRelativeStyles(renderObject);
					applyAnimations();
					var fmt:FormattingObject;
					if (displayStyleProperty != "none")  // kill layout of this subtree.
					{
						var top:Number = topStyleProperty;
						var left:Number = leftStyleProperty;
						
						var backgroundColor:ColorExpression = backgroundColorStyleProperty;
						if (this.parent is BlockContainer)
						{
							// then we already drew the background
							backgroundColor = Colors.Transparent;
						}
						
						var pass:int = this.renderPassProperty;
						
						if (visibilityStyleProperty == "hidden")  // everything is drawn transparently.
						{
							backgroundColor = Colors.Transparent;
						}
						
						var child:*;
						if (pass == 0)
						{
							actualDrawing = new Rectangle();
							actualDrawing.x = referenceArea().x;
							actualDrawing.y = referenceArea().y;
							actualDrawing.width = referenceArea().width;
							actualDrawing.height = 0;
							for each (child in children)
							{
								fmt = child as FormattingObject;
								/// blocks stack their children inside the 
								/// reference area. But in order to know where we have to
								/// know how big they are.
								fmt.setStyle("#left", left);
								fmt.setStyle("#top", top);
								fmt.createFormatter()(renderObject);
								top += fmt.actualArea().height;
								actualDrawing.height += fmt.actualArea().height;
							}
						}
						else
						{
							actualDrawing.y = top;
							actualDrawing.x = left;
							var right:Number = Math.min(actualDrawing.x + actualDrawing.width, referenceArea().x + referenceArea().width);
							var bottom:Number = Math.min(actualDrawing.y + actualDrawing.height, referenceArea().y + referenceArea().height);
							renderObject.drawRectangle(backgroundColor, actualDrawing.x, actualDrawing.y, right, bottom);
							
							var mode:WritingMode= writingModeStyleProperty;
							var vertical:Boolean = (mode == WritingMode.TOP_BOTTOM_LEFT_RIGHT || mode == WritingMode.TOP_BOTTOM_RIGHT_LEFT);
							var rightMode:Boolean = (mode == WritingMode.TOP_BOTTOM_RIGHT_LEFT);
							
							// set left depending on writing mode.
							if (vertical && rightMode)
							{   // start over on the right.
								left = actualDrawing.x + actualDrawing.width;
							}
							else
							{   // start on the left.
								left = actualDrawing.x;
							}
							
							for each (child in children)
							{
								/// issue - do we need some block advance width?
								fmt = child as FormattingObject;
								if (vertical && rightMode) left -= fmt.actualArea().width;
								fmt.setStyle("#top", top);
								fmt.setStyle("#left", left);
								fmt.createFormatter()(renderObject);
								if(!vertical) top += fmt.actualArea().height;
								if (vertical && !rightMode) left += fmt.actualArea().width;
							}
						}
					}
					removeAppliedAnimations();
					return;
				};
			return func;
		}
	}
}