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
package org.osmf.smpte.tt.captions
{
	import flash.utils.getTimer;
	
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.Category;
	import flashx.textLayout.formats.Direction;
	import flashx.textLayout.formats.FormatValue;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.LineBreak;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.property.Property;
	import flashx.textLayout.tlf_internal;
	
	import org.osmf.smpte.tt.styling.Extent;
	import org.osmf.smpte.tt.styling.FontSize;
	import org.osmf.smpte.tt.styling.LineHeight;
	import org.osmf.smpte.tt.styling.Origin;
	import org.osmf.smpte.tt.styling.PaddingThickness;
	import org.osmf.smpte.tt.styling.TextOutline;
	import org.osmf.smpte.tt.styling.Visibility;
	import org.osmf.smpte.tt.styling.WrapOption;
	import org.osmf.smpte.tt.styling.WritingMode;
	
	use namespace tlf_internal;

	public class TimedTextStyle extends TextLayoutFormat 
		implements ITextLayoutFormat
	{ 
		private var _id:String;
		
		/** @private */
		static public const displayProperty:Property = Property.NewEnumStringProperty(
			"display",FormatValue.AUTO,true,Vector.<String>([Category.CONTAINER,Category.PARAGRAPH,Category.CHARACTER])
			,FormatValue.AUTO
			,FormatValue.NONE
		);
		
		/** @private */
		static public const displayAlignProperty:Property = Property.NewEnumStringProperty(
			"displayAlign",DisplayAlign.Before.value,true,Vector.<String>([Category.CONTAINER,Category.PARAGRAPH,Category.CHARACTER])
			,DisplayAlign.Before.value
			,DisplayAlign.Center.value
			,DisplayAlign.After.value
		);
		
		// private var _extent:Extent = Extent.Auto;
		// private var _ttFontSize:Length = new Length(LengthUnit.Pixel,20);
		// private var _ttLineHeight:Length = null;
		
		/** @private */
		static public const opacityProperty:Property = Property.NewNumberProperty(
			"opacity",1,false,Vector.<String>([Category.CONTAINER]),0,1
		);
		
		// private var _origin:Origin = Origin.Empty;
		
		/** @private */
		static public const overflowProperty:Property = Property.NewEnumStringProperty(
			"overflow",Overflow.Hidden.value,true,Vector.<String>([Category.PARAGRAPH,Category.CHARACTER])
			,Overflow.Hidden.value
			,Overflow.Visible.value
			,Overflow.Dynamic.value
		);
		
		// private var _padding:Padding = Padding.Empty;
		
		/** @private */
		static public const showBackgroundProperty:Property = Property.NewEnumStringProperty(
			"showBackground",ShowBackground.Always.value,true,Vector.<String>([Category.PARAGRAPH,Category.CHARACTER])
			,ShowBackground.Always.value
			,ShowBackground.WhenActive.value
		);
		
		
		/** @private */
		static public const unicodeBidiProperty:Property = Property.NewEnumStringProperty(
			"unicodeBidi","normal",true,Vector.<String>([Category.PARAGRAPH,Category.CHARACTER])
			,"normal"
			,"embed"
			,"bidiOverride"
		);
		
		/** @private */
		static public const visibilityProperty:Property = Property.NewEnumStringProperty(
			"visibility",Visibility.VISIBLE.value,true,Vector.<String>([Category.CONTAINER,Category.PARAGRAPH,Category.CHARACTER])
			,Visibility.VISIBLE.value
			,Visibility.HIDDEN.value
		);
		
		/** @private */
		static public const wrapOptionProperty:Property = Property.NewEnumStringProperty(
			"wrapOption",WrapOption.WRAP.value,false,Vector.<String>([Category.CHARACTER])
			,WrapOption.WRAP.value
			,WrapOption.NOWRAP.value
		);
		
		/** @private */
		static public const writingModeProperty:Property = Property.NewEnumStringProperty(
			"writingMode",WritingMode.LEFT_RIGHT_TOP_BOTTOM.value,false,Vector.<String>([Category.CONTAINER])
			,WritingMode.LEFT_RIGHT_TOP_BOTTOM.value
			,WritingMode.RIGHT_LEFT_TOP_BOTTOM.value
			,WritingMode.TOP_BOTTOM_LEFT_RIGHT.value
			,WritingMode.TOP_BOTTOM_RIGHT_LEFT.value
		);
		
		/** @private */
		static public const zIndexProperty:Property = Property.NewUintOrEnumProperty(
			"zIndex",FormatValue.AUTO,false,Vector.<String>([Category.CONTAINER])
			,FormatValue.AUTO
		);
		
		static private var _description:Object = {
			color:colorProperty
			, backgroundColor:backgroundColorProperty
			, lineThrough:lineThroughProperty
			, textAlpha:textAlphaProperty
			, backgroundAlpha:backgroundAlphaProperty
			, fontSize:fontSizeProperty
			, baselineShift:baselineShiftProperty
			, trackingLeft:trackingLeftProperty
			, trackingRight:trackingRightProperty
			, lineHeight:lineHeightProperty
			, breakOpportunity:breakOpportunityProperty
			, digitCase:digitCaseProperty
			, digitWidth:digitWidthProperty
			, dominantBaseline:dominantBaselineProperty
			, kerning:kerningProperty
			, ligatureLevel:ligatureLevelProperty
			, alignmentBaseline:alignmentBaselineProperty
			, locale:localeProperty
			, typographicCase:typographicCaseProperty
			, fontFamily:fontFamilyProperty
			, textDecoration:textDecorationProperty
			, fontWeight:fontWeightProperty
			, fontStyle:fontStyleProperty
			, whiteSpaceCollapse:whiteSpaceCollapseProperty
			, renderingMode:renderingModeProperty
			, cffHinting:cffHintingProperty
			, fontLookup:fontLookupProperty
			, textRotation:textRotationProperty
			, textIndent:textIndentProperty
			, paragraphStartIndent:paragraphStartIndentProperty
			, paragraphEndIndent:paragraphEndIndentProperty
			, paragraphSpaceBefore:paragraphSpaceBeforeProperty
			, paragraphSpaceAfter:paragraphSpaceAfterProperty
			, textAlign:textAlignProperty
			, textAlignLast:textAlignLastProperty
			, textJustify:textJustifyProperty
			, justificationRule:justificationRuleProperty
			, justificationStyle:justificationStyleProperty
			, direction:directionProperty
			, wordSpacing:wordSpacingProperty
			, tabStops:tabStopsProperty
			, leadingModel:leadingModelProperty
			, columnGap:columnGapProperty
			, paddingLeft:paddingLeftProperty
			, paddingTop:paddingTopProperty
			, paddingRight:paddingRightProperty
			, paddingBottom:paddingBottomProperty
			, columnCount:columnCountProperty
			, columnWidth:columnWidthProperty
			, firstBaselineOffset:firstBaselineOffsetProperty
			, verticalAlign:verticalAlignProperty
			, blockProgression:blockProgressionProperty
			, lineBreak:lineBreakProperty
			, listStyleType:listStyleTypeProperty
			, listStylePosition:listStylePositionProperty
			, listAutoPadding:listAutoPaddingProperty
			, clearFloats:clearFloatsProperty
			, styleName:styleNameProperty
			, linkNormalFormat:linkNormalFormatProperty
			, linkActiveFormat:linkActiveFormatProperty
			, linkHoverFormat:linkHoverFormatProperty
			, listMarkerFormat:listMarkerFormatProperty
			
			/* FOLLOWING ARE THE STYLES WE'VE ADDED TO HANDLE TIMED TEXT PROPERTIES */
			, display:displayProperty
			, displayAlign:displayAlignProperty
			/*  
				// These data structures help us calculate length values based on context
				, extent:extentProperty
				, ttFontSize:ttFontSizeProperty
				, ttLineHeight:ttLineHeightProperty */  
			, opacity:opacityProperty
			/*  
				// This data structure helps us calculate position values based on context
				, origin  */
			, overflow:overflowProperty
			/*  
				// This data structure helps us calculate padding values based on context
				, padding */
			, showBackground:showBackgroundProperty
			, unicodeBidi:unicodeBidiProperty
			, visibility:visibilityProperty
			, wrapOption:wrapOptionProperty
			, writingMode:writingModeProperty
			, zIndex:zIndexProperty
		}
		
		/** Intentionally hidden so that overriders can override individual property setters */
		private function setStyleByProperty(styleProp:Property,newValue:*):void
		{
			var name:String = styleProp.name;
			newValue = styleProp.setHelper(getStyle(name),newValue);
			setStyleByName(name, newValue);
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function set id(value:String):void
		{
			_id = value;
		}
		
		[Inspectable(enumeration="auto,none")]
		public function get display():*
		{
			return getStyle("display");
		}
		public function set display(value:*):void
		{
			setStyleByProperty(TimedTextStyle.displayProperty,value);
		}
		
		[Inspectable(enumeration="before,center,after")]
		public function get displayAlign():String
		{
			return getStyle("displayAlign");
		}
		public function set displayAlign(value:String):void
		{
			setStyleByProperty(TimedTextStyle.displayAlignProperty,value);
		}
		
		public function get extent():org.osmf.smpte.tt.styling.Extent
		{
			return getStyle("extent");
		}
		public function set extent(value:org.osmf.smpte.tt.styling.Extent):void
		{
			setStyleByName("extent",value);
		}
		
		public function get ttFontSize():FontSize
		{
			return getStyle("ttFontSize") as FontSize;
		}
		public function set ttFontSize(value:FontSize):void
		{
			setStyleByName("ttFontSize",value);
		}
		
		public function get ttLineHeight():LineHeight
		{
			return getStyle("ttLineHeight") as LineHeight;
		}
		public function set ttLineHeight(value:LineHeight):void
		{
			setStyleByName("ttLineHeight",value);
		}
		
		public function get opacity():*
		{
			return getStyle("opacity");
		}
		public function set opacity(value:*):void
		{
			setStyleByProperty(TimedTextStyle.opacityProperty,value);
		}
		
		public function get origin():org.osmf.smpte.tt.styling.Origin
		{
			return getStyle("origin");
		}
		public function set origin(value:org.osmf.smpte.tt.styling.Origin):void
		{
			setStyleByName("origin",value);
		}
		
		public function get overflow():*
		{
			return getStyle("overflow");
		}
		public function set overflow(value:*):void
		{
			setStyleByProperty(TimedTextStyle.overflowProperty,value);
		}
		
		public function get padding():org.osmf.smpte.tt.styling.PaddingThickness
		{
			return getStyle("padding");
		}
		public function set padding(value:org.osmf.smpte.tt.styling.PaddingThickness):void
		{
			setStyleByName("padding",value);
		}
		
		public function get showBackground():*
		{
			return getStyle("showBackground");
		}
		public function set showBackground(value:*):void
		{
			setStyleByProperty(TimedTextStyle.showBackgroundProperty,value);
		}
		
		public function get textOutline():TextOutline
		{
			return getStyle("textOutline");
		}
		public function set textOutline(value:TextOutline):void
		{
			setStyleByName("textOutline",value);
		}
		
		[Inspectable(enumeration="normal,embed,bidiOverride")]
		public function get unicodeBidi():String
		{
			return getStyle("unicodeBidi");
		}
		
		public function set unicodeBidi(value:String):void
		{
			setStyleByProperty(TimedTextStyle.unicodeBidiProperty,value);
		}
		
		[Inspectable(enumeration="visible,hidden")]
		public function get visibility():*
		{
			return getStyle("visibility");
		}
		public function set visibility(value:*):void
		{
			setStyleByProperty(TimedTextStyle.visibilityProperty,value);
		}
		
		[Inspectable(enumeration="wrap,noWrap")]
		public function get wrapOption():*
		{
			return getStyle("wrapOption");
		}
		public function set wrapOption(value:*):void
		{
			setStyleByProperty(TimedTextStyle.wrapOptionProperty,value);
			switch(wrapOption){
				case "nowrap":
					this.lineBreak=LineBreak.EXPLICIT;
					break;
				case "wrap":
				default:
					this.lineBreak=LineBreak.TO_FIT;
					break;
			}
		}
		
		[Inspectable(enumeration="lrtb,rltb,tbrl,tblr,tb,lr")]
		public function get writingMode():*
		{ 
			return getStyle("writingMode");
		}
		public function set writingMode(value:*):void
		{  
			setStyleByProperty(TimedTextStyle.writingModeProperty,value);
			switch(writingMode){
				case "lrtb":
				case "lr":
					blockProgression = BlockProgression.TB;
					if (!direction)
						direction = Direction.LTR;
					break;
				case "rltb":
				case "rl":
					blockProgression = BlockProgression.TB;
					if (!direction)
						direction = Direction.RTL;
					break;
				case "tbrl":
				case "tb":
					blockProgression = BlockProgression.RL;
					if (!direction)
						direction = Direction.RTL;
					break;
				case "tblr":
					blockProgression = BlockProgression.RL;
					if (!direction)
						direction = Direction.LTR;	
					break;
				default:
					blockProgression = BlockProgression.TB;
					if (!direction)
						direction = Direction.LTR;
					break;
			}
		}
		
		public function get zIndex():*
		{
			return getStyle("zIndex");
		}
		
		public function set zIndex(value:*):void
		{
			setStyleByProperty(TimedTextStyle.zIndexProperty,value);
		}
		
		public function TimedTextStyle(initialValues:ITextLayoutFormat=null)
		{
			super(initialValues);
			
			id = flash.utils.getTimer().toString();
			
			/*
			if (!initialValues)
			{
				displayAlign = TimedTextStyle.displayAlignProperty.defaultValue;
				display = TimedTextStyle.displayProperty.defaultValue;
				opacity = TimedTextStyle.opacityProperty.defaultValue;
				showBackground = TimedTextStyle.showBackgroundProperty.defaultValue;
				visibility = TimedTextStyle.visibilityProperty.defaultValue;
				wrapOption = TimedTextStyle.wrapOptionProperty.defaultValue;
				
				backgroundColor = TextLayoutFormat.backgroundColorProperty.defaultValue;
				backgroundAlpha = TextLayoutFormat.backgroundAlphaProperty.defaultValue;
				color = TextLayoutFormat.colorProperty.defaultValue;
				textAlpha = TextLayoutFormat.textAlphaProperty.defaultValue;
				fontFamily = TextLayoutFormat.fontFamilyProperty.defaultValue;
				fontStyle = TextLayoutFormat.fontStyleProperty.defaultValue;
				fontWeight = TextLayoutFormat.fontWeightProperty.defaultValue;
				ttFontSize = new FontSize("1c");
				textAlign = TextLayoutFormat.textAlignProperty.defaultValue;
			}
			*/
		}
		
		public function clone():TimedTextStyle
		{
			return new TimedTextStyle(this as ITextLayoutFormat);
		}
		
		
	}
}