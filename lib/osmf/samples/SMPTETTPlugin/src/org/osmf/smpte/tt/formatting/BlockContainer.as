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
	import org.osmf.smpte.tt.styling.Extent;
	import org.osmf.smpte.tt.styling.Origin;
	import org.osmf.smpte.tt.styling.PaddingThickness;

	public class BlockContainer extends FormattingObject
	{
		public function BlockContainer(p_element:TimedTextElementBase)
		{
			element = p_element;
		}		
		
		public function get zIndex():Number
		{
			var val:Number = element.getComputedStyle("zIndex", null) as Number;
			if (val is Number)
			{
				return val as Number;                  
			}
			return (0); 
		}
		
		private var _referenceArea:Rectangle;
		private var _drawnArea:Rectangle;
		
		/** 
		 * Block containers generate a non null reference area.
		 */
		public override function referenceArea():Rectangle
		{
			return _referenceArea;
		}
		
		/** 
		 * Block containers generate a non null reference area.
		 */
		public override function actualArea():Rectangle
		{
			return _drawnArea;
		}
		
		/** 
		 * Retun a formatting function for this element.
		 */
		public override function createFormatter():Function
		{
			var func:Function = function(renderObject:IRenderObject):void
				{
					computeRelativeStyles(renderObject);
					this._referenceArea = new Rectangle();
					this._drawnArea = new Rectangle();
					var child:*;
					if (showBackgroundStyleProperty != "always")
					{
						var needToShow:Boolean = false;
						for each (child in children)
						{
							if (child.children.length > 0)
							{
								needToShow = true;
								break;
							}
						}
						if (!needToShow) return;
					}
					
					var visible:Boolean = this.visibilityStyleProperty;
					var display:String = this.displayStyleProperty;
					var opacity:Number = this.opacityStyleProperty;
					
					var backgroundColor:ColorExpression = this.backgroundColorStyleProperty as ColorExpression;
					var pad:PaddingThickness = this.calculatePaddingStyle(renderObject) as PaddingThickness;
					var origin:Origin = this.calculateOriginStyle(renderObject) as Origin;
					var extent:Extent = this.calculateExtentStyle(renderObject) as Extent;
					var clip:String = this.overflowStyleProperty;
					
					var bounds:Rectangle = new Rectangle();
					bounds.x = origin.y;
					bounds.y = origin.y;
					bounds.width = extent.width;
					bounds.height = extent.height;
					
					this.referenceArea.x = origin.x + pad.widthStart;
					this.referenceArea.y = origin.y + pad.widthBefore;
					this.referenceArea.height = extent.height - (pad.widthAfter + pad.widthBefore);
					this.referenceArea.width = extent.width - (pad.widthEnd + pad.widthStart);
					
					
					if (visible != "hidden" && display != "none")
					{
						// we do layout twice. Once without making any marks, but calculating the actual drawing sizes
						// the second to do the actual rendering.
						for (var pass:uint = 0; pass < 2; pass++)
						{
							if (pass > 0)
							{
								// we need to clip twice here. First time round to include the padding area
								if (clip == "hidden" || clip == "scroll")
								{  
									renderObject.pushClip(bounds);
									
								}
								
								if (0.0 <= opacity && opacity < 1.0)
								{   // hack - set opacity here so its the outer clip context that gets it.
									// byte level = (byte)(255 * opacity);
									renderObject.setOpacity(opacity);
								}
								renderObject.drawRectangle(backgroundColor, origin.x, origin.y, origin.x + extent.width, origin.y + extent.height);
								// clip for second time to content (after drawing background so padding gets drawn).
								if (clip == "hidden" || clip == "scroll")
								{  
									renderObject.pushClip(this.referenceArea);
								}
								// renderObject.DrawRectangle(backgroundColor, origin.x, origin.y, origin.x + extent.width, origin.y + extent.height);
							}
							var top:Number = this.referenceArea.y;
							var left:Number = this.referenceArea.y;
							var scrollHeight:Number = 1;  // blank in and blank out.
							//double scrollDuration = 1;
							
							for each (child in children)
							{
								// a block container only has one child - the block.
								// from CSS 14.2 - body should set the background of the 'canvas'
								// which is what the region is.
								// so pick up the block background here.
								var fmt:Block = child as Block;
								renderObject.drawRectangle(fmt.backgroundColorStyleProperty, origin.x, origin.y, origin.x + extent.width, origin.x + extent.height);
								
								//{ region compute display align
								/// To do - generalize to block progression direction
								var leftover:Number = this.referenceArea().height - fmt.actualArea().height;  // stacked height of all the children.
								var offset:Number = 0;
								
								switch (displayAlignStyleProperty)
								{
									case "center":
										offset = (leftover / 2);
										break;
									case "after":
										offset = leftover;
										break;
								}
								top += offset;
								
								//} endregion
								
								fmt.setStyle("#left", left);
								fmt.setStyle("#top", top);
								fmt.setStyle("#renderpass", pass);
								fmt.createFormatter()(renderObject);
								top += fmt.actualArea().height;
								scrollHeight = fmt.actualArea().height - this.referenceArea.height;
								if (clip == "scroll" && scrollHeight > 0)
								{
									renderObject.pushScroll(0, -scrollHeight);
								}
							}
							if (clip == "hidden" || clip == "scroll")
							{
								
								renderObject.popClip();
								renderObject.popClip();
							}
							
						}
					}
					
					return;
				};
			return func;		
		}
		
	}
}