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
package org.osmf.smpte.tt.media
{
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.BreakElement;
	import flashx.textLayout.elements.DivElement;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.ParagraphFormattedElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.SubParagraphGroupElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.Direction;
	import flashx.textLayout.formats.LineBreak;
	import flashx.textLayout.formats.TextDecoration;
	
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.LayoutRendererBase;
	import org.osmf.layout.ScaleMode;
	import org.osmf.smpte.tt.captions.CaptionElement;
	import org.osmf.smpte.tt.captions.CaptionRegion;
	import org.osmf.smpte.tt.captions.ShowBackground;
	import org.osmf.smpte.tt.captions.TimedTextElement;
	import org.osmf.smpte.tt.captions.TimedTextElementType;
	import org.osmf.smpte.tt.captions.TimedTextStyle;
	import org.osmf.smpte.tt.enums.Unit;
	import org.osmf.smpte.tt.model.TimedTextElementBase;
	import org.osmf.smpte.tt.primitives.Size;
	import org.osmf.smpte.tt.styling.AutoExtent;
	import org.osmf.smpte.tt.styling.AutoOrigin;
	import org.osmf.smpte.tt.styling.Extent;
	import org.osmf.smpte.tt.styling.FontSize;
	import org.osmf.smpte.tt.styling.LineHeight;
	import org.osmf.smpte.tt.styling.NumberPair;
	import org.osmf.smpte.tt.styling.Origin;
	import org.osmf.smpte.tt.styling.PaddingThickness;
	import org.osmf.smpte.tt.styling.TextDecorationAttributeValue;
	import org.osmf.smpte.tt.styling.TextOutline;
	import org.osmf.smpte.tt.styling.Visibility;
	import org.osmf.smpte.tt.styling.WrapOption;
	import org.osmf.smpte.tt.utilities.VectorUtils;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.TimeTrait;
	
	public class RegionLayoutTargetSprite extends RootLayoutTargetSprite
	{
		
		public function RegionLayoutTargetSprite(captionRegion:CaptionRegion, layoutRenderer:LayoutRendererBase=null, layoutMetadata:LayoutMetadata=null)
		{
			super(layoutRenderer, layoutMetadata);
						
			this.captionRegion = captionRegion;
			
			this.layoutMetadata.scaleMode = ScaleMode.NONE;
			this.layoutMetadata.snapToPixel = true;
			this.layoutMetadata.width = width;
			this.layoutMetadata.height = height;
			
			_textFlowContainer = new Sprite();
			addChild(_textFlowContainer);
			
			_textFlow = new TextFlow();
			
			_containerController = new ContainerController(_textFlowContainer, width, height);
			_textFlow.flowComposer.addController(_containerController);			
		}

		public function get id():String
		{
			return _id;
		}
		
		public function set id(value:String):void
		{
			_id = value;
		}
		
		public function get captionRegion():CaptionRegion
		{
			return _captionRegion;
		}
		
		public function set captionRegion(value:CaptionRegion):void
		{
			if(_captionRegion != value){
				_captionRegion = value;
				_id = _captionRegion.id;
			}
		}
		
		public function addCaption(value:CaptionElement):void
		{
			_currentCaption = value;
			if(hasRendererContext())
			{
				buildTextFlow(_currentCaption);
			}
			
			//trace("\n*******\nADD CAPTION:\n\t "+_textFlow.getText()+"\n\t from "+this.id+"\n*******\n");
		}
		
		public function redrawCaption():void
		{
			if (_textFlow.numChildren>0 && _textFlow.getText().length)
				_textFlow.replaceChildren(0,_textFlow.numChildren);
			
			
			if (hasRendererContext())
			{
				if (_currentCaption)
				{
					buildTextFlow(_currentCaption);
				} else
				{
					applyRegionStyles();
					autoSizeContainerController();	
				}
			}
		}
		
		private function hasRendererContext():Boolean
		{
			return (layoutRenderer 
				&& layoutRenderer.parent
				&& layoutRenderer.parent.measuredWidth
				&& layoutRenderer.parent.measuredHeight);
		}
		
		public function removeCaption(value:CaptionElement=null):void
		{
			// trace("\n*******\nREMOVE CAPTION:\n\t "+_textFlow.getText()+"\n\t from "+this.id+"\n*******\n");
			if (_textFlow.numChildren>0)
			{
				_textFlow.replaceChildren(0,_textFlow.numChildren);	
			}
			autoSizeContainerController();
			_currentCaption = null;
		}
		
		public function validateCaption(begin:Number=NaN, end:Number=NaN, currentTime:Number=NaN):void
		{
			if (_currentCaption)
			{
				var round:Boolean = false;
				
				if (isNaN(currentTime) && timeTrait)
				{
					// if no currentTime is specified and a TimeTrait exist, 
					// use the currentTime of the mediaElement's TimeTrait for comparison,
					// but round to adjust for time interval imprecision.
					currentTime = timeTrait.currentTime;
				}
				
				if (isNaN(begin))
				{
					// If an expilict begin time is not specified,
					// use either the currentTime if a TimeTrait is present,
					// or the begin time of the currentCaption for this region.
					if (timeTrait)
					{
						begin = currentTime;
						round = true;
					} else 
					{
						begin = _currentCaption.begin;
						round = false;
					}
				}				

				if (isNaN(end))
					end = _currentCaption.end;
				
				if (timeTrait)
				{
					if (!_currentCaption.isActiveAtPosition(currentTime, round))
					{
						removeCaption(_currentCaption);
					} else 
					{
						redrawAtPosition(_currentCaption, currentTime);
					}
				} else if (!_currentCaption.isActiveInRange(begin, end))
				{
					removeCaption(_currentCaption);
				}  
					
			}
		}
		
		private function redrawAtPosition(captionElement:CaptionElement, currentTime:Number):Boolean
		{
			if (captionElement.hasAnimations 
				|| captionRegion.hasAnimations 
				|| !captionElement.isActiveAtPosition(currentTime, true))
			{
				//trace(_id+" redrawAtPosition("+captionElement+", "+currentTime+") hasAnimations="+captionElement.hasAnimations);
				redrawCaption();
				return true;
			}
			
			for each(var c:CaptionElement in captionElement.children)
			{	
				if (c.hasAnimations || !c.isActiveAtPosition(currentTime, true))
				{
					redrawCaption();
					return true;
				} else if (redrawAtPosition(c, currentTime))
				{
					return true;
				}
			}
			return false;
		}
		
		private function getFlowElement(captionElement:CaptionElement):FlowElement
		{
			//("\t>>>START getFlowElement "+captionElement.captionElementType+"<<<");
			
			if (timeTrait)
				captionElement.calculateCurrentStyle(timeTrait.currentTime);
			
			if (captionElement.currentStyle.display == "none") 
				return null;
			
			//(captionElement+" "+captionElement.captionElementType +" "+captionElement.content);
			
			var flowElement:FlowElement;
			var parentElement:TimedTextElement = captionElement.parentElement;
			
			if(captionElement.captionElementType == TimedTextElementType.Text)
			{
				var span:SpanElement = new SpanElement();
				span.text = captionElement.content;
				
				applyStyles(span, captionElement.currentStyle, captionElement);
				
				span.text = addBidirectionEncoding(span.text, 
					(captionElement.currentStyle.unicodeBidi 
						|| parentElement.currentStyle.unicodeBidi),
					(captionElement.currentStyle.direction 
					|| parentElement.currentStyle.direction));
				
				flowElement = span as FlowElement;				
			}
			else if (captionElement.captionElementType == TimedTextElementType.LineBreak)
			{
				var br:BreakElement = new BreakElement();
				
				applyStyles(br, captionElement.currentStyle, captionElement);
				
				flowElement = br;
			} else if (captionElement.captionElementType == TimedTextElementType.Container 
				  || captionElement.captionElementType == TimedTextElementType.SupParagraphGroupElement)
			{	
				
				var children:Vector.<TimedTextElement> = captionElement.children;
				var div:DivElement;
				var paragraph:ParagraphElement;
				var subParagraphGroupElement:SubParagraphGroupElement;
				if (captionElement.captionElementType == TimedTextElementType.SupParagraphGroupElement)
				{
					subParagraphGroupElement = new SubParagraphGroupElement();
					
					flowElement = subParagraphGroupElement as FlowElement;
				} else if (children 
					&& children.length>0 
					&& children[0].captionElementType==TimedTextElementType.Container)
				{
					div = new DivElement();
					
					flowElement = div as FlowElement;
				} else 
				{
					paragraph = new ParagraphElement();
					
					flowElement = paragraph as FlowElement;
				}
				
				if (flowElement)
				{
					applyStyles(flowElement, captionElement.currentStyle, captionElement);

					if (timeTrait)
					{
						var currentTime:Number = timeTrait.currentTime;
					
						for each(var c:CaptionElement in children)
						{
							if (c.isActiveAtPosition(currentTime, true)
								&& c.isActiveInRange(currentTime,captionElement.end)
								&& c.currentStyle.display != "none")
							{
									/*
									trace("YES: "+c.captionElementType
											+"\t"+ currentTime
											+"\t("+c.begin+", "+c.end+")"
											+"\t"+c.content+"\n");
									*/
								var childElement:FlowElement = getFlowElement(c);
								if (childElement)
									FlowGroupElement(flowElement).addChild(childElement);
							} 
							/*else
							{
									trace("NO: "+c.captionElementType
										+"\t"+ currentTime
										+"\t("+c.begin+", "+c.end+")"
										+"\t"+c.content);
							}*/
						}
					}
					}
			}
			
			// trace(captionElement.captionElementType + " " + flowElement + " "+(flowElement as FlowElement).getText());
			return flowElement as FlowElement;
		}
		
		private function updateContext():void {
			if (!hasRendererContext()) return;
			_size = new Size(layoutRenderer.parent.measuredWidth, layoutRenderer.parent.measuredHeight);
			_cellSize = new Size(toTextSafeArea(_size.width)/NumberPair.cellColumns, toTextSafeArea(_size.height)/NumberPair.cellRows);
		}
		
		private function get size():Size {
			updateContext();
			return _size;
		}
		
		private function get cellSize():Size {
			updateContext();
			return _cellSize;
		}
		
		
		private function toTextSafeArea(value:Number):Number
		{
			return value*TEXT_SAFE_AREA_RATIO;
		}
		
		public function get showBackground():String
		{
			return _showBackground;
		}
		
		public function set showBackground(value:String):void
		{
			_showBackground = value;
		}
		
		private function applyRegionStyles():void
		{
			//trace("\n*************\n"+this.id+".applyRegionStyles()");
			if (timeTrait)
				captionRegion.calculateCurrentStyle(timeTrait.currentTime);
						
			var styles:Object = captionRegion.currentStyle.styles;
			var cellWidth:Number, cellHeight:Number,
				safeAreaWidth:Number, safeAreaHeight:Number;
			
			layoutMetadata.left = NaN;
			layoutMetadata.right = NaN;
			layoutMetadata.bottom = NaN;
			
			if (styles.origin)
			{ 
				//trace("is AutoOrigin? "+ (styles.origin is AutoOrigin));
				if (styles.origin as AutoOrigin == null)
				{
					styles.origin.setContext(size.width,size.height);
					styles.origin.setFontContext(cellSize.width,cellSize.height);
					
					if(styles.origin.x>0)
					{
						layoutMetadata.x = styles.origin.x;
						layoutMetadata.right = 0;
					}
					if(styles.origin.y>0)
					{
						layoutMetadata.y = styles.origin.y;
						layoutMetadata.bottom = 0;
					}
					
				} else
				{
					layoutMetadata.x = 0;
					layoutMetadata.y = 0;
				}
				
				//trace("\tlayoutMetadata {x:"+layoutMetadata.x +", y:"+layoutMetadata.y+"}");
			}
			
			if(styles.extent)
			{
				//trace("{width:"+size.width+", height:"+size.height+"}")
				
				//trace("is AutoExtent? "+ (styles.extent is AutoExtent));
				if (styles.extent as AutoExtent == null)
				{
						
					styles.extent.setContext(size.width,size.height);
					styles.extent.setFontContext(cellSize.width,cellSize.height);
					
					layoutMetadata.width = (styles.extent.width>0) ? Math.min(styles.extent.width, size.width-layoutMetadata.x) : NaN;
					layoutMetadata.height = (styles.extent.height>0) ? Math.min(styles.extent.height, size.height-layoutMetadata.y) : NaN;
					
				} else
				{
					layoutMetadata.width = size.width-layoutMetadata.x;
					layoutMetadata.height = size.height-layoutMetadata.y;
				}
				//trace("\tlayoutMetadata {width:"+layoutMetadata.width +", height:"+layoutMetadata.height+"}");
			}
			
			if(styles.zIndex)
			{
				layoutMetadata.index = styles.zIndex;
			}
			
			for(var key:String in styles){
				var value:* = styles[key];
				//trace("\t{"+key+":"+value+"}");
				switch(key){
					case "showBackground":
					case "backgroundColor":
					case "backgroundAlpha":
					{
						this[key] = value;
						break;
					}
					case "wrapOption":
					{
						_containerController.lineBreak = _textFlow.lineBreak = (styles.wrapOption == WrapOption.NOWRAP.value) ? LineBreak.EXPLICIT : LineBreak.TO_FIT;
						break;
					}
					case "ttFontSize":
					{
						var ttFontSize:FontSize = value as FontSize;
						if (ttFontSize)
						{
							safeAreaWidth = (ttFontSize.unitMeasureHorizontal==Unit.CELL) ? toTextSafeArea(size.width) : size.width;
							safeAreaHeight = (ttFontSize.unitMeasureVertical==Unit.CELL) ? toTextSafeArea(size.height) : size.height;
							ttFontSize.setContext(safeAreaWidth, safeAreaHeight);
							
							cellWidth = (ttFontSize.unitMeasureHorizontal==Unit.PERCENT) ? cellSize.width*(NumberPair.cellColumns-2) : cellSize.width;
							cellHeight = (ttFontSize.unitMeasureVertical==Unit.PERCENT) ? cellSize.height*(NumberPair.cellRows-2) : cellSize.height;
							ttFontSize.setFontContext(cellWidth, cellHeight);

							_containerController.fontSize = _textFlow.fontSize = ttFontSize.fontHeight;
							//trace(_containerController+" setContext("+safeAreaWidth+","+safeAreaHeight+")");
							//trace(_containerController+" setFontContext("+cellWidth+","+cellHeight+")");
						} else {
							_containerController.fontSize = _textFlow.fontSize = cellSize.height;
						}
						//trace(_containerController+" fontSize="+_containerController.fontSize);
						break;
					}
					case "ttLineHeight":
					{
						var ttLineHeight:LineHeight = value as LineHeight;
						if (ttLineHeight)
						{
							safeAreaWidth = (ttLineHeight.unitMeasureHorizontal==Unit.CELL) ? toTextSafeArea(size.width) : size.width;
							safeAreaHeight = (ttLineHeight.unitMeasureVertical==Unit.CELL) ? toTextSafeArea(size.height) : size.height;
							ttLineHeight.setContext(safeAreaWidth, safeAreaHeight);
							
							cellWidth = (ttLineHeight.unitMeasureHorizontal==Unit.PERCENT) ? cellSize.width*(NumberPair.cellColumns-2) : cellSize.width;
							cellHeight = (ttLineHeight.unitMeasureVertical==Unit.PERCENT) ? cellSize.height*(NumberPair.cellRows-2) : cellSize.height;
							ttLineHeight.setFontContext(cellWidth, cellHeight);
							_containerController.lineHeight = _textFlow.lineHeight = ttLineHeight.height;
						} else
						{
							_containerController.lineHeight = _textFlow.lineHeight = (_containerController.fontSize ? _containerController.fontSize : cellSize.height) * 1.2;
						}
						//trace("lineHeight: " + _containerController.lineHeight);
						break;
					}
					case "padding":
					{
						var padding:PaddingThickness = value as PaddingThickness;
						if (padding)
						{
							padding.setContext(this.layoutRenderer.parent.container.measuredWidth,this.layoutRenderer.parent.container.measuredHeight);
							padding.setFontContext(cellSize.width, cellSize.height);
							_containerController.paddingTop = _textFlow.paddingTop = (padding.widthBefore>0) ? padding.widthBefore : 0;
							_containerController.paddingRight = _textFlow.paddingRight = (padding.widthEnd>0) ? padding.widthEnd : 0;
							_containerController.paddingBottom = _textFlow.paddingBottom = (padding.widthAfter>0) ? padding.widthAfter : 0;
							_containerController.paddingLeft = _textFlow.paddingLeft = (padding.widthStart>0) ? padding.widthStart : 0;
						}
						break;
					}
					case "opacity":
					{
						if (!isNaN(value))
						{
							blendMode = BlendMode.LAYER;
							alpha = value;
						}
						break;
					}	
					case "lineThrough":
					case "textDecoration":
					{
						_containerController.textDecoration = _textFlow.textDecoration = styles["textDecoration"] ? styles["textDecoration"] : TextDecoration.NONE;
						_containerController.lineThrough = _textFlow.lineThrough = (styles["lineThrough"]) ? styles["lineThrough"] : false;
						break;
					}
					case "direction":
					{
						_containerController.direction = _textFlow.direction = (value==Direction.RTL) ? Direction.RTL : Direction.LTR;
						break;
					}
					case "visibility":
					{
						if (styles[key]==Visibility.HIDDEN.value)
						{
							_containerController.textAlpha = _textFlow.textAlpha = 0;
							_containerController.backgroundAlpha = _textFlow.backgroundAlpha = 0;
						} else
						{
							_containerController.textAlpha = _textFlow.textAlpha = styles["textAlpha"];
							_containerController.backgroundAlpha = _textFlow.backgroundAlpha = styles["backgroundAlpha"];
						}
						break;
					}
					default:
					{
						if(_containerController.hasOwnProperty(key) && value)
						{
							_containerController.setStyle(key,value);
						} else if(_textFlow.hasOwnProperty(key) && value)
						{
							_textFlow.setStyle(key,value);
						} else {
							// trace(this+" "+key+"="+styles[key]);
						}
						
						
						break;
					}
				}
			}
			//trace("*************\n");
		}
		
		
		
		private function applyStyles(flowElement:FlowElement, style:TimedTextStyle, captionElement:CaptionElement):void {
			
			//trace("\n*************\n"+flowElement+".applyStyles()");
			updateContext();
			
			var styles:Object = style.styles;
			var cellWidth:Number, cellHeight:Number,
				safeAreaWidth:Number, safeAreaHeight:Number;
			
			for(var key:String in styles)
			{
				var value:* = styles[key];
				//trace("\t{"+key+":"+value+"}");
				switch(key)
				{
					case "backgroundColor" :
					case "backgroundAlpha" :
					{						
						if(flowElement is ParagraphFormattedElement){
							this[key] = value;	
						} else {
							flowElement[key] = value;
						}
						break;
					}
						
					case "color" :
					case "textAlpha" :
					{						
						flowElement[key] = value;
						break;
					}
						
					case "showBackground" :
					{
						this[key] = value;
						break;
					}
					case "wrapOption" :
					{		
						flowElement.lineBreak = (style.wrapOption == WrapOption.NOWRAP.value) ? LineBreak.EXPLICIT : LineBreak.TO_FIT;
						_textFlow.lineBreak = flowElement.lineBreak;
						//trace("\n"+captionElement.captionElementType+" "+key+"="+styles[key] + " : "+flowElement.lineBreak+"\n");
						break;
					}
					case "ttFontSize" :
					{
						var ttFontSize:FontSize = value as FontSize;
						if(ttFontSize){
							safeAreaWidth = (ttFontSize.unitMeasureHorizontal==Unit.CELL) ? toTextSafeArea(size.width) : size.width;
							safeAreaHeight = (ttFontSize.unitMeasureVertical==Unit.CELL) ? toTextSafeArea(size.height) : size.height;
							ttFontSize.setContext(safeAreaWidth, safeAreaHeight);
							
							cellWidth = (ttFontSize.unitMeasureHorizontal==Unit.PERCENT) ? cellSize.width*(NumberPair.cellColumns-2) : cellSize.width;
							cellHeight = (ttFontSize.unitMeasureVertical==Unit.PERCENT) ? cellSize.height*(NumberPair.cellRows-2) : cellSize.height;
							ttFontSize.setFontContext(cellWidth, cellHeight);
							flowElement.fontSize = ttFontSize.fontHeight;
							//trace(flowElement+" setContext("+safeAreaWidth+","+safeAreaHeight+")");
							//trace(flowElement+" setFontContext("+cellWidth+","+cellHeight+")");
							
						} else {
							flowElement.fontSize = cellSize.height;
						}
						//trace(flowElement+" fontSize="+flowElement.fontSize);
						break;
					}
					case "ttLineHeight" :
					{
						var ttLineHeight:LineHeight = value as LineHeight;
						if(ttLineHeight){
							safeAreaWidth = (ttLineHeight.unitMeasureHorizontal==Unit.CELL) ? toTextSafeArea(size.width) : size.width;
							safeAreaHeight = (ttLineHeight.unitMeasureVertical==Unit.CELL) ? toTextSafeArea(size.height) : size.height;
							ttLineHeight.setContext(safeAreaWidth, safeAreaHeight);
							
							cellWidth = (ttLineHeight.unitMeasureHorizontal==Unit.PERCENT) ? cellSize.width*(NumberPair.cellColumns-2) : cellSize.width;
							cellHeight = (ttLineHeight.unitMeasureVertical==Unit.PERCENT) ? cellSize.height*(NumberPair.cellRows-2) : cellSize.height;
							ttLineHeight.setFontContext(cellWidth, cellHeight);
							
							flowElement.lineHeight = ttLineHeight.height;
						} else
						{
							flowElement.lineHeight = (flowElement.fontSize ?  flowElement.fontSize : cellSize.height) * 1.2;
						}
						//trace(flowElement+" lineHeight=" + flowElement.lineHeight);
						break;
					}
					case "padding" :
					{
						var padding:PaddingThickness = value as PaddingThickness;
						if(padding){
							padding.setContext(this.layoutRenderer.parent.container.measuredWidth,this.layoutRenderer.parent.container.measuredHeight);
							
							if(padding.widthBeforeUnit == Unit.PERCENT){
								padding.setFontContext(this.layoutRenderer.parent.container.measuredWidth,this.layoutRenderer.parent.container.measuredHeight);
							} else {
								padding.setFontContext(cellSize.width, cellSize.height);
							}
							flowElement.paddingTop = (padding.widthBefore>0) ? padding.widthBefore : 0;
							
							if(padding.widthEndUnit == Unit.PERCENT){
								padding.setFontContext(this.layoutRenderer.parent.container.measuredWidth,this.layoutRenderer.parent.container.measuredHeight);
							} else {
								padding.setFontContext(cellSize.width, cellSize.height);
							}
							flowElement.paddingRight = (padding.widthEnd>0) ? padding.widthEnd : 0;
							
							if(padding.widthAfterUnit == Unit.PERCENT){
								padding.setFontContext(this.layoutRenderer.parent.container.measuredWidth,this.layoutRenderer.parent.container.measuredHeight);
							} else {
								padding.setFontContext(cellSize.width, cellSize.height);
							}
							flowElement.paddingBottom = (padding.widthAfter>0) ? padding.widthAfter : 0;
							
							if(padding.widthStartUnit == Unit.PERCENT){
								padding.setFontContext(this.layoutRenderer.parent.container.measuredWidth,this.layoutRenderer.parent.container.measuredHeight);
							} else {
								padding.setFontContext(cellSize.width, cellSize.height);
							}
							flowElement.paddingLeft = (padding.widthStart>0) ? padding.widthStart : 0;
							
							//trace("padding: "+flowElement.paddingTop+" "+flowElement.paddingRight+" "+flowElement.paddingBottom+" "+flowElement.paddingLeft);
						}
						break;
					}
					case "textOutline" :
					{
						var textOutline:TextOutline = value as TextOutline;
						if (textOutline)
						{
							
							textOutline.setContext(this.layoutRenderer.parent.container.measuredWidth,
												   this.layoutRenderer.parent.container.measuredHeight);
							textOutline.setFontContext(cellSize.width, cellSize.height);
							
							if(!textOutline.colorDefined 
								&& textOutline.width 
								&& styles.color)
							{
								textOutline.color = styles.color;
								for each(var filter:GlowFilter in textOutline.filters)
								{
									filter.color = styles.color;
								}
							}
							/*
							trace(captionElement+" "+key+"="+styles[key]);
							trace("\twidth: "+textOutline.width);
							trace("\tcolorDefined: "+textOutline.colorDefined);
							trace("\tcolor: "+textOutline.color);
							trace("\talpha: "+textOutline.alpha);
							trace("\tblur: "+textOutline.blur);
							trace("\tfilters: "+textOutline.filters);
							*/
							if (!_textOutlineFiltersDict)
							{
								_textOutlineFiltersDict = new Dictionary();
								_textOutlineFiltersHash = new Vector.<FlowElement>();
							}
							
							_textOutlineFiltersDict[flowElement] = textOutline.filters;
							_textOutlineFiltersHash.push(flowElement);
						}
						break;
					}
					case "lineThrough":
					case "textDecoration":
					{
						flowElement.textDecoration = styles["textDecoration"] ? styles["textDecoration"] : TextDecoration.NONE;
						flowElement.lineThrough = (styles["lineThrough"]) ? styles["lineThrough"] : false;
						break;
					}
					case "direction":
					{
						flowElement.direction = (value==Direction.RTL) ? Direction.RTL : Direction.LTR;
						break;
					}
					case "visibility":
					{
						if (value==Visibility.HIDDEN.value)
						{
							flowElement.textAlpha = 0;
							flowElement.backgroundAlpha = 0;
						} else
						{
							flowElement.textAlpha = styles["textAlpha"];
							flowElement.backgroundAlpha = styles["backgroundAlpha"];
						}
						break;
					}
					default :
					{
						if(flowElement.hasOwnProperty(key) && value!==null){
							// trace(flowElement+"\t"+key+"\t"+styles[key]);
							flowElement.setStyle(key,value);
						} else {
							//trace(captionElement+" "+key+"="+styles[key]);
						}
						break;
					}
				}
			}
			//trace("*************\n");
		}
		
		/**
		 * Assemble the Unicode Bidi text for a given string.
		 * 
		 * @param text
		 * @param unicodeBidirection Either embed, normal or bidiOveride
		 * @param direction Either ltr or rtl
		 * @return 
		 */
		private function addBidirectionEncoding(text:String, unicodeBidirection:String, direction:String):String
		{
			var data:String = "";
			switch (unicodeBidirection)
			{
				case "embed":
					//The direction of this embedding level is given by the 'direction'
					//property. Inside the element, reordering is done implicitly. 
					//This corresponds to adding a LRE (U+202A; for 'direction: ltr') 
					//or RLE (U+202B; for 'direction: rtl') at the start of the 
					//element and a PDF (U+202C) at the end of the element. 
					if (direction == "ltr")
					{
						data = "\u202A" + text + "\u202C";
					}
					else
					{
						data = "\u202B" + text + "\u202C";
					}
					break;
				case "bidiOverride":
					//reordering is strictly in sequence according to the 'direction' 
					//property; the implicit part of the bidirectional algorithm 
					//is ignored. This corresponds to adding a LRO (U+202D; for 
					//'direction: ltr') or RLO (U+202E; for 'direction: rtl') at 
					//the start of the element and a PDF (U+202C) at the end
					//of the element. 
					if (direction == "ltr")
					{
						data = "\u202D" + text + "\u202C";
					}
					else
					{
						data = "\u202E" + text + "\u202C";
					} break;
				default:
					data = text;
					break;
				
			}
			return data;
		}

		private function buildTextFlow(captionElement:CaptionElement):void
		{
			//("\n>>>START buildTextFlow<<<");
			updateContext();
			
			_textOutlineFiltersDict = null;
			_textOutlineFiltersHash = null;
			
			applyRegionStyles();
			
			if (timeTrait)
				captionElement.calculateCurrentStyle(timeTrait.currentTime);
						
			var styles:Object = captionElement.currentStyle.styles;
			var origin:Origin,
				extent:Extent,
				opacity:Number,
				ttFontSize:FontSize,
				ttLineHeight:LineHeight;
			
			if(styles.origin && styles.origin as AutoOrigin == null){
				origin = styles.origin as Origin;
				
				origin.setContext(size.width,size.height);
				origin.setFontContext(cellSize.width,cellSize.height);
				
				if(origin.x>0)
				{
					layoutMetadata.x = origin.x;
					layoutMetadata.right = 0;
				}
				if(origin.y>0)
				{
					layoutMetadata.y = origin.y;
					layoutMetadata.bottom = 0;
				}
				//trace("layoutMetadata {x:"+layoutMetadata.x +", y:"+layoutMetadata.y+"}");
			}
			
			if(styles.extent && styles.extent as AutoExtent == null){
				extent = styles.extent as Extent;
				extent.setContext(size.width,size.height);
				extent.setFontContext(cellSize.width,cellSize.height);
				if(extent.width>0)
				{
					layoutMetadata.width = extent.width;
				}
				if(extent.height>0)
				{
					layoutMetadata.height = extent.height;
				}				
				//trace("\n\nlayoutMetadata {width:"+layoutMetadata.width +", height:"+layoutMetadata.height+"}\n\n");
			}
			
			validateNow();
			
			if(_textFlow.numChildren>0) 
				_textFlow.replaceChildren(0,_textFlow.numChildren);
			
			var flowElement:FlowElement = getFlowElement(captionElement);
			
			if (flowElement) 
				_textFlow.addChild(flowElement);
			var xmlOut:XML = TextConverter.export(_textFlow,TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
			//trace(xmlOut.toXMLString());
			autoSizeContainerController();
		}
		
		private function applyTextOutlines():void
		{
			if (_textOutlineFiltersDict)
			{
				var len:Number = _textOutlineFiltersHash.length;
				for (var i:uint; i<len; i++)
				{ 
					var flow:FlowElement = _textOutlineFiltersHash[i] as FlowElement;
					var toFilters:Vector.<GlowFilter> = _textOutlineFiltersDict[flow] as Vector.<GlowFilter>;
					var filters:Array = VectorUtils.toArray(toFilters);
					
					if (filters)
					{
						var pos:uint = FlowElement(flow).getAbsoluteStart();
						var endPos:uint = pos + FlowElement(flow).textLength;
						while (pos < endPos)
						{
							var line:TextFlowLine = _textFlow.flowComposer.findLineAtPosition(pos);
							if (line)
							{	
								var textLine:TextLine = line.getTextLine(true);	
								if(textLine)
								{
									textLine.filters = filters;
								}
								pos += line.textLength;
							}
						}
					}
				}
				_textOutlineFiltersDict = null;
				_textOutlineFiltersHash = null;
			}
		}
		
		public function clear():void
		{
			if (_textFlow.numChildren>0)
			{
				_textFlow.replaceChildren(0,_textFlow.numChildren);
				autoSizeContainerController();
			}
		}
		
		private function autoSizeContainerController():void
		{
			_textFlow.flowComposer.composeToPosition();
			
			var contentBounds:Rectangle = _containerController.getContentBounds();

			_containerController.setCompositionSize(Math.min(_containerController.compositionWidth, layoutMetadata.x-size.width), contentBounds.height);
			_textFlow.flowComposer.updateAllControllers();
			
			layoutMetadata.height = contentBounds.height;
			
			measure();
			validateNow();
		}
		
		// Overrides
		//
		override public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean=true):void
		{
			if(lastAvailableWidth==availableWidth && lastAvailableHeight==availableHeight) return;
			
			// trace(">>>>>>>>>"+this+" "+this.id+".layout("+availableWidth+","+availableHeight+","+deep+")");
			if (_containerController)
			{	
				_containerController.setCompositionSize(availableWidth, availableHeight);
				_textFlow.flowComposer.updateAllControllers();
				
				applyTextOutlines();
				
				this._textFlowContainer.scrollRect = null;
			}
			
			super.layout(availableWidth, availableHeight, deep);
		}
		
		override public function set width(value:Number):void
		{
			if (_containerController)
			{
				_containerController.setCompositionSize(value, _containerController.compositionHeight);
				_textFlow.flowComposer.updateAllControllers();
			}
			super.width = value;
		}
		
		override public function set height(value:Number):void
		{
			if (_containerController)
			{
				_containerController.setCompositionSize(_containerController.compositionWidth, value);
				_textFlow.flowComposer.updateAllControllers();
			}
			super.height = value;
		}
		
		
		private function get timeTrait():TimeTrait
		{
			if (!_timeTrait && mediaElement)
			{
				_timeTrait = mediaElement.getTrait(MediaTraitType.TIME) as TimeTrait;
			}	
			return _timeTrait;
		}
		
		private var _id:String = "";
		private var _captionRegion:CaptionRegion;
		private var _textFlow:TextFlow;
		private var _textFlowContainer:Sprite;
		private var _containerController:ContainerController;
		private var _currentCaption:CaptionElement;
		private var _size:Size;
		private var _cellSize:Size;
		private var _showBackground:String = ShowBackground.Always.value;
		private var _textOutlineFiltersDict:Dictionary;
		private var _textOutlineFiltersHash:Vector.<FlowElement>;
		private var _timeTrait:TimeTrait;
		private static const TEXT_SAFE_AREA_RATIO:Number = 0.8;
	}
}