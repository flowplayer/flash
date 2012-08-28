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
	import org.osmf.smpte.tt.model.RegionElement;
	import org.osmf.smpte.tt.model.SpanElement;
	import org.osmf.smpte.tt.model.TimedTextAttributeBase;
	import org.osmf.smpte.tt.model.TimedTextElementBase;
	import org.osmf.smpte.tt.rendering.IRenderObject;
	import org.osmf.smpte.tt.styling.AutoExtent;
	import org.osmf.smpte.tt.styling.AutoOrigin;
	import org.osmf.smpte.tt.styling.ColorExpression;
	import org.osmf.smpte.tt.styling.Colors;
	import org.osmf.smpte.tt.styling.Extent;
	import org.osmf.smpte.tt.styling.FontSize;
	import org.osmf.smpte.tt.styling.Inherit;
	import org.osmf.smpte.tt.styling.LineHeight;
	import org.osmf.smpte.tt.styling.NormalHeight;
	import org.osmf.smpte.tt.styling.Origin;
	import org.osmf.smpte.tt.styling.PaddingThickness;
	import org.osmf.smpte.tt.styling.TextDecorationAttributeValue;
	import org.osmf.smpte.tt.styling.TextOutline;
	import org.osmf.smpte.tt.styling.WritingMode;
	import org.osmf.smpte.tt.timing.TimeCode;
	import org.osmf.smpte.tt.timing.TreeType;
	
	public class FormattingObject extends TreeType
	{
		public function FormattingObject()
		{
		}
		
		/**
		 *  Formatter is a function which takes a rendering engine 
		 * and applies it to the element
		 *
		 * @param renderObject
		 */
		public var formatter:Function;
		
		private var _animations:Vector.<Animation> = new Vector.<Animation>();
		public function get animations():Vector.<Animation>
		{
			return _animations;
		}
		public function set animations(value:Vector.<Animation>):void
		{
			_animations = value;
		}
		
		private var _contextualFontSize:FontSize;
		public function get contextualFontSize():FontSize
		{
			return _contextualFontSize;
		}
		public function set contextualFontSize(value:FontSize):void
		{
			_contextualFontSize = value;
		}
		
		/**
		 * Get the region for this formatting object
		 * 
		 * @returns id of the region to format into
		 */
		public function get regionId():String
		{
			/// region isnt a style property per se, but it behaves a bit like one.
			/// so thats where we store it
			return _element.getComputedStyle("region", null) as String;	
		}
		
		public function get textOutlineStyleProperty():TextOutline
		{
			var outline:TextOutline = _element.getComputedStyle("textOutline", assignedRegion) as TextOutline;
			return outline;
		}
		
		public function get showBackgroundStyleProperty():String
		{
			return _element.getComputedStyle("showBackground", null) as String;
		}
		
		public function get renderPassProperty():int
		{
			return _element.getComputedStyle("#renderpass", assignedRegion) as int;
		}
		
		public function get topStyleProperty():Number
		{
			return _element.getComputedStyle("#top", assignedRegion) as Number;
		}
		
		public function get leftStyleProperty():Number
		{
			return _element.getComputedStyle("#left", assignedRegion) as Number;	
		}
		
		public function get preserveStyleProperty():Boolean
		{
			return _element.getComputedStyle("#preserve", null) as Boolean;
		}
		
		public function get colorStyleProperty():ColorExpression
		{
			var property:ColorExpression = _element.getComputedStyle("color", assignedRegion) as ColorExpression;
			var c:ColorExpression = (property != null) ? property : Colors.Black;
			return c;
		}
		
		public function get backgroundColorStyleProperty():ColorExpression { 
			return getBackgroundColorStyle();
		}
		
		private function getBackgroundColorStyle():ColorExpression
		{
			var e:*;
			
			// anonymous spans do inherit if they.
			if (_element is AnonymousSpanElement)
			{
				var p:SpanElement = _element.parent as SpanElement;
				if (p != null)
				{
					e = p.getReferentStyle("backgroundColor");
				}
				else
				{
					e = Colors.Transparent;
				}
			}
			else
			{
				e = _element.getReferentStyle("backgroundColor");
			}
			
			if(e is Inherit)
			{
				e = _element.getComputedStyle("backgroundColor", assignedRegion);
			}
			
			if (e != null && e is ColorExpression)
			{
				return e as ColorExpression;
			}
			return Colors.Transparent;
		}
		
		public function get displayStyleProperty():String
		{
			return _element.getComputedStyle("display", assignedRegion) as String;
		}
		
		public function get directionStyleProperty():String
		{
			var direction:String = _element.getComputedStyle("direction", assignedRegion) as String;
			if (direction == "auto")
			{
				// then author hasnt set it, defer to writing mode
				var mode:WritingMode = writingModeStyleProperty;
				return (mode == WritingMode.RIGHT_LEFT_TOP_BOTTOM) ? "rtl" : "ltr";
			}
			else
			{
				return direction;
			}
		}
		
		public function get unicodeBidirectionStyleProperty():String
		{
			return _element.getComputedStyle("unicodeBidi", assignedRegion) as String;
		}
		
		public function get displayAlignStyleProperty():String
		{
			return _element.getComputedStyle("displayAlign", assignedRegion) as String;
		}
		
		public function get opacityStyleProperty():Number
		{
			return _element.getComputedStyle("opacity", assignedRegion) as Number;
		}
		
		public function get textAlignStyleProperty():String
		{
			return _element.getComputedStyle("textAlign", assignedRegion) as String;
		}
		
		public function get textDecorationStyleProperty():TextDecorationAttributeValue
		{
			return _element.getComputedStyle("textDecoration", assignedRegion) as TextDecorationAttributeValue;
		}
		
		public function get writingModeStyleProperty():WritingMode
		{
			// lrtb | rltb | tbrl | tblr | lr | rl | tb
			var wm:WritingMode = WritingMode.LEFT_RIGHT_TOP_BOTTOM;
			switch (_element.getComputedStyle("writingMode", assignedRegion) as String)
			{
				case "lrtb":
				case "lr":
					wm = WritingMode.LEFT_RIGHT_TOP_BOTTOM;
					break;
				case "rltb":
				case "rl":
					wm = WritingMode.RIGHT_LEFT_TOP_BOTTOM;
					break;
				case "tbrl":
				case "tb":
					wm = WritingMode.TOP_BOTTOM_RIGHT_LEFT;
					break;
				case "tblr":
					wm = WritingMode.TOP_BOTTOM_LEFT_RIGHT;
					break;
				default:
					wm = WritingMode.LEFT_RIGHT_TOP_BOTTOM;
					break;
			}
			
			return wm;
		}
		
		public function get visibilityStyleProperty():String
		{
			return _element.getComputedStyle("visibility", assignedRegion) as String;
		}
		
		public function get overflowStyleProperty():String
		{
			return _element.getComputedStyle("overflow", assignedRegion) as String;
		}
		public function get wrapOptionStyleProperty():Boolean
		{
			var wrap:Boolean;
			var wrapOption:String = _element.getComputedStyle("wrapOption", assignedRegion) as String;
			wrap = (wrapOption == "wrap");
			return wrap;
		}
		
		public function calculateLineHeightStyle(renderObject:IRenderObject):LineHeight
		{
			var lineHeight:LineHeight = _element.getComputedStyle("lineHeight", assignedRegion) as LineHeight;
			if (lineHeight is NormalHeight)
			{
				if (this.children.length == 0)
				{
					lineHeight = new LineHeight(_contextualFontSize.fontHeight);
				}
				else
				{
					lineHeight = this.maxChildFontSize(renderObject);
				}
			}
			else
			{
				lineHeight.setContext(renderObject.width(), renderObject.height());
				lineHeight.setFontContext(_contextualFontSize.fontWidth, _contextualFontSize.fontHeight);
			}
			return lineHeight;
		}
		
		public function calculateOriginStyle(renderObject:IRenderObject):Origin
		{
			var origin:Origin = _element.getComputedStyle("origin", assignedRegion) as Origin;
			if (origin as AutoOrigin != null)
			{
				origin = new Origin(0, 0);  // renderObject origin?
			}
			else
			{
				origin.setContext(renderObject.width(), renderObject.height());
				origin.setFontContext(_contextualFontSize.fontWidth, _contextualFontSize.fontHeight);
			}
			return origin;
		}
		
		public function calculatePaddingStyle(renderObject:IRenderObject):PaddingThickness
		{
			var pad:PaddingThickness = _element.getComputedStyle("padding", assignedRegion) as PaddingThickness;
			pad.setContext(renderObject.width(), renderObject.height());
			pad.setFontContext(_contextualFontSize.fontWidth, _contextualFontSize.fontHeight);
			return pad;
		}
		
		public function calculateExtentStyle(renderObject:IRenderObject):Extent
		{
			var extent:Extent = _element.getComputedStyle("extent", assignedRegion) as Extent;
			if (extent as AutoExtent != null)
			{
				extent = new Extent(renderObject.width(), renderObject.height());
			}
			else
			{
				extent.setContext(renderObject.width(), renderObject.height());
				extent.setFontContext(_contextualFontSize.fontWidth, _contextualFontSize.fontHeight);
			}
			return extent;
		}      
		
		public function calculateFontSizeStyle(renderObject:IRenderObject):FontSize
		{
			var fontSizeSpec:String = _element.getComputedStyle("fontSize", assignedRegion) as String;
			var fontSize:FontSize = new FontSize(fontSizeSpec, _contextualFontSize, renderObject.width(), renderObject.height());
			return fontSize;
		}
		
		/**
		 * Remove any subtrees which are not selected into the region.
		 * @param regionId region to select
		 */
		public function prune(regionId:String):void
		{
			var unprunedChildren:Vector.<TreeType> = children.slice();
			children.length = 0;
			
			for each (var child:TreeType in unprunedChildren)
			{
				var fo:FormattingObject = child as FormattingObject;
				fo.prune(regionId);
				var foRegionID:String = fo.regionId;
				if ((regionId == "default region")
					|| ((!foRegionID || foRegionID.length==0) && fo.children.length > 0)
					|| (foRegionID == regionId))
				{
					children.push(fo);
				}
			}
		}
		
		/**
		 * Calculate the largest fontsize of children. 
		 * If no children, use context font.
		 * 
		 * @param renderObject
		 */
		private function maxChildFontSize(renderObject:IRenderObject):LineHeight
		{
			var fontHeight:Number = 0;
			for each (var child:* in children)
			{
				var fo:FormattingObject = child as FormattingObject;
				var fontSizeSpec:String = fo.element.getComputedStyle("fontSize", assignedRegion) as String;
				var fontSize:FontSize = new FontSize(fontSizeSpec, _contextualFontSize, renderObject.width(), renderObject.height());
				fontHeight = Math.max(fontHeight, fontSize.fontHeight);
			}
			return new LineHeight(fontHeight);
		}
		
		/**
		 * Calculate the context font size.
		 * 
		 * @param renderObject
		 */
		public function computeRelativeStyles(renderObject:IRenderObject):void
		{
			if (parent == null || this is Root || _element == null)
			{
				_contextualFontSize =new FontSize("1c 1c", null, renderObject.width(), renderObject.height());
			}
			else
			{
				var fo:FormattingObject = parent as FormattingObject;
				var contextFontSize:FontSize = fo.contextualFontSize;
				var fontSize:String = _element.getReferentStyle("fontSize") as String;
				if (fontSize == null)
				{
					_contextualFontSize = contextFontSize;
				}
				else
				{
					_contextualFontSize = new FontSize(fontSize, contextFontSize, renderObject.width(), renderObject.height());
				}
			}
		}
		
		/**
		 * reference to the underlying timed text element
		 */
		private var _element:TimedTextElementBase;
		public function get element():TimedTextElementBase
		{
			return _element;
		}
		public function set element(value:TimedTextElementBase):void
		{
			_element = value;
		}
		
		/**
		 * Return the currently assigned region for this Formatting object
		 * 
		 * @returns
		 */
		public function get assignedRegion():RegionElement
		{
			
			if (this is BlockContainer)
			{
				return element as RegionElement;
			}
			else if (parent != null)
			{
				return (parent as FormattingObject).assignedRegion;
			}
			return null;
		}
		
		/**
		 *  Return a formatting function for this element.
		 * 
		 * @returns
		 */
		public function createFormatter():Function
		{
			var func:Function = function(renderObject:IRenderObject):void
			{
				for each (var child:* in children)
				{
					var fmt:FormattingObject = child as FormattingObject;
					fmt.createFormatter()(renderObject);
				}
				return;
			};
			return func;
		}
		
		/**
		 * Override animated attributes.
		 */
		public function applyAnimations():void
		{
			var setOnce:Boolean = false;  // only record the first old value, in case multiple animations are applied
			for each (var animation:Animation in animations)
			{
				for each (var attribute:TimedTextAttributeBase in animation.element.attributes)
				{
					if (attribute.isStyleAttribute())
					{
						var property:String = attribute.localName;
						var newvalue:Object = animation.element.getReferentStyle(property);
						var oldValue:Object = this.element.getReferentStyle(property);
						if (oldValue != null && !setOnce)
						{
							this.element.setLocalStyle("#_" + property, oldValue);
							setOnce = true;
						}
						this.element.setLocalStyle(property, newvalue);
					}
				}
			}
		}
		
		/**
		 * Undo all the animated overrides.
		 */
		public function removeAppliedAnimations():void
		{
			for each (var animation:Animation in animations)
			{
				for each (var attribute:TimedTextAttributeBase in animation.element.attributes)
				{
					if (attribute.isStyleAttribute())
					{
						var property:String = attribute.localName;
						var oldValue:Object = this.element.getReferentStyle("#_" + property);
						if (oldValue != null)
						{
							this.element.setLocalStyle(property, oldValue);
						}
						else
						{
							this.element.clearLocalStyle(property);
						}
					}
				}
			}
		}
		
		/**
		 * The reference area is where this element computes its dimensions from
		 */
		public function referenceArea():Rectangle
		{
			return new Rectangle();
		}
		
		// ought to make this a property, but its parts are set outside here.
		protected var actualDrawing:Rectangle = new Rectangle();
		
		/**
		 * The ActualArea area is where this element draws itself into
		 */
		public function actualArea():Rectangle
		{
			return actualDrawing;
		}
		
		/**
		 * return the formatting object which represents the timed text tree at the given time
		 *
		 * @param timeSpan
		 * @param tree
		 */
		public static function renderTree(timeSpan:TimeCode, tree:TimedTextElementBase):FormattingObject
		{
			
			var root:FormattingObject = tree.root.getFormattingObject(timeSpan) as FormattingObject;
			return root;
		}
		
		/**
		 * Set a local style on the element
		 * @param property
		 * @param value
		 */
		public function setStyle(property:String, value:*):void
		{
			_element.setLocalStyle(property, value);
		}
		
		/**
		 * clear a local style
		 * 
		 * @param property
		 */
		public function clearStyle(property:String):void
		{
			_element.clearLocalStyle(property);
		}
	}
}