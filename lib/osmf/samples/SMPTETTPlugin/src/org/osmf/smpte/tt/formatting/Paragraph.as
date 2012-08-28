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
	
	import org.osmf.smpte.tt.formatting.InlineContent;
	import org.osmf.smpte.tt.informatics.MetadataInformation;
	import org.osmf.smpte.tt.model.BrElement;
	import org.osmf.smpte.tt.model.TimedTextElementBase;
	import org.osmf.smpte.tt.rendering.IRenderObject;
	import org.osmf.smpte.tt.rendering.Unicode;
	import org.osmf.smpte.tt.styling.ColorExpression;
	import org.osmf.smpte.tt.styling.Colors;
	import org.osmf.smpte.tt.styling.Extent;
	import org.osmf.smpte.tt.styling.Font;
	import org.osmf.smpte.tt.styling.FontSize;
	import org.osmf.smpte.tt.styling.LineHeight;
	import org.osmf.smpte.tt.styling.TextOutline;
	import org.osmf.smpte.tt.styling.WritingMode;
	
	public class Paragraph extends FormattingObject
	{
		public function Paragraph(p_element:TimedTextElementBase)
		{
			element = p_element;
		}
		
		private var _text:String;
		public function get text():String
		{
			return _text;
		}
		public function set text(value:String):void
		{
			_text = value;
		}
		
		/** 
		 * collect up the Unicode Bidi algorithm on this paragraph
		 * 
		 * @param unicodeBidirection one of embed, normal, bidiOveride
		 * @param direction one of ltr or rtl
		 */
		public static function addBidirectionEncoding(text:String, unicodeBidirection:String, direction:String):String
		{
			var data:String = "";
			switch (unicodeBidirection)
			{
				case "undefined":
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
					///reordering is strictly in sequence according to the 'direction' 
					///property; the implicit part of the bidirectional algorithm 
					///is ignored. This corresponds to adding a LRO (U+202D; for 
					///'direction: ltr') or RLO (U+202E; for 'direction: rtl') at 
					///the start of the element and a PDF (U+202C) at the end
					///of the element. 
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
		
		public override function referenceArea():Rectangle
		{
			var fo:FormattingObject = this.parent as FormattingObject;
			
			return fo.referenceArea();
		}
		
		/**
		 * Return a formatting function for paragraphs.
		 */
		public override function createFormatter():Function
		{
			/// children of Paragraph should be InlineContent, all Inlines should have 
			/// been lifted by this point.
			var func:Function = function(renderObject:IRenderObject):void
				{
					computeRelativeStyles(renderObject);
					applyAnimations();
					var breakChars:Vector.<String> = new Vector.<String>(['\n']);
					var extent:Extent,
						c:String,
						inlineContent:*,
						content:InlineContent,
						length:Number,
						lengthV:Number,
						lineLength:Number = 0,
						isPreserve:Boolean,
						font:Font,
						characters:Array,
						hardBreak:Boolean;
					if (displayStyleProperty != "none")  // kill layout of this subtree.
					{
						//{ region display
						//{ region setup
						var mode:WritingMode = writingModeStyleProperty;
						var vertical:Boolean = (mode == WritingMode.TOP_BOTTOM_LEFT_RIGHT || mode == WritingMode.TOP_BOTTOM_RIGHT_LEFT);
						var horizontal:Boolean = !vertical;
						//bool rightMode = mode == WritingMode.TopBottomRightLeft;
						
						var lineHeight:LineHeight = this.calculateLineHeightStyle(renderObject);
						var fontSize:FontSize = calculateFontSizeStyle(renderObject);
						var top:Number = topStyleProperty;
						var left:Number = leftStyleProperty;
						var backgroundColor:ColorExpression = backgroundColorStyleProperty;
						if (visibilityStyleProperty == "hidden")  // everything is drawn transparently.
						{
							backgroundColor = Colors.Transparent;
						}
						
						var wrap:Boolean;
						var layoutRight:Number = referenceArea().x + referenceArea().width;
						//} endregion
						
						
						if (renderPassProperty == 0)
						{
							//{ region pass 0
							//{ region Compute intial reference rectangle
							actualDrawing = new Rectangle();
							// set the area we will fill
							if (horizontal)
							{
								actualDrawing.x = referenceArea().x;
								actualDrawing.y = referenceArea().y;
								actualDrawing.height = fontSize.fontHeight;
								actualDrawing.width = referenceArea().width;
							}
							else
							{
								actualDrawing.x = referenceArea().x;
								actualDrawing.y = referenceArea().y;
								actualDrawing.height = referenceArea().height;
								actualDrawing.width = fontSize.fontWidth;
							}
							//} endregion
							
							var lengthSinceBreak:Number = 0;
							
							for each (inlineContent in children)
							{
								/// In the first pass we need to know how big the 
								/// paragraph is, and where the left margins are.
								content = inlineContent as InlineContent;
								isPreserve = content.preserveStyleProperty;
								font = content.getFont(renderObject);
								
								//{ region figure out where line breaks go and communicate them into pass 2,
								
								if (!isPreserve) content.clearBreaks();  // remove any breaks in the content
								var currentChar:int = 0; // where we are in the local text.
								var lastbreakChar:int = -1;
								
								var wrappingSpace:Number = actualDrawing.width;
								if (!horizontal) wrappingSpace = actualDrawing.height;
								
								wrap = content.wrapOptionStyleProperty;
								characters = content.content.split("");
								var breaks:Vector.<int> = new Vector.<int>();
								if (content != null)
								{
									for each (c in characters)
									{
										extent = content.measureText(c, renderObject, font);
										length = extent.width;
										lengthV = extent.height;
										
										if (!horizontal) length = lengthV;
										
										var shouldWrap:Boolean = wrap && ((lineLength + length) > wrappingSpace);
										hardBreak = (content.element is BrElement) || (isPreserve && breakChars.indexOf(c)>=0);
										if (Unicode.BreakOpportunities.indexOf(c)>=0) // other breakable chars?
										{
											lastbreakChar = currentChar;
											lengthSinceBreak = 0;
										}
										if (hardBreak || shouldWrap)
										{
											//{ region break line if we can.
											if (lastbreakChar > 0)
											{   // break at the previous convenient spot.
												if (!isPreserve)
												{
													breaks.push(lastbreakChar);
												}
												lineLength = lengthSinceBreak;
												lastbreakChar = -1;
											}
											if (hardBreak)
											{
												if (!isPreserve)
												{
													breaks.push(currentChar);
												}
												lineLength = 0;
												
												lengthSinceBreak = 0;
											}
											else
											{
												// cant break yet. we'll overflow to the next space
												currentChar++;
												lineLength += length;
												if (lastbreakChar > 0) lengthSinceBreak += length;
											}
											//} endregion
										}
										else
										{
											currentChar++;
											lineLength += length;
											if (lastbreakChar > 0) lengthSinceBreak += length;
										}
									}
								}


								if (horizontal)
								{
									actualDrawing.height += (lineHeight.height * breaks.length);
								}
								else
								{ // line width?
									actualDrawing.width += (lineHeight.width * breaks.length);
								}
								content.insertBreaks(breaks);
								//} endregion
							}
							//} endregion
						}
						else
						{
							//{ region pass 1
							
							//{region Draw Background
							// in the second pass we render the inline content.
							actualDrawing.y = top;
							actualDrawing.x = left;
							// in case we overflowed, we dont want to draw backround over padding.
							var right:Number = Math.min(actualDrawing.x + actualDrawing.width, referenceArea().x + referenceArea().width);
							var bottom:Number = Math.min(actualDrawing.y + actualDrawing.height, referenceArea().y + referenceArea().height);
							renderObject.drawRectangle(backgroundColor, actualDrawing.x, actualDrawing.y, right, bottom);
							//renderObject.DrawRectangle(backgroundColor, m_actualDrawing.X, m_actualDrawing.Y, right, bottom);
							//} endregion
							
							//{ region Setup
							lineLength = 0;
							var leftMargin:Number = actualDrawing.x;
							var rightMargin:Number = actualDrawing.x + actualDrawing.width;
							var topMargin:Number = actualDrawing.y;
							var x_loc:Number = -1;
							var y_loc:Number = -1; // m_actualDrawing.Y;
							var breakLine:Boolean = true;
							var suppressWhitespace:Boolean = true;
							
							if (horizontal)
							{
								x_loc = -1;
								y_loc = topMargin;
							}
							else
							{
								if (mode == WritingMode.TOP_BOTTOM_LEFT_RIGHT)
								{
									x_loc = leftMargin;
									y_loc = -1;
								}
								else
								{
									x_loc = rightMargin - lineHeight.width;
									y_loc = -1;
								}
							}
							//} endregion
							
							//{ region fill the text buffer
							var alltext:String = "";
							for each (inlineContent in children)
							{
								content = inlineContent as InlineContent;
								isPreserve = content.preserveStyleProperty;
								
								// BUG - when we bidi the whole paragraph in one go, which
								// is  the proper way, we screw up the 
								// styling information. So for now we bidi in discrete lumps, which is wrong
								// but close enough for today.
								// 
								if (isPreserve)
								{
									alltext += (content.content);
								}
								else
								{
									alltext += (content.content);
									
									//var bidi:String = Paragraph.addBidirectionEncoding(content.content, content.unicodeBidirectionStyleProperty, content.directionStyleProperty);
									//alltext += bidi;
								}
							}
							
							var paragraphText:String = alltext;
							
							//#endregion
							
							var charCount:Number = 0;  // index into the combined text above.
							for each (inlineContent in children)
							{                        
								// bug - we need to collapse consecutive spaces beteen inlines.
								content = inlineContent as InlineContent;
								
								content.applyAnimations();
								var rtlWidth:Number = 0, rtlHeight:Number = 0;
								font = content.getFont(renderObject);
								extent = content.measureText(content.content, renderObject, font);
								rtlWidth = extent.width;
								rtlHeight = extent.height;
								if (content.displayStyleProperty != "none")
								{
									//{ region display content
									wrap = content.wrapOptionStyleProperty;
									isPreserve = content.preserveStyleProperty;
									
									if (isPreserve) suppressWhitespace = false;
									
									//{ region continue reposition after inline
									if (!breakLine && mode == WritingMode.RIGHT_LEFT_TOP_BOTTOM)
									{
										x_loc -= content.actualArea().width;
									}
									//} endregion
									
									
									if (content != null)
									{
										characters = content.content.split("");
										for (var i:uint = 0; i < content.content.length; i++)
										{
											// if the bidi algorithm elides characters this should hopefully catch it.
											if (charCount >= paragraphText.length) break;
											c = paragraphText[charCount];
											var advanceHeight:Number=0, advanceWidth:Number = 0;
											extent = content.measureText(c, renderObject, font);
											advanceWidth = extent.width;
											advanceHeight = extent.height;
											var softBreak:Boolean = wrap && (!(content.element is BrElement) && breakChars.indexOf(c)>=0);
											hardBreak = (content.element is BrElement) || (isPreserve && breakChars.indexOf(c)>=0);
											if (softBreak || hardBreak)  // soft breaks are inserted in pass 1.
											{
												//{ region Apply Line break
												if (horizontal)
												{
													y_loc += lineHeight.height;
												}
												else
												{
													if (mode == WritingMode.TOP_BOTTOM_LEFT_RIGHT)
													{
														x_loc += lineHeight.width; 
													}
													else
													{
														x_loc -= lineHeight.width;
													}
												}
												//} endregion
												breakLine = true;
												if (!isPreserve) suppressWhitespace = true;
												charCount++;
											}
											else
											{
												if (breakLine)
												{
													breakLine = false;
													//{ region Initialise new line
													if (mode == WritingMode.LEFT_RIGHT_TOP_BOTTOM)
													{
														x_loc = leftMargin + Paragraph.computeLeftMargin(renderObject, content, font, actualDrawing.width, paragraphText, charCount);
													}
													else if (mode == WritingMode.RIGHT_LEFT_TOP_BOTTOM)
													{
														layoutRight = rightMargin;
														x_loc = layoutRight - rtlWidth; // -ComputeLeftMargin(renderObject, content, font, m_actualDrawing.Width, paragraphText, charCount);
													} else
													{
														y_loc = top + Paragraph.computeLeftMargin(renderObject, content, font, actualDrawing.height, paragraphText, charCount);
													}
													//} #endregion
												}
												//{ region Render this character
												if (horizontal)
												{
													if (!(suppressWhitespace && Unicode.Whitespace.indexOf(c)>=0))
													{
														renderObject.drawRectangle(content.backgroundColorStyleProperty, x_loc, y_loc, x_loc + advanceWidth, y_loc + font.emHeight);
														Paragraph.renderChar(x_loc, y_loc, font, renderObject, content, c);
														x_loc += advanceWidth;
														lineLength += advanceWidth;
														if (Unicode.Whitespace.indexOf(c)>=0 && !isPreserve)
														{
															suppressWhitespace = true;
														} else
														{
															suppressWhitespace = false;
														}
													}
												}
												else
												{
													if (!(suppressWhitespace && Unicode.Whitespace.indexOf(c)>=0))
													{
														renderObject.drawRectangle(content.backgroundColorStyleProperty, x_loc, y_loc, x_loc + advanceWidth, y_loc + font.emHeight);
														Paragraph.renderChar(x_loc, y_loc, font, renderObject, content, c);
														y_loc += advanceHeight;
														lineLength += advanceHeight;
														if (Unicode.Whitespace.indexOf(c)>=0 && !isPreserve)
														{
															suppressWhitespace = true;
														} else
														{
															suppressWhitespace = false;
														}
													}
												}
												charCount++;
												//} endregion
											}
										}
									}
									//} endregion
								}
								else
								{
									charCount += content.content.length;
								}
								//{ region begin reposition after inline
								if (mode == WritingMode.RIGHT_LEFT_TOP_BOTTOM)
								{
									x_loc -= rtlWidth;
								}
								//} endregion
								content.removeAppliedAnimations();
							}
							//} endregion
						}
						//} endregion
					}
					
					removeAppliedAnimations();
					return;
				};
			return func;
		}
		
		private static function renderChar(x_loc:Number, y_loc:Number, font:Font, renderObject:IRenderObject, content:InlineContent, c:String):void
		{
			var outline:TextOutline = content.textOutlineStyleProperty;
			var fg:ColorExpression = content.colorStyleProperty;
			// Color bg = content.BackgroundColorStyleProperty;
			
			if (content.visibilityStyleProperty == "hidden")
			{
				fg = Colors.Transparent;
				// bg = Color.FromArgb(0x00, 0x00, 0x00, 0x00);
			}
			var sh:String = c;
			var data:MetadataInformation = new MetadataInformation();
			data.role = content.element.getMetadata("role");
			
			if (outline.width > 0 || outline.blur > 0)
			{
				renderObject.drawOutlineText(sh, font, fg, outline, x_loc, y_loc, data);
			}
			else
			{
				renderObject.drawText(sh, font, fg, content.textDecorationStyleProperty, x_loc, y_loc, data);
			}
			return;
		}
		
		/** 
		 * Find the length of the next rendered line.
		 * @param renderObject
		 * @param content
		 * @param font
		 * @param width
		 * @param characters
		 * @param startchar
		 * @returns
		 */
		private static function computeLeftMargin(renderObject:IRenderObject, content:InlineContent, font:Font, width:Number, characters:String, startchar:uint):Number
		{
			var direction:String = content.directionStyleProperty;
			var mode:WritingMode = content.writingModeStyleProperty;
			var margin:Number = width,
				marginL:Number = 0,
				marginT:Number = 0,
				extent:Extent;
			var i:uint = startchar;
			var j:uint = characters.indexOf('\n', i);
			var substring:String;
			if (j > i)
			{
				substring = characters.substring(i, j - i);
			}
			else
			{
				substring = characters.substring(i);
			}
			
			extent = content.measureText(substring, renderObject, font);
			marginL = extent.width;
			marginT = extent.height;
			
			if (mode == WritingMode.TOP_BOTTOM_LEFT_RIGHT || mode == WritingMode.TOP_BOTTOM_RIGHT_LEFT)
			{
				margin -= marginT;
			}
			else
			{
				margin -= marginL;
			}
			i++;
			
			switch (content.textAlignStyleProperty)
			{
				case "center":
					margin = margin / 2;
					break;
				case "start":
				case "left":
					if (direction == "ltr")
					{
						margin = 0;
					}
					break;
				case "end":
				case "right":
					if (direction == "rtl" || mode == WritingMode.LEFT_RIGHT_TOP_BOTTOM)
					{
						margin = 0;
					}
					break;
			}
			return margin;
		}
		
		public override function actualArea():Rectangle
		{
			return actualDrawing;
		}
	}
}