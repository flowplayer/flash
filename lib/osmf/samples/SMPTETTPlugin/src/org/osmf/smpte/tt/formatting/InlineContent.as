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
	
	import org.osmf.smpte.tt.model.AnonymousSpanElement;
	import org.osmf.smpte.tt.model.BrElement;
	import org.osmf.smpte.tt.model.TimedTextElementBase;
	import org.osmf.smpte.tt.rendering.IRenderObject;
	import org.osmf.smpte.tt.rendering.Unicode;
	import org.osmf.smpte.tt.styling.Extent;
	import org.osmf.smpte.tt.styling.Font;
	import org.osmf.smpte.tt.styling.FontSize;
	import org.osmf.smpte.tt.styling.FontStyleAttributeValue;
	import org.osmf.smpte.tt.styling.FontWeightAttributeValue;

	public class InlineContent extends FormattingObject
	{
		public function InlineContent(p_element:TimedTextElementBase)
		{
			this.element = p_element;
			_original_text = content;
		}
		
		private var _original_text:String;
				
		public function get content():String
		{
			var e:AnonymousSpanElement = element as AnonymousSpanElement;
			return e.text;
		}
		
		
		/**
		 * clear all breaks in the text.
		 */
		public function clearBreaks():void
		{
			if (element is BrElement) return;  // don't clean explicit breaks;
			if (element is AnonymousSpanElement)
			{
				var e:AnonymousSpanElement = element as AnonymousSpanElement;
				e.text = _original_text;
			}
		}
		
		/**
		 * Insert breaks in the text at given positions.
		 */
		public function insertBreaks(breaks:Vector.<int>):void
		{
			if (element is BrElement) return;  // don't touch explicit breaks;
			if (element is AnonymousSpanElement)
			{
				var e:AnonymousSpanElement = element as AnonymousSpanElement;
				var offset:int = 0;
				for each (var n:int in breaks)
				{
					var newtext:String = e.text;
					
					// insert a newline
					if (Unicode.BreakOpportunities.indexOf(newtext.charAt(n + offset))>=0)
					{
						// replace the breaking char with a newline. 
						if (Unicode.VisibleBreakChar.indexOf(newtext.charAt(n + offset))>=0)
						{
							// we should leave it in place if its a visible breaking opp.                           
							newtext = newtext.slice(0,n+offset).concat("\n",newtext.substring(n+offset,newtext.length));
							offset++;
						}
						else
						{
							newtext = newtext.slice(0,n+offset).concat("\n",newtext.substring(n+offset+1,newtext.length));
						}
					}
					e.text = newtext;
				}
			}
		}
		
		/**
		 * Return a formatting function for this element.
		 */		
		public override function createFormatter():Function
		{
			var func:Function = function(renderObject:IRenderObject):void
				{
					return;
				};
			return func;
		}
		
		public override function actualArea():Rectangle
		{
			return actualDrawing;
		}
		
		/**
		 * Measure the width of content.
		 *  
		 * @param renderObject
		 */
		internal function measureText(p_measureText:String, renderObject:IRenderObject, font:Font):Extent
		{
			var area:Rectangle = renderObject.computeTextExtent(p_measureText, font);
			actualDrawing.width = area.width;
			actualDrawing.height = area.height;
			return new Extent(area.width, area.height);
		}
		
		public function getFont(renderObject:IRenderObject):Font
		{
			computeRelativeStyles(renderObject);
			var fontFamily:String = element.getComputedStyle("fontFamily", assignedRegion) as String;
			var fontSizeSpec:String = element.getComputedStyle("fontSize", assignedRegion) as String;
			var fontSize:FontSize = new FontSize(fontSizeSpec, contextualFontSize, renderObject.width(), renderObject.height());
			var fontWeight:FontWeightAttributeValue = element.getComputedStyle("fontWeight", assignedRegion) as FontWeightAttributeValue;
			var fontStyle:FontStyleAttributeValue = element.getComputedStyle("fontStyle", assignedRegion) as FontStyleAttributeValue;
			var font:Font = new Font(fontFamily, fontSize.fontHeight, fontWeight, fontStyle);
			return font;
		}
	}
}