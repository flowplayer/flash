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
package org.osmf.smpte.tt.parsing
{
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.formats.TextDecoration;
	import flashx.textLayout.formats.WhiteSpaceCollapse;
	
	import org.osmf.smpte.tt.captions.DisplayAlign;
	import org.osmf.smpte.tt.captions.Overflow;
	import org.osmf.smpte.tt.captions.ShowBackground;
	import org.osmf.smpte.tt.captions.TextAlignment;
	import org.osmf.smpte.tt.captions.TimedTextStyle;
	import org.osmf.smpte.tt.model.RegionElement;
	import org.osmf.smpte.tt.model.TimedTextElementBase;
	import org.osmf.smpte.tt.styling.ColorExpression;
	import org.osmf.smpte.tt.styling.Extent;
	import org.osmf.smpte.tt.styling.FontSize;
	import org.osmf.smpte.tt.styling.FontStyleAttributeValue;
	import org.osmf.smpte.tt.styling.FontWeightAttributeValue;
	import org.osmf.smpte.tt.styling.LineHeight;
	import org.osmf.smpte.tt.styling.NormalHeight;
	import org.osmf.smpte.tt.styling.NumberPair;
	import org.osmf.smpte.tt.styling.Origin;
	import org.osmf.smpte.tt.styling.PaddingThickness;
	import org.osmf.smpte.tt.styling.TextDecorationAttributeValue;
	import org.osmf.smpte.tt.styling.TextOutline;
	import org.osmf.smpte.tt.styling.Visibility;
	import org.osmf.smpte.tt.styling.WrapOption;
	import org.osmf.smpte.tt.styling.WritingMode;
	import org.osmf.smpte.tt.vocabulary.Styling;
	
	/**
	 * Parses style information about a timed text marker.
	 * <p>Style information determines the appearance of the marker text.
	 * This class uses the style information defined in XML and creates corresponding 
	 * TimedTextStyle objects. </p>
	 * <p>Styles are defined in the W3C TTAF 1.0 specification.</p>
	 */
	public class TimedTextStyleParser
	{
		private static const defaultStyle:TimedTextStyle = new TimedTextStyle();
		
		public function TimedTextStyleParser()
		{
		}
		
		internal static function isValidAnimationPropertyName(name:String):Boolean
		{
			var ret:Boolean = false;
			switch (name)
			{
				case "backgroundColor":
					ret = true;
					break;
				case "color":
					ret = true;
					break;
				case "displayAlign":
					ret = true;
					break;
				case "display":
					ret = true;
					break;
				case "extent":
					ret = true;
					break;
				case "fontFamily":
					ret = true;
					break;
				case "fontSize":
					ret = true;
					break;
				case "fontStyle":
					ret = true;
					break;
				case "fontWeight":
					ret = true;
					break;
				case "lineHeight":
					ret = true;
					break;
				case "lineThrough":
					ret = true;
					break;
				case "opacity":
					ret = true;
					break;
				case "origin":
					ret = true;
					break;
				case "overflow":
					ret = true;
					break;
				case "padding":
					ret = true;
					break;
				case "showBackground":
					ret = true;
					break;
				case "textAlign":
					ret = true;
					break;
				case "textDecoration":
					ret = true;
					break;
				case "textOutline":
					ret = true;
					break;
				case "visibility":
					ret = true;
					break;
				case "wrapOption":
					ret = true;
					break;
				case "zIndex":
					ret = true;
					break;
			}
			return ret;
		}
		
		private static var _numberPairXref:Dictionary = new Dictionary();
		public static function getNumberPair(value:String):NumberPair
		{
			if (_numberPairXref[value] !== undefined)
			{
				return new NumberPair(_numberPairXref[value]);
			}
			else
			{
				var pair:NumberPair = new NumberPair(value);
				_numberPairXref[value] = pair;
				return pair;
			}
		}
		
		// captions will usually use a handful of colors, we'll cache them to reduce resource usage.
		private static var _cachedBrushes:Dictionary = new Dictionary();
		public static function getCachedBrush(src:ColorExpression):ColorExpression
		{
			if (_cachedBrushes[src.argb] !== undefined)
			{
				return _cachedBrushes[src.argb];
			}
			else
			{
				_cachedBrushes[src.argb] = src;
				return src;
			}
		}
		
		internal static function mapStyle(styleElement:TimedTextElementBase, region:RegionElement):TimedTextStyle
		{
			var style:TimedTextStyle = new TimedTextStyle();
			
			if(styleElement.id)	style.styleName = styleElement.id;
			
			//  backgroundColor
			var backgroundColor:ColorExpression = 
				styleElement.getComputedStyle(Styling.TTML_STYLING_BACKGROUNDCOLOR.localName, region) as ColorExpression;
			style.backgroundColor = (backgroundColor!=null) 
				? getCachedBrush(backgroundColor).color 
				: defaultStyle.backgroundColor;
			style.backgroundAlpha = (backgroundColor!=null) 
				? getCachedBrush(backgroundColor).alpha 
				: defaultStyle.backgroundAlpha;
			
			//  color
			var color:ColorExpression = 
				styleElement.getComputedStyle(Styling.TTML_STYLING_COLOR.localName, region) as ColorExpression;
			style.color = (color!=null) 
				? getCachedBrush(color).color 
				: defaultStyle.color;
			style.textAlpha = (color!=null) 
				? getCachedBrush(color).alpha 
				: defaultStyle.textAlpha;
			
			// direction
			var direction:String = 
				styleElement.getComputedStyle(Styling.TTML_STYLING_DIRECTION.localName, region) as String;
			style.direction = (direction=="rtl") 
				? direction
				: defaultStyle.direction;
			
			// display
			var display:String =
				styleElement.getComputedStyle(Styling.TTML_STYLING_DISPLAY.localName, region) as String;
			style.display =(display!=null && display=="none")
				? display
				: defaultStyle.display;
			
			// displayAlign
			var displayAlign:String =
				styleElement.getComputedStyle(Styling.TTML_STYLING_DISPLAYALIGN.localName, region) as String;
			var parsedDisplayAlign:DisplayAlign = DisplayAlign.parseConstant(displayAlign);
			style.displayAlign = (parsedDisplayAlign!=null)
				? parsedDisplayAlign.value
				: defaultStyle.displayAlign;
			
			// extent
			var extent:org.osmf.smpte.tt.styling.Extent = 
				styleElement.getComputedStyle(Styling.TTML_STYLING_EXTENT.localName, region) as org.osmf.smpte.tt.styling.Extent;
			if (extent!=null && !extent.isEmpty())
			{
				style.extent = extent;
			} else
			{
				style.extent = defaultStyle.extent;
			}
			
			// fontFamily
			var fontFamily:String = 
				styleElement.getComputedStyle(Styling.TTML_STYLING_FONTFAMILY.localName, region) as String;			
			style.fontFamily = (fontFamily && fontFamily.length>0 && fontFamily!="default")
				? fontFamily
				: defaultStyle.fontFamily;
			
			// fontSize
			var ttFontSize:FontSize= 
				styleElement.getComputedStyle(Styling.TTML_STYLING_FONTSIZE.localName, region) as FontSize;
			if(ttFontSize!=null && ttFontSize is FontSize)
			{
				style.ttFontSize = ttFontSize;
			} else
			{
				style.ttFontSize = defaultStyle.ttFontSize;
			}
			
			// fontStyle
			var fontStyle:FontStyleAttributeValue = 
				styleElement.getComputedStyle(Styling.TTML_STYLING_FONTSTYLE.localName, region) as FontStyleAttributeValue;
			if(fontStyle!=null && fontStyle is FontStyleAttributeValue)
			{
				style.fontStyle = (fontStyle == FontStyleAttributeValue.ITALIC ||
						fontStyle == FontStyleAttributeValue.OBLIQUE ||
						fontStyle == FontStyleAttributeValue.REVERSE_OBLIQUE)
					? FontPosture.ITALIC
					: defaultStyle.fontStyle;
			} else
			{
				style.fontStyle = defaultStyle.fontStyle;
			}
			
			// fontWeight
			var fontWeight:FontWeightAttributeValue = 
				styleElement.getComputedStyle(Styling.TTML_STYLING_FONTWEIGHT.localName, region) as FontWeightAttributeValue;
			style.fontWeight = (fontWeight!=null && (fontWeight == FontWeightAttributeValue.BOLD))
				? FontWeight.BOLD
				: defaultStyle.fontWeight;
			
			// lineHeight
			var ttLineHeight:LineHeight = 
				styleElement.getComputedStyle(Styling.TTML_STYLING_LINEHEIGHT.localName, region) as LineHeight;
			
			style.ttLineHeight = (ttLineHeight!=null && !(ttLineHeight is NormalHeight))
				? ttLineHeight
				: defaultStyle.ttLineHeight;
			
			// opacity
			var opacity:Number = 
				styleElement.getComputedStyle(Styling.TTML_STYLING_OPACITY.localName, region) as Number;
			style.opacity = (!isNaN(opacity) && opacity>=0)
				? opacity
				: defaultStyle.opacity;
			
			// origin
			var origin:org.osmf.smpte.tt.styling.Origin = 
				styleElement.getComputedStyle(Styling.TTML_STYLING_ORIGIN.localName, region) as org.osmf.smpte.tt.styling.Origin;
			if(origin!=null && !origin.isEmpty()){
				style.origin = origin;
			} else {
				style.origin = defaultStyle.origin;
			}			
			
			// overflow
			var overflow:String = styleElement.getComputedStyle(Styling.TTML_STYLING_OVERFLOW.localName, region) as String;
			var parsedOverflow:Overflow = Overflow.parseConstant(overflow);
			style.overflow = (parsedOverflow!=null)
				? parsedOverflow.value
				: defaultStyle.overflow;
			
			var padding:org.osmf.smpte.tt.styling.PaddingThickness = 
				styleElement.getComputedStyle(Styling.TTML_STYLING_PADDING.localName, region) as org.osmf.smpte.tt.styling.PaddingThickness;			
			if(padding!=null && !padding.isEmpty()){
				style.padding = padding;
			} else {
				style.padding = defaultStyle.padding;
			}
			
			// showBackground
			var showBackground:String =
				styleElement.getComputedStyle(Styling.TTML_STYLING_SHOWBACKGROUND.localName, region) as String;
			var parsedShowBackground:ShowBackground = ShowBackground.parseConstant(showBackground);
			style.showBackground = parsedShowBackground!=null
				? parsedShowBackground.value
				: defaultStyle.showBackground;
			
			// textAlign
			var textAlign:String =
				styleElement.getComputedStyle(Styling.TTML_STYLING_TEXTALIGN.localName, region) as String;			
			var parsedTextAlign:TextAlignment = TextAlignment.parseConstant(textAlign);
			style.textAlign = (parsedTextAlign!=null)
				? parsedTextAlign.value
				: defaultStyle.textAlign;
			
			// textDecoration			
			var textDecoration:TextDecorationAttributeValue = 
				styleElement.getComputedStyle(Styling.TTML_STYLING_TEXTDECORATION.localName, region) as TextDecorationAttributeValue;
			if(textDecoration)
			{
				switch(textDecoration)
				{
					case TextDecorationAttributeValue.UNDERLINE:
						style.textDecoration = TextDecoration.UNDERLINE;
						break;
					case TextDecorationAttributeValue.NO_UNDERLINE:
						style.textDecoration = TextDecoration.NONE;
						break;
				}
			}
			
			var lineThrough:TextDecorationAttributeValue = 
				styleElement.getComputedStyle("lineThrough", region) as TextDecorationAttributeValue;
			if(lineThrough)
			{
				switch(lineThrough)
				{
					case TextDecorationAttributeValue.LINE_THROUGH:
						style.lineThrough = true;
						break;
					case TextDecorationAttributeValue.NO_LINE_THROUGH:
						style.lineThrough = false;
						break;
				}
			}
			
			// textOutline
			var textOutline:TextOutline =
				styleElement.getComputedStyle(Styling.TTML_STYLING_TEXTOUTLINE.localName, region) as TextOutline;
			style.textOutline = (textOutline!=null)
				? textOutline
				: defaultStyle.textOutline;
			
			// unicodeBidi
			var unicodeBidi:String = 
				styleElement.getComputedStyle(Styling.TTML_STYLING_UNICODEBIDI.localName, region) as String;
			style.unicodeBidi = (unicodeBidi!=null 
				&& (unicodeBidi=="embed" || unicodeBidi=="bidiOverride"))
				? unicodeBidi
				: defaultStyle.unicodeBidi;
			
			// visiblility
			var visibility:String =
				styleElement.getComputedStyle(Styling.TTML_STYLING_VISIBILITY.localName, region) as String;
			style.visibility = (visibility && visibility==Visibility.HIDDEN.value)
				? visibility
				: defaultStyle.visibility;
			
			// whiteSpaceCollapse
			style.whiteSpaceCollapse = 
				((styleElement.getComputedStyle("space", region) as String)=="preserve")
				? WhiteSpaceCollapse.PRESERVE
				: WhiteSpaceCollapse.COLLAPSE;
			
			// wrapOption
			var wrapOption:String =
				styleElement.getComputedStyle(Styling.TTML_STYLING_WRAPOPTION.localName, region) as String;
			var parsedWrapOption:WrapOption = WrapOption.parseConstant(wrapOption);
			style.wrapOption = (parsedWrapOption!=null)
				? parsedWrapOption.value
				: defaultStyle.wrapOption;
			
			// writingMode
			var writingMode:String =
				styleElement.getComputedStyle(Styling.TTML_STYLING_WRITINGMODE.localName, region) as String;
			var parsedWritingMode:WritingMode = WritingMode.parseConstant(writingMode);
			style.writingMode = (parsedWritingMode!=null)
				? parsedWritingMode.value
				: defaultStyle.writingMode;
			
			// zIndex
			var zIndex:* = styleElement.getComputedStyle(Styling.TTML_STYLING_ZINDEX.localName, region);
			try
			{
				if (!(zIndex is String))
				{
					var tmp:Number = Number(zIndex);
					style.zIndex = int(tmp);
				}
				else
				{
					style.zIndex = 0;
				}
			}
			catch(e:Error)
			{
				style.zIndex = 0;
			}
			return style;
		}
	}
}