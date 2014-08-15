/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.captioning.parsers
{
	import flash.utils.Dictionary;
	
	import org.osmf.captioning.model.Caption;
	import org.osmf.captioning.model.CaptionFormat;
	import org.osmf.captioning.model.CaptionStyle;
	import org.osmf.captioning.model.CaptioningDocument;
	import org.osmf.utils.TimeUtil;
	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
	}

	/**
	 * This class parses a W3C Timed Text DFXP file and
	 * creates a document object model representation of 
	 * the file by returning a <code>CaptioningDocument</code> object
	 * from the <code>parse</code> method.  A load failure translates to
	 * an OSMF media load failed message.
	 * 
	 * A subset of the W3C Timed Text Authoring Format 1.0 - Distribution
	 * Format Exchange Profile (DFXP) is supported by this parser.
	 * 
	 * The subset supported by this class is specified here:
	 * <ul>
	 *	<li> <strong>tt</strong> tag</li>
	 * 		<ul>
	 * 			<li> All attributes of the tt tag are ignored.</li>
	 * 			<li> <strong>head</strong> tag</li>
	 * 			<ul>
	 * 				<li> head tag is not required.</li>
	 * 				<li> <strong>metadata</strong> tag is supported. The title, 
	 * description, and copyright attribute values are available via properties 
	 * of this class.</li>
	 * 				<li> <strong>layout</strong> tag and any child tags are ignored.</li>
	 * 				<li> <strong>styling</strong> tag is supported.</li>
	 * 				<ul>
	 * 					<li> <strong>style</strong> tags are supported.</li>
	 * 					<ul>
	 * 						<li> Each style tag must have a unique ID and the 
	 * following attributes are supported:</li>
	 * 						<ul>
	 * 							<li>tts:fontFamily</li>
	 * 							<li>tts:fontSize</li>
	 * 							<ul>
	 * 								<li> Support for only one value. If two values 
	 * are present only the first is used.</li>
	 * 								<li> Units are ignored, pixels are assumed.</li>
	 * 								<li> Percentages are not supported (e.g. 50%).</li>
	 * 								<li> Increment/decrement is not supported (e.g. +5).</li>
	 * 							</ul>
	 * 							<li>tts:fontStyle</li>
	 * 							<li>tts:fontWeight</li>
	 * 							<li>tts:textAlign</li>
	 * 							<li>tts:wrapOption</li>
	 * 							<li>tts:backgroundColor</li>
	 * 							<li>tts:color</li>
	 * 						</ul>
	 * 					</ul>
	 * 				</ul>
	 * 			</ul>
	 * 			<li> <strong>body</strong> tag</li>
	 * 			<ul>
	 * 				<li> body tag is required.</li>
	 * 				<li> Only one body tag is supported.</li>
	 * 				<li> All attributes of the body tag are ignored.</li>
	 * 				<li> <strong>div</strong> tag</li>
	 * 				<ul>
	 * 					<li> Supported but not required.</li>
	 * 					<li> Support for one div tag only.</li>
	 * 					<li> All attributes of the div tag are ignored.</li>
	 * 					<li> <strong>p</strong> tag</li>
	 * 					<ul>
	 * 						<li> Support for one or many.</li>
	 * 						<li> p tags contain the caption text and optionally any styles.</li>
	 * 						<li> Support for the attributes begin, dur, and end only. All other attributes are ignored.</li> 
	 * 						<ul>
	 * 							<li> If begin is absent, zero is assumed.</li> 
	 * 							<li> If both dur and end are present, dur will be ignored.</li>
	 * 							<li> The following time values are supported:</li>
	 * 						</ul>
	 * 						<ul>
	 * 							<li> full clock format in "hours:minutes:seconds:fraction" (e.g. 00:03:00:00).</li>
	 * 							<li> offset time (e.g. 10s for ten seconds or 1m for one minute).</li>
	 * 							<li> offset times without units (e.g. 10) are assumed to be seconds.</li>
	 * 						</ul>
	 * 						<li> styles can be 'inline', using a span tag, or referenced with a style ID</li>
	 * 						<li> <strong>span</strong> tags are supported.</li>
	 * 						<ul>
	 * 							<li> suppport for style attributes only, all other attributes are ignored.</li>
	 * 							<li> nested span tags are not supported.</li>
	 * 						</ul>
	 * 						<li> The <strong>br</strong> tag is supported.</li>
	 * 				</ul>
	 * 			</ul>
	 * 		</ul>
	 * 	</li>
	 * </ul>
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.0
	 *  @productversion OSMF 1.0
	 */
	public class DFXPParser implements ICaptioningParser
	{
		/**
		 * Constructor.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function DFXPParser()
		{
			super();
			
			namedColorMap = new Dictionary();
			
			namedColorMap["transparent"]= 0x000000;
			namedColorMap["black"]		= 0x000000;
			namedColorMap["silver"]		= 0xc0c0c0;
			namedColorMap["gray"]		= 0x808080;
			namedColorMap["white"]		= 0xffffff;
			namedColorMap["maroon"]		= 0x800000;
			namedColorMap["red"]		= 0xff0000;
			namedColorMap["purple"]		= 0x800080;
			namedColorMap["fuchsia"]	= 0xff00ff;
			namedColorMap["magenta"]	= 0xff00ff;
			namedColorMap["green"]		= 0x008000;
			namedColorMap["lime"]		= 0x00ff00;
			namedColorMap["olive"]		= 0x808000;
			namedColorMap["yellow"]		= 0xffff00;
			namedColorMap["navy"]		= 0x000080;
			namedColorMap["blue"]		= 0x0000ff;
			namedColorMap["teal"]		= 0x008080;
			namedColorMap["aqua"]		= 0x00ffff;
			namedColorMap["cyan"]		= 0x00ffff;
		}

		/**
		 * Parses the raw data passed in which should represent
		 * a W3C Timed Text DFXP file and returns a <code>CaptioningDocument</code>
		 * object which represents the root level object of the file's
		 * document object model.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function parse(rawData:String):CaptioningDocument
		{
			var document:CaptioningDocument = new CaptioningDocument();
			var saveXMLIgnoreWhitespace:Boolean = XML.ignoreWhitespace;
			var saveXMLPrettyPrinting:Boolean = XML.prettyPrinting; 
			
			// Remove line ending whitespaces
			var xmlStr:String = rawData.replace(/\s+$/, "");
			
			// Remove whitespaces between tags
			xmlStr = xmlStr.replace(/>\s+</g, "><");

			// Tell the XML class to show white space in text nodes		
			XML.ignoreWhitespace = false;
			// Tell the XML class not to normalize white space for toString() method calls
			XML.prettyPrinting = false;
			
			try
			{
				var xml:XML = new XML(xmlStr);
			}
			catch (e:Error)
			{
				debugLog("Unhandled exception in DFXPParser : "+e.message);
				throw e;				
			}
			finally
			{
				XML.ignoreWhitespace = saveXMLIgnoreWhitespace;
				XML.prettyPrinting = saveXMLPrettyPrinting;
			}
			
			rootNamespace = xml.namespace();
			
			ns = xml.namespace();
			ttm = xml.namespace("ttm");
			tts = xml.namespace("tts");
			
			try 
			{
				parseHead(document, xml);
				parseBody(document, xml);		
			}
			catch (err:Error) 
			{
				debugLog("Unhandled exception in DFXPParser : "+err.message);
				throw err;
			}
			
			return document;
		}		
			
			
		private function parseHead(doc:CaptioningDocument, xml:XML):void 
		{
			// Metadata - not required
			try 
			{
				doc.title = xml..ttm::title.text();
				doc.description = xml..ttm::desc.text();
				doc.copyright = xml..ttm::copyright.text();
			}
			catch (err:Error) 
			{
				// Catch only this one: "Error #1080: Illegal value for namespace." This
				// means the document is missing some of the metadata tags we tried to
				// access, not a fatal error.
				if (err.errorID != 1080) 
				{
					throw err;
				}
			}
			
			// Styles - not required
			var styling:XMLList = xml..ns::styling;
			
			if (styling.length()) 
			{
				var styles:XMLList = styling.children();
				for (var i:uint = 0; i < styles.length(); i++) 
				{
					var styleNode:XML = styles[i];
					var styleObj:CaptionStyle = createStyleObject(styleNode);
					
					doc.addStyle(styleObj);
				}
			}			
		}
		
		/**
		 * Creates a CaptionStyle from a style node.
		 */
		private function createStyleObject(styleNode:XML):CaptionStyle 
		{
			var id:String = styleNode.@*::id;
			var styleObj:CaptionStyle = new CaptionStyle(id);
			
			var colorValue:Object;
			
			var color:String = styleNode.@tts::backgroundColor;
			if (color != "") 
			{
				colorValue = parseColor(color);	
				styleObj.backgroundColor = colorValue.color;
				styleObj.backgroundColorAlpha = colorValue.alpha;
			}
			styleObj.textAlign = styleNode.@tts::textAlign;
			
			color = styleNode.@tts::color;
			if (color != "") 
			{
				colorValue = parseColor(color);
				styleObj.textColor = colorValue.color;
				styleObj.textColorAlpha = colorValue.alpha;	
			}
			
			styleObj.fontFamily = parseFontFamily(styleNode.@tts::fontFamily);
			
			var fontSize:String = parseFontSize(styleNode.@tts::fontSize);
			styleObj.fontSize = parseInt(fontSize);
			
			styleObj.fontStyle = styleNode.@tts::fontStyle;
			styleObj.fontWeight = styleNode.@tts::fontWeight;
			styleObj.wrapOption = (String(styleNode.@tts::wrapOption).toLowerCase() == "nowrap") ? false : true;

			return styleObj;			
		}
		
		/**
		 * Takes a string in the valid formats specified by the W3C Timed Text 
		 * standard which include:<ul>
		 * <li>#rrggbb - each color value is a hexadecimal digit, such as #ff0000 for red</li>
		 * <li>#rrggbbaa - each color value is a hexadecial digit, such as #ff0000ff for fully opaque red</li>
		 * <li>rgb(red, green, blue) - each value has a range from 0 - 255</li>
		 * <li>rgba(red, green, blue, alpha) - each value has a range from 0 - 255</li>
		 * </ul>
		 * 
		 * and returns an Object with the following properties:<ul>
		 * <li>color : a hexadecimal value representing the color, for example, 0xff0000 is red.</li>
		 * <li>alpha : a Number between 0 and 1 specifying the alpha transparency</li>
		 * </ul>
		 */
		private function parseColor(colorStr:String):Object 
		{
			var colorValue:Object;
			var alphaValue:Object;
			
			// First check for #rrggbb and #rrggbbaa formats
			var pattern:RegExp = /^\s*#([\dA-Fa-f][\dA-Fa-f][\dA-Fa-f][\dA-Fa-f][\dA-Fa-f][\dA-Fa-f])([\dA-Fa-f][\dA-Fa-f])?\s*$/;
			var result:Array = colorStr.match(pattern);
			 
			if (result != null) 
			{
				colorValue = parseInt(result[1], 16);
				if (result.length == 3)
				{
					alphaValue = Number(parseInt(result[2])/255);
				}
			} 
			else  
			{
				// Next check for rgb(r,g,b) and rgba(r, g, b, a) formats
				pattern = /^\s*rgb(a)?\((\d+),(\d+),(\d+)(\)|(,(\d+)\)))\s*$/i;
				result = colorStr.match(pattern);
				
				if (result != null && result.length >= 5)
				{
					colorValue = (parseInt(result[2]) << 16) + (parseInt(result[3]) << 8) + parseInt(result[4]);
					if (result.length == 8 && result[7] != undefined)
					{
						alphaValue = Number(parseInt(result[7])/255);
					}
				}
				else 
				{
					// Check for named color values
					colorValue = namedColorMap[colorStr.toLowerCase()]; 
					if (colorValue == null)
					{
						// Finally, just take what we got
						colorValue = parseInt(colorStr);
						if (isNaN(int(colorValue)))
						{
							colorValue = null;
							debugLog("Invalid DFXP document: invalid color value of " + colorStr);
						} 
					}
				}
			}
			
			return {color:colorValue, alpha:alphaValue};
		}
		
			
		private function parseFontSize(rawFontSize:String):String 
		{
			if (!rawFontSize || rawFontSize == "") 
			{
				return "";
			}	
			
			var returnValue:String = "";
			
			// Check for percentage, e.g., 50%
			var perRegExp:RegExp = new RegExp(/^\s*\d+%.*$/);
			var perResult:Object = perRegExp.exec(rawFontSize);
						
			if (perResult) 
			{
				// Percentages not supported
				debugLog("Invalid DFXP document: percentages are not supported for font size.");
				returnValue = "";	
			}
			else
			{
				// Check for increment, e.g., +5
				var incRegExp:RegExp = new RegExp(/^\s*[\+\-]\d.*/);
				var incResult:Object = incRegExp.exec(rawFontSize);
				
				if (incResult) 
				{
					// Increment not supported
					debugLog("Invalid DFXP document: increment values are not supported for font size.");
					returnValue = "";
				}
				else
				{
					var regExp:RegExp = new RegExp(/^\s*(\d+).*$/);
					var result:Object = regExp.exec(rawFontSize);
					
					if (result && (result[1] != undefined)) 
					{
						returnValue = result[1];
					}
				}
			}
			return returnValue;
		}
		
		private function parseFontFamily(rawFontFamily:String):String 
		{
			if (!rawFontFamily || rawFontFamily == "") 
			{
				return "";
			}
			
			var retVal:String = "";
			var regExp:RegExp = new RegExp(/^\s*([^,\s]+)\s*((,\s*([^,\s]+)\s*)*)$/);
			var done:Boolean = false;
			
			do 
			{
				var result:Object = regExp.exec(rawFontFamily);
				if (!result) 
				{
					done = true;
				}
				else 
				{
					if (retVal.length > 0) 
					{
						retVal += ",";
					} 
					
					// These generic family names are right out of the W3C spec. We need to map them to one of the Flash player's
					// three default fonts: "_sans", "_serif", and "_typewriter". The Flash player will find the closest font
					// on the user's system at run-time.
					switch (result[1]) 
					{
						case "default":
						case "serif":
						case "proportionalSerif":
							retVal += "_serif";
							break;					
							
						case "monospace":
						case "monospaceSansSerif":
						case "monospaceSerif":
							retVal += "_typewriter";
							break;
							
						case "sansSerif":
						case "proportionalSansSerif":
							retVal += "_sans";
							break;
							
						default:
							retVal += result[1];
							break;
					}
					
					if ((result[2] != undefined) && (result[2] != "")) 
					{
						rawFontFamily = result[2].slice(1);
					}
					else 
					{
						done = true;
					}
				}
				
			} while (!done);
			
			return retVal;			
		}
		
		private function parseBody(doc:CaptioningDocument, xml:XML):void 
		{
			// The <body> tag is required
			var body:XMLList = xml..ns::body;
			if (body.length() <= 0) 
			{
				debugLog("Invalid DFXP document: <body> tag is required.");
			}
			else
			{
				// Support for one <div> tag only, but it is not required
				var div:XMLList = xml..ns::div;
				
				// Support for 1 to many <p> tags, these tags contain the timing info, they can appear in any order
				var p:XMLList = div.length() ? div.children() : (body.length() ? body.children() : new XMLList());
				
				// Captions should be in <p> tags
				for (var i:uint = 0; i < p.length(); i++) 
				{
					var pNode:XML = p[i];
					
					// According the W3C, foreign namespaces should be ignored for p tags
					if (rootNamespace == pNode.namespace())
					{
						parsePTag(doc, pNode, i);
					}
					else
					{
						debugLog("Ignoring this tag, foreign namespaces not supported: \""+pNode+"\"");
					}
				}
			}			
		}
		
		private function parsePTag(doc:CaptioningDocument, pNode:XML, index:uint):void 
		{
			// For timing attributes, we support 'begin', 'dur', 'end', all others are ignored.
			// If the attribute 'begin' is missing, we default to zero.
			// If both 'dur' and 'end' are present, the 'end' attribute is used
			
			var begin:String = pNode.@begin;
			var end:String = pNode.@end;
			var dur:String = pNode.@dur;
										
			// If no 'begin' default to 0 seconds
			if (begin == "") 
			{
				begin = "0s";
			}
			
			// Format begin in seconds
			var beginSecs:Number = TimeUtil.parseTime(begin);
			
			var endSecs:Number = 0;
			
			// If we found both 'end' and 'dur', ignore 'dur'
			if (end != "") 
			{
				endSecs = TimeUtil.parseTime(end);
			}
			else if (dur != "") 
			{
				endSecs = beginSecs + TimeUtil.parseTime(dur);
			}
									
			var captionFormatList:Array = new Array();

			// Create the caption text, we don't support nested span tags
			var text:String = new String("<p>");
			
			var children:XMLList = pNode.children();
			for (var i:uint = 0; i < children.length(); i++) 
			{
				var child:XML = children[i];
				switch (child.nodeKind()) 
				{
					case "text":
						text += formatCCText(child.toString());
						break;
					case "element":
						switch (child.localName()) 
						{
							case "set":
							case "metadata":
								break;	// We don't support these in <p> tags
							case "span":
								var styleStartIndex:uint = calcClearTextLength(text);
								var spanText:String;
								
								var stylesList:Array = new Array();

								text += parseSpanTag(doc, child, stylesList);
												
								var styleEndIndex:uint = calcClearTextLength(text);
								
								for each (var styleObject:CaptionStyle in stylesList) 
								{
									var fmtObj:CaptionFormat = new CaptionFormat(styleObject, styleStartIndex, styleEndIndex);
									captionFormatList.push(fmtObj);
								}
								break;
							case "br":
								text += "<br />";
								break;
							default:
								text += formatCCText(child.toString());
								break;
						}
						break;
				}
			}
			
			text += "</p>";

			var captionItem:Caption = new Caption(index, beginSecs, endSecs, text);
			
			// If there is a style attribute, parse that
			var styleObj:CaptionStyle = parseStyleAttrib(doc, pNode);
			if (styleObj) 
			{
				var formatObj:CaptionFormat = new CaptionFormat(styleObj);
				captionItem.addCaptionFormat(formatObj);
			}
			
			// If there were styles in the span tag(s), add those
			for (i = 0; i < captionFormatList.length; i++) 
			{
				captionItem.addCaptionFormat(captionFormatList[i]);
			}
		
			doc.addCaption(captionItem);		
		}
		
		/**
		 * If an element has a style attribute specifying a style id, such as <code><p style="1">Caption text</p></code>,
		 * this method looks up the style object read from the head tag and returns it.
		 * 
		 * If an element has an attribute in the TT Style namespace, such as <code><span tts:color="green">some green text</span></code>,
		 * this method parses that attribute and returns a new style object.
		 */
		private function parseStyleAttrib(doc:CaptioningDocument, node:XML):CaptionStyle 
		{
			var styleId:String = node.@style;
			var captionStyle:CaptionStyle = null;
			
			// See if it references a style tag with an ID attribute
			if (styleId != "") 
			{
				for (var i:uint; i < doc.numStyles; i++) 
				{
					if (doc.getStyleAt(i).id == styleId) 
					{
						captionStyle = doc.getStyleAt(i);
					}
				}
			}
			else 
			{
				try
				{				
					var attributes:XMLList = node.@tts::*;
				}
				catch (err:Error) 
				{
					// Catch only this one: "Error #1080: Illegal value for namespace." This
					// means the document is missing the xmlns:tts declartion in the tt tag, 
					// not a fatal error.
					if (err.errorID != 1080) 
					{
						throw err;
					}
				}
				
				for (i = 0; (attributes != null) && (i < attributes.length()); i++) 
				{
					var attrib:XML = attributes[i];
					var localName:String = attrib.localName();
					
					if (localName == "inherit") 
					{
						continue;
					}
					else 
					{
						captionStyle = createStyleObject(node);
					}
				}
			}
			return captionStyle;
		}
		
		private function parseSpanTag(doc:CaptioningDocument, spanNode:XML, styles:Array):String 
		{
			// Look for style attribute
			var styleObj:CaptionStyle = parseStyleAttrib(doc, spanNode);
			
			if (styleObj != null)
			{
				styles.push(styleObj);
			}
			
			var ccText:String = new String();
			var children:XMLList = spanNode.children();
			
			for (var i:uint = 0; i < children.length(); i++ ) 
			{
				var child:XML = children[i];
				
				switch (child.nodeKind()) 
				{
					case "text":
						ccText += formatCCText(child.toString());
						break;
					case "element":
						switch (child.localName()) 
						{
							case "set":
							case "metadata":
								break;	// We don't support these in <span> tags
							case "br":
								ccText += "<br/>";
								break;
							default:
								ccText += child.toString();
								break;
						}
						break;
				}
			}

			return ccText;
		}
				
		private function formatCCText(txt:String):String 
		{
			var retString:String = txt.replace(/\s+/g, " ");
			return retString;
		}
			
		/**
		 * Utility method to calculate the length
		 * of a string non-inclusive of any HTML tags.
		 */
		private function calcClearTextLength(txt:String):int
		{
			var clrTxt:String = txt.replace(/<(.|\n)*?>/g, "");
			return clrTxt.length;
		}
		
		private function debugLog(msg:String):void
		{
			CONFIG::LOGGING
			{
				if (logger != null)
				{					
					logger.debug(msg);
				}
			}
		}
		
		private var ns:Namespace;
		private var ttm:Namespace;
		private var tts:Namespace;
		private var rootNamespace:Namespace;
		private var namedColorMap:Dictionary;
		
		CONFIG::LOGGING
		{	
			private static const logger:Logger = org.osmf.logging.Log.getLogger("org.osmf.captioning.parsers.DFXPParser");		
		}	
		
	}
}
