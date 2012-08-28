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
	import flashx.textLayout.container.TextContainerManager;
	import flashx.textLayout.conversion.ITextImporter;
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
	import flashx.textLayout.formats.LineBreak;
	
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
	import org.osmf.smpte.tt.primitives.Size;
	import org.osmf.smpte.tt.styling.AutoExtent;
	import org.osmf.smpte.tt.styling.AutoOrigin;
	import org.osmf.smpte.tt.styling.Extent;
	import org.osmf.smpte.tt.styling.FontSize;
	import org.osmf.smpte.tt.styling.LineHeight;
	import org.osmf.smpte.tt.styling.NumberPair;
	import org.osmf.smpte.tt.styling.Origin;
	import org.osmf.smpte.tt.styling.PaddingThickness;
	import org.osmf.smpte.tt.styling.TextOutline;
	import org.osmf.smpte.tt.styling.WrapOption;
	import org.osmf.smpte.tt.utilities.DictionaryUtils;
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
			{
				_textFlow.replaceChildren(0,_textFlow.numChildren);
			}
			
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
				&& layoutRenderer.parent.container
				&& layoutRenderer.parent.container.measuredWidth
				&& layoutRenderer.parent.container.measuredHeight);
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
		
		public function validateCaption(begin:Number=NaN, end:Number=NaN):void
		{
			if (_currentCaption)
			{
				var timeTrait:TimeTrait;
				
				if (mediaElement)
					timeTrait = mediaElement.getTrait(MediaTraitType.TIME) as TimeTrait;
				
				if (isNaN(begin))
					begin = (timeTrait) ? timeTrait.currentTime : _currentCaption.begin;

				if (isNaN(end))
					end = _currentCaption.end;
				
				if (!_currentCaption.isActiveInRange(begin, end))
				{
					removeCaption(_currentCaption);
				} 
				else if (timeTrait)
				{
					if (!_currentCaption.isActiveAtPosition(timeTrait.currentTime, true))
						removeCaption(_currentCaption);
					else
						redrawAtPosition(_currentCaption, timeTrait.currentTime);
				}
			}
		}
		
		private function redrawAtPosition(captionElement:CaptionElement, currentTime:Number):Boolean
		{
			if (!captionElement.isActiveAtPosition(currentTime))
			{
				redrawCaption();
				return true;
			}
			
			for each(var c:CaptionElement in captionElement.children)
			{
				if (!c.isActiveAtPosition(currentTime))
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
			if (captionElement.style.display == "none") 
				return null;
			
			//trace(captionElement+" "+captionElement.captionElementType +" "+captionElement.content);
			
			var flowElement:FlowElement;
			
			if(captionElement.captionElementType == TimedTextElementType.Text)
			{
				var span:SpanElement = new SpanElement();
				span.text = captionElement.content;
				
				applyStyles(span, captionElement.style, captionElement);

				flowElement = span as FlowElement;				
			}
			else if (captionElement.captionElementType == TimedTextElementType.LineBreak)
			{
				var br:BreakElement = new BreakElement();
				
				applyStyles(br, captionElement.style, captionElement);
				
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
				
				if (flowElement) {
					applyStyles(flowElement, captionElement.style, captionElement);
				}
				
				var timeTrait:TimeTrait;
				if (mediaElement)
					timeTrait = mediaElement.getTrait(MediaTraitType.TIME) as TimeTrait;
				
				if(timeTrait)
				{
					var currentTime:Number = timeTrait.currentTime;
				
					for each(var c:CaptionElement in children)
					{
						if (timeTrait 
							&& c.isActiveAtPosition(currentTime, true)
							&& c.isActiveInRange(currentTime,captionElement.end)
							&& c.style.display != "none")
						{
								/*
								trace("YES: "+c.captionElementType
										+"\t"+ currentTime
										+"\t("+c.begin+", "+c.end+")"
										+"\t"+c.content+"\n");
								*/
							var childElement:FlowElement = getFlowElement(c);
							if(childElement)
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
			
			// trace(captionElement.captionElementType + " " + flowElement + " "+(flowElement as FlowElement).getText());
			return flowElement as FlowElement;
		}
		
		private function updateContext():void {
			_size = new Size(layoutRenderer.parent.container.measuredWidth, layoutRenderer.parent.container.measuredHeight);
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
			var styles:Object = captionRegion.style.styles;
			var cellWidth:Number, cellHeight:Number,
				safeAreaWidth:Number, safeAreaHeight:Number;
			
			layoutMetadata.left = NaN;
			layoutMetadata.right = NaN;
			layoutMetadata.bottom = NaN;
			
			if(styles.origin){
				 
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
			
			if(styles.extent){
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
			
			for(var key:String in styles){
				switch(key){
					case "showBackground":
					case "backgroundColor":
					case "backgroundAlpha":
					{
						this[key] = styles[key];
						break;
					}
					case "wrapOption":
					{
						_containerController.lineBreak = (styles.wrapOption == WrapOption.NOWRAP.value) ? LineBreak.EXPLICIT : LineBreak.TO_FIT;
						break;
					}
					case "ttFontSize":
					{
						var ttFontSize:FontSize = styles[key] as FontSize;
						if(ttFontSize){
							safeAreaWidth = (ttFontSize.unitMeasureHorizontal==Unit.CELL) ? toTextSafeArea(size.width) : size.width;
							safeAreaHeight = (ttFontSize.unitMeasureVertical==Unit.CELL) ? toTextSafeArea(size.height) : size.height;
							ttFontSize.setContext(safeAreaWidth, safeAreaHeight);
							
							cellWidth = (ttFontSize.unitMeasureHorizontal==Unit.PERCENT) ? cellSize.width*(NumberPair.cellColumns-2) : cellSize.width;
							cellHeight = (ttFontSize.unitMeasureVertical==Unit.PERCENT) ? cellSize.height*(NumberPair.cellRows-2) : cellSize.height;
							ttFontSize.setFontContext(cellWidth, cellHeight);

							_containerController.fontSize = ttFontSize.fontHeight;
							//trace(_containerController+" setContext("+safeAreaWidth+","+safeAreaHeight+")");
							//trace(_containerController+" setFontContext("+cellWidth+","+cellHeight+")");
						} else {
							_containerController.fontSize = 16;
						}
						//trace(_containerController+" fontSize="+_containerController.fontSize);
						break;
					}
					case "ttLineHeight":
					{
						var ttLineHeight:LineHeight = styles[key] as LineHeight;
						if(ttLineHeight){
							safeAreaWidth = (ttLineHeight.unitMeasureHorizontal==Unit.CELL) ? toTextSafeArea(size.width) : size.width;
							safeAreaHeight = (ttLineHeight.unitMeasureVertical==Unit.CELL) ? toTextSafeArea(size.height) : size.height;
							ttLineHeight.setContext(safeAreaWidth, safeAreaHeight);
							
							cellWidth = (ttLineHeight.unitMeasureHorizontal==Unit.PERCENT) ? cellSize.width*(NumberPair.cellColumns-2) : cellSize.width;
							cellHeight = (ttLineHeight.unitMeasureVertical==Unit.PERCENT) ? cellSize.height*(NumberPair.cellRows-2) : cellSize.height;
							ttLineHeight.setFontContext(cellWidth, cellHeight);
							_containerController.lineHeight = ttLineHeight.height;
						}
						//trace("lineHeight: " + _containerController.lineHeight);
						break;
					}
					case "padding":
					{
						var padding:PaddingThickness = styles[key] as PaddingThickness;
						if (padding)
						{
							padding.setContext(this.layoutRenderer.parent.container.measuredWidth,this.layoutRenderer.parent.container.measuredHeight);
							padding.setFontContext(cellSize.width, cellSize.height);
							_containerController.paddingTop = (padding.widthBefore>0) ? padding.widthBefore : 0;
							_containerController.paddingRight = (padding.widthEnd>0) ? padding.widthEnd : 0;
							_containerController.paddingBottom = (padding.widthAfter>0) ? padding.widthAfter : 0;
							_containerController.paddingLeft = (padding.widthStart>0) ? padding.widthStart : 0;
						}
						break;
					}
					case "opacity":
					{
						if (!isNaN(styles[key]))
						{
							blendMode = BlendMode.LAYER;
							alpha = styles[key];
						}
					}
					default:
					{
						if(_containerController.hasOwnProperty(key) && styles[key]!=null){
							_containerController.setStyle(key,styles[key]);
						} else {
							//trace(this+" "+key+"="+styles[key]);
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
			
			for(var key:String in styles){
				switch(key)
				{
					case "backgroundColor" :
					case "backgroundAlpha" :
					{
						if(flowElement is ParagraphFormattedElement){
							this[key] = styles[key];	
						} else {
							flowElement[key] = styles[key];
						}
						break;
					}
					case "showBackground" :
					{
						this[key] = styles[key];
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
						var ttFontSize:FontSize = styles[key] as FontSize;
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
							flowElement.fontSize = 16;
						}
						//trace(flowElement+" fontSize="+flowElement.fontSize);
						break;
					}
					case "ttLineHeight" :
					{
						var ttLineHeight:LineHeight = styles[key] as LineHeight;
						if(ttLineHeight){
							safeAreaWidth = (ttLineHeight.unitMeasureHorizontal==Unit.CELL) ? toTextSafeArea(size.width) : size.width;
							safeAreaHeight = (ttLineHeight.unitMeasureVertical==Unit.CELL) ? toTextSafeArea(size.height) : size.height;
							ttLineHeight.setContext(safeAreaWidth, safeAreaHeight);
							
							cellWidth = (ttLineHeight.unitMeasureHorizontal==Unit.PERCENT) ? cellSize.width*(NumberPair.cellColumns-2) : cellSize.width;
							cellHeight = (ttLineHeight.unitMeasureVertical==Unit.PERCENT) ? cellSize.height*(NumberPair.cellRows-2) : cellSize.height;
							ttLineHeight.setFontContext(cellWidth, cellHeight);
							
							flowElement.lineHeight = ttLineHeight.height;
						}
						//trace(flowElement+" lineHeight=" + flowElement.lineHeight);
						break;
					}
					case "padding" :
					{
						var padding:PaddingThickness = styles[key] as PaddingThickness;
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
						
						
						var textOutline:TextOutline = styles[key] as TextOutline;
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
					default :
					{
						if(flowElement.hasOwnProperty(key) && styles[key]!=null){
							// trace(flowElement+"\t"+key+"\t"+styles[key]);
							flowElement.setStyle(key,styles[key]);
						} else {
							//trace(captionElement+" "+key+"="+styles[key]);
						}
						break;
					}
				}
			}
			//trace("*************\n");
		}
		
		private function buildTextFlow(captionElement:CaptionElement):void
		{
			updateContext();
			
			_textOutlineFiltersDict = null;
			_textOutlineFiltersHash = null;
			
			applyRegionStyles();
						
			var styles:Object = captionElement.style.styles;
			var origin:Origin,
				extent:Extent,
				opacity:Number,
				ttFontSize:FontSize,
				ttLineHeight:LineHeight;
				
			if(styles.origin){
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
			
			if(styles.extent){
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
		private static const TEXT_SAFE_AREA_RATIO:Number = 0.8;
	}
}