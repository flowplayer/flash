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
package org.osmf.smpte.tt.model
{
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import org.osmf.smpte.tt.errors.SMPTETTException;
	import org.osmf.smpte.tt.formatting.FormattingObject;
	import org.osmf.smpte.tt.model.metadata.AgentElement;
	import org.osmf.smpte.tt.model.parameter.ParameterElement;
	import org.osmf.smpte.tt.styling.AutoExtent;
	import org.osmf.smpte.tt.styling.AutoOrigin;
	import org.osmf.smpte.tt.styling.ColorExpression;
	import org.osmf.smpte.tt.styling.Extent;
	import org.osmf.smpte.tt.styling.FontSize;
	import org.osmf.smpte.tt.styling.FontStyleAttributeValue;
	import org.osmf.smpte.tt.styling.FontWeightAttributeValue;
	import org.osmf.smpte.tt.styling.Inherit;
	import org.osmf.smpte.tt.styling.LineHeight;
	import org.osmf.smpte.tt.styling.NormalHeight;
	import org.osmf.smpte.tt.styling.NumberPair;
	import org.osmf.smpte.tt.styling.Origin;
	import org.osmf.smpte.tt.styling.PaddingThickness;
	import org.osmf.smpte.tt.styling.TextDecorationAttributeValue;
	import org.osmf.smpte.tt.styling.TextOutline;
	import org.osmf.smpte.tt.timing.ClockMode;
	import org.osmf.smpte.tt.timing.SmpteMode;
	import org.osmf.smpte.tt.timing.TimeBase;
	import org.osmf.smpte.tt.timing.TimeCode;
	import org.osmf.smpte.tt.timing.TimeContainer;
	import org.osmf.smpte.tt.timing.TimeExpression;
	import org.osmf.smpte.tt.timing.TreeType;
	import org.osmf.smpte.tt.utilities.DictionaryUtils;
	import org.osmf.smpte.tt.utilities.StringUtils;
	import org.osmf.smpte.tt.vocabulary.Namespaces;
	
	public class TimedTextElementBase extends TreeType
	{
		public function TimedTextElementBase()
		{
		}
		
		//{ region Properties
		public var language:String;
		
		public var localName:String;
		
		public var namespace:Namespace;
		
		public var body:BodyElement;
		
		public var id:String;
		
		public var root:TtElement;
		//} endregion
		
		//{ region Local members
		private var _styling:Dictionary = new Dictionary();
		
		public static var defaultZ:Number = 0.0001;
		//} endregion
		
		//{ region Error handler
		protected static function error(message:String):void
		{
			//trace("[ERROR] "+ " "+ message);
			try {
				throw new SMPTETTException(message);
			} catch (err:SMPTETTException){
				trace("[ERROR] "+ err +" "+ err.message);
			}
		}
		//} endregion
		
		//{ region static tt_element GetElementFromName(string elem)
		/** 
		 * Instantiate one of the TimedText.* classes from a string representing its name. 
		 * 
		 * @param elem name of the class to instantiate
		 * @returns descendent of tt_element
		 */
		public static function getElementFromName(elem:String):TimedTextElementBase
		{
			var ClassReference:Class = getDefinitionByName(elem) as Class;
			
			if (ClassReference != null)
			{
				return new ClassReference() as TimedTextElementBase;
			}
			else
			{
				error("No such element (" + elem + ") in namespace");
			}
			return null;
		}
		//} endregion
		
		//{ region public virtual bool Valid()
		/**
		 * Test validity of this subtree
		 * @returns true if valid
		 */
		public function valid():Boolean
		{
			try
			{
				validElements();
				validAttributes();  // this has to happen 2nd as we move attributes in ValidElements
			}
			catch (ex:SMPTETTException)
			{
				error(ex.message);
				return false;
			}
			return true;
		}
		//} endregion
		
		//{ region Element Validity
		/**
		 * Test whether an element's content model, and all its descendants are valid Timed Text
		 * 
		 * @throws an exception if invalid.
		 */
		protected function validElements():void
		{
		};
		
		/**
		 * Test whether an element's attributes are allowed by Timed Text
		 * 
		 * @throws an exception if invalid.
		 */
		protected function validAttributes():void 
		{ 
		};
		//} endregion
		
		//{ region public virtual bool Valid()
		/** 
		 * Set a local style on this element allows modification at runtime.
		 *
		 *  @param property
		 *  @param value
		 */
		public function setLocalStyle(property:String, value:*):void
		{ 
			_styling[property] = value;
		}
		
		/** 
		 * Clear local style on this element
		 * 
		 * @param property
		 */
		public function clearLocalStyle(property:String):void
		{
			delete _styling[property]
		}
		//} endregion
		
		//{ region public object GetReferentStyle(string property)
		/** 
		 * Look up a style property in any referent style elements.
		 * 
		 * @param property
		 */
		public function getReferentStyle(property:String):Object
		{
			var styleCount:uint = DictionaryUtils.getLength(_styling);

			// check for local override, this will always win
			if (styleCount > 0 && _styling[property] !== undefined)
			{	
				return _styling[property];
			}
			
			// find out if we refer to any other styles.
			var referentStyles:Vector.<String> = _styling["style"] as Vector.<String>;
			if (styleCount > 0 && referentStyles)
			{
				if (referentStyles == null || referentStyles.length == 0)
				{
					_styling[property] = null;
					return null;
				} 
				// recursively check them in reverse order.
				var i:int = referentStyles.length - 1;
				while (i >= 0)
				{
					var s:String = referentStyles[i];
					var styleElement:StyleElement = root.styles[s] as StyleElement;
					if (styleElement)
					{
						var result:* = styleElement.getReferentStyle(property);
						if (result != null)
						{	
							_styling[property] = result;
							return result;
						}
					}
					i--;
				}
				
			}
			return null;
		}
		//} endregion
		
		//{ region public virtual object GetComputedStyle(string property)
		/**
		 * Get the final computed value for a style property from this element
		 * 
		 * @param propertyName 
		 * @param currentRegion 
		 */
		public function getComputedStyle(propertyName:String, currentRegion:RegionElement):*
		{
			
			var value:*;
			
			value = getReferentStyle(propertyName);

			// to do: special case visibility, as the parent value=hidden trumps the child value.
			if (value == null || (value is Inherit))
			{
				value = getInheritedStyle(propertyName, currentRegion);
			}
			
			_styling[propertyName] = value;
			
			return value;
		}
		
		/**
		 * Get the computed value for a style property from this element's parent region
		 * 
		 * @param propertyName 
		 * @param currentRegion 
		 */
		public function getInheritedStyle(propertyName:String, currentRegion:RegionElement):Object
		{
			var isBodyElement:Boolean = (this is BodyElement);
			var canInherit:Boolean = !isBodyElement && !(this is RegionElement);

			// we don't want the same background colors to to be 
			// inherited by a container element and an inline element.
			if(this is SpanElement && propertyName == "backgroundColor")
			{
				canInherit = false;
			}
			
			if (parent != null && canInherit)
			{	
				return TimedTextElementBase(parent).getComputedStyle(propertyName, currentRegion);
			} if (isBodyElement && currentRegion != null)
			{
				// body needs to inherit from the region it has been parented to
				return currentRegion.getComputedStyle(propertyName, null);
			}
			else
			{
				/// return initial value.
				return TimedTextAttributeBase.getInitialStyle(propertyName);
				
			}
		}
		//} endregion
		
		//{ region Layout
		/**
		 * sub classes need to override this.
		 */
		public function getFormattingObject(tick:TimeCode):FormattingObject
		{
			return null;
		}
		//} endregion
		
		public function writeElement(writer:XML, isRoot:Boolean = false):void
		{
			var xml:XML;
			if(isRoot)
			{
				xml = writer;
			} else 
			{
				xml = <{localName}/>;
				xml.setNamespace(Namespaces.TTML_NS);
				xml.addNamespace(Namespaces.TTML_STYLING_NS);
				xml.addNamespace(Namespaces.TTML_PARAMETER_NS);
				xml.addNamespace(Namespaces.TTML_METADATA_NS);
				xml.addNamespace(Namespaces.XML_NS);
			}
			writeAttributes(xml);
			for each (var element:TimedTextElementBase in children)
			{		
				element.writeElement(xml);
			}
			if(this is TimedTextElementBase && !isRoot)
			{
				writer.appendChild(xml);
			}
		}
		
		public function writeAttributes(writer:XML):void
		{
			for each (var a:TimedTextAttributeBase in attributes)
			{
				var aNS:Namespace = (writer.namespace(a.namespace.prefix) == a.namespace) 
									? writer.namespace(a.namespace.prefix) 
									: new Namespace(a.namespace.prefix,a.namespace.uri);
				writer.@aNS::[a.localName] = a.value;
			}
		}
		
		public function serialize():String
		{	
			
			if (localName == null) return (this is AnonymousSpanElement) ? (this as AnonymousSpanElement).text : "";
			var xml:XML = <{localName}></{localName}>;
			xml.setNamespace(Namespaces.TTML_NS);
			xml.addNamespace(Namespaces.TTML_STYLING_NS);
			xml.addNamespace(Namespaces.TTML_PARAMETER_NS);
			xml.addNamespace(Namespaces.TTML_METADATA_NS);
			xml.addNamespace(Namespaces.XML_NS);
			writeElement(xml, true);
			return xml.toXMLString();
		}
		
		//{ Attribute Validation
		/** 
		 * Validate attribute classes
		 * 
		 * @param parameterSet true if required to validate parameter attributes
		 * @param metadataSet true if required to validate metadata attributes
		 * @param styleSet true if required to validate style attributes
		 * @param timingSet true if required to validate timing attributes
		 * @param regionSet true if required to validate region attributes
		 * @param timeContainerSet true if required to time container parameter attributes
		 */
		protected function validateAttributes(parameterSet:Boolean, metadataSet:Boolean, 
											  styleSet:Boolean, timingSet:Boolean, 
											  regionSet:Boolean, timeContainerSet:Boolean):void
		{				
			var seenStyleAttributeInSet:Boolean = false;
			
			// now check each of the attributes is individually valid
			for each (var attribute:TimedTextAttributeBase in attributes)
			{
				if (attribute.isXmlAttribute())
				{
					validXmlAttributeValue(attribute);
					//trace(this+"\t"+attribute.localName +" is validXmlAttributeValue "+attribute.value);			
				} else if (attribute.isMetadataAttribute())
				{
					if (metadataSet)
					{	
						validMetadataAttributeValue(attribute);
						//trace("\t"+attribute.localName +" is validMetadataAttributeValue");
					}else
					{	
						error("invalid metadata attribute");
					}
				} else if (attribute.isParameterAttribute())
				{
					if (parameterSet)
					{	
						validParameterAttribute(attribute);
						//trace("\t"+attribute.localName +" is validParameterAttribute");
					}else
					{	
						error("invalid parameter attribute");
					}
				} else if (attribute.isStyleAttribute())
				{
					var isSetElement:Boolean = (this is SetElement);
					if (styleSet)
					{
						if (seenStyleAttributeInSet && isSetElement)
						{ 
							error("set only allows a single style attribute");
						}
						if (isSetElement)
						{
							seenStyleAttributeInSet = true;
						}
						validStyleAttributeValue(attribute);
						//trace("\t"+attribute.localName +" is validStyleAttributeValue");
					} else if (this is TtElement && attribute.localName == "extent")
					{
						validStyleAttributeValue(attribute);
						//trace("\t"+attribute.localName +" is validStyleAttributeValue");
					} else 
					{
						error("invalid style attribute");
					}
				} else if (attribute.isTimedTextAttribute())
				{
					switch (attribute.localName)
					{
						case "id" :
							// this is actually invalid, but we ignore for the time being.
							validXmlAttributeValue(attribute);
							break;
						case "style" :
							validStyleReference(attribute);
							//trace("\t"+attribute.localName +" is validStyleReference");
							break;
						case "begin":
							if (timingSet)
							{
								timing["begin"] = TimeExpression.parse(attribute.value);
								//trace("begin: "+(timing["begin"] as TimeCode).toString());
							} else
							{
								error("invalid begin attribute");
							}
							break;
						case "end":
							if (timingSet)
							{
								timing["end"] = TimeExpression.parse(attribute.value);
								//trace("end: "+(timing["end"] as TimeCode).toString());
							} else
							{
								error("invalid begin attribute");
							}
							break;
						case "dur":
							if (timingSet)
							{
								timing["dur"] = TimeExpression.parse(attribute.value);
								//trace("dur: "+(timing["dur"] as TimeCode).toString());
							} else
							{
								error("invalid begin attribute");
							}
							break;						
						case "region":
							if (regionSet)
							{
								validRegionAttribute(attribute);
								//trace("\t"+attribute.localName +" is validRegionAttribute");
							} else
							{
								error("Erroneous region attribute " + attribute.localName + " on " + this);
							}
							break;
						case "timeContainer":
							if (timeContainerSet)
							{
								validTimeContainerAttribute(attribute);
								//trace("\t"+attribute.localName +" is validTimeContainerAttribute");
							} else
							{
								error("Erroneous time container attribute " + attribute.localName + " on " + this);
							}
							break;
						default:							
							error("Erroneous tt: namespace attribute " + attribute.localName + " on " + this);
							break;
					}
				}
			}
		}
		
		/**
		 * Validate a parameter attribute
		 * 
		 * @param attribute
		 */
		protected function validParameterAttribute(attribute:TimedTextAttributeBase, feature:Boolean=false, value:String=""):void
		{
			
			if (!(this is TtElement)) return;
			
			switch (attribute.localName)
			{
				case "cellResolution":
					NumberPair.setCellSize(attribute.value);
					break;
				case "clockMode":
					switch (attribute.value)
					{
						case "local":
							TimeExpression.CurrentClockMode = ClockMode.LOCAL;
							break;
						case "gps":
							TimeExpression.CurrentClockMode = ClockMode.GPS;
							break;
						case "utc":
							TimeExpression.CurrentClockMode = ClockMode.UTC;
							break;
					}
					break;
				case "frameRate":
					// TO DO - put some error checking in here!
					TimeExpression.CurrentFrameRate = parseInt(attribute.value);
					break;
				case "frameRateMultiplier":
					// TO DO - put some error checking in here!
					var delimeter:String = (/\:/g.test(attribute.value)) ? ':' : ' ' ;
					var parts:Vector.<String> = Vector.<String>(attribute.value.split(delimeter));
					TimeExpression.CurrentFrameRateNominator = parseInt(parts[0]);
					TimeExpression.CurrentFrameRateDenominator = Math.max(1, parseInt(parts[1]));
					break;
				case "markerMode":
					root.parameters[attribute.localName] = attribute.value;
					break;
				case "pixelAspectRatio":
					root.parameters[attribute.localName] = attribute.value;
					break;
				case "profile":
					if (DictionaryUtils.getLength(ParameterElement.features) == 0)
					{ // we have not seen a profile element, OK to proceed
						validProfileAttribute(attribute);
					}
					break;
				case "smpteMode":
					switch (attribute.value)
					{
						case "dropNTSC":
							TimeExpression.CurrentSmpteMode = SmpteMode.DROP_NTSC;
							break;
						case "dropPAL":
							TimeExpression.CurrentSmpteMode = SmpteMode.DROP_PAL;
							break;
						case "nonDrop":
							TimeExpression.CurrentSmpteMode = SmpteMode.NON_DROP;
							break;
					}
					break;
				case "subFrameRate":
					// TO DO - put some error checking in here!
					TimeExpression.CurrentSubFrameRate = parseInt(attribute.value);
					break;
				case "tickRate":
					// TO DO - put some error checking in here!
					TimeExpression.CurrentTickRate = parseInt(attribute.value);
					break;
				case "timeBase":
					switch (attribute.value)
					{
						case "media":
							TimeExpression.CurrentTimeBase = TimeBase.MEDIA;
							break;
						case "smpte":
							TimeExpression.CurrentTimeBase = TimeBase.SMPTE;
							break;
						case "clock":
							TimeExpression.CurrentTimeBase = TimeBase.CLOCK;
							break;
					}
					break;
				default:
					error("Erroneous parameter attribute on  " + this);
					break;
			}
		}
		
		/**
		 * Validate a profile attribute
		 * 
		 * @param attribute
		 */
		protected static function validProfileAttribute(attribute:TimedTextAttributeBase):void
		{
			
			var profile:URLRequest = new URLRequest("http://www.w3.org/ns/ttml/profile/");
			var designator:URLRequest;
			try
			{
				designator = new URLRequest(profile.url+attribute.value);
				var f:*;
				switch (designator.url)
				{
					case "http://www.w3.org/ns/ttml/profile/dfxp-transformation":
						for each (f in ParameterElement.transformProfile)
						{
							if (ParameterElement.features[f.key] !== undefined)
							{   // if local profile has added this, then dont over-ride it
								ParameterElement.features[f.key] = f.value;
							}
						}
						break;
					case "http://www.w3.org/ns/ttml/profile/dfxp-presentation":
						for each (f in ParameterElement.presentationProfile)
						{
							if (ParameterElement.features[f.key] !== undefined)
							{   // if local profile has added this, then dont over-ride it
								ParameterElement.features[f.key] = f.value;
							}
						}
						break;
					case "http://www.w3.org/ns/ttml/profile/dfxp-full":
						for each (f in ParameterElement.presentationProfile)
						{
							if (ParameterElement.features[f.key] !== undefined)
							{   // if local profile has added this, then dont over-ride it
								ParameterElement.features[f.key] = f.value;
							}
						}
						for each (f in ParameterElement.transformProfile)
						{
							if (ParameterElement.features[f.key] !== undefined)
							{   // if local profile has added this, then dont over-ride it
								ParameterElement.features[f.key] = f.value;
							}
						}
						break;
					default:
						throw new SMPTETTException("unrecognized profile " + designator.url);
						break;
				}
			}
			catch (err:SMPTETTException)
			{
				throw new SMPTETTException("unrecognized profile " + attribute.value);
			}
		}
		
		/**
		 * Validate a time container attribute
		 * 
		 * @param attribute
		 */
		protected function validTimeContainerAttribute(attribute:TimedTextAttributeBase):void
		{
			switch (attribute.value)
			{
				case "par":
					timing["timeContainer"] = TimeContainer.PAR;
					timeSemantics = TimeContainer.PAR;
					break;
				case "seq":
					timing["timeContainer"] = TimeContainer.SEQ;
					timeSemantics = TimeContainer.SEQ;
					break;
				default:
					error("Erroneous value for timeContainer on " + this);
					break;
			}
		}		
		
		/**
		 * Validate a region attribute
		 * 
		 * @param attribute
		 */
		protected function validRegionAttribute(attribute:TimedTextAttributeBase):void
		{	
			// strictly speaking region is not a style attribute, but this is convenient.
			_styling["region"] = attribute.value;
			
		}
		
		/**
		 * Validate a style reference attribute
		 * 
		 * @param attribute
		 */
		protected function validStyleReference(attribute:TimedTextAttributeBase):void
		{
			
			//  IDREFS allow only a single space between names. Not sure what happens here if there are multiple.
			// we should do a pattern match to ensure its legal.
			var idrefs:Vector.<String> = new Vector.<String>();
			var whitespace:String = " ";
			var attributeArray:Array = attribute.value.split(whitespace);
			for each (var s:String in attributeArray)
			{
				// to do - what we want to do here is check it's in m_styles; however that won't work for 
				// forward references in styling; can we get a spec restriction here?.
				s = StringUtils.trim(s);
				if(s.length>0){
					idrefs[idrefs.length] = s;
				}
			}
			// strictly speaking style is not a style attribute, but this is convenient.
			_styling["style"] = idrefs;
			
		}
		//} endregion
		
		//{ region regular expressions for attribute values
		
		private const s_lengthExpression:String = "(-|\\+)?(\\d+)(\\.\\d+)?(px|em|c|%)";
		private const s_fontSizeExpression:String = "^" + s_lengthExpression + "( \\+" + s_lengthExpression + ")?$";
		private const s_paddingExpression:String = "^" + s_lengthExpression + "( \\+" + s_lengthExpression + "( \\+" + s_lengthExpression + "( +" + s_lengthExpression + ")?)?)?$";
		private const s_fontStyleExpression:String = "^normal|italic|oblique|reverseOblique|inherit$";
		private const s_fontWeightExpression:String = "^normal|bold|inherit$";
		private const s_directionExpression:String = "^ltr|rtl|inherit$";
		private const s_displayExpression:String = "^auto|none|inherit$";
		private const s_displayAlignExpression:String = "^before|center|after|inherit$";
		private const s_lineHeightExpression:String = "^normal|" + s_lengthExpression + "|inherit$";
		private const s_opacityExpression:String = "^(\\d+)(\\.\\d+)?|inherit$";    /// not to spec --- but float is ridiculous.
		private const s_overflowExpression:String = "^visible|hidden|scroll|inherit$";
		private const s_showBackgroundExpression:String = "^always|whenActive|inherit$";
		private const s_textDecorationExpression:String = "^none|underline|noUnderline|lineThrough|noLineThrough|overline|noOverline|inherit$";
		private const s_writingModeExpression:String = "^lrtb|rltb|tbrl|tblr|lr|rl|tb|inherit$";
		private const s_wrapOptionExpression:String = "^wrap|noWrap|inherit$";
		private const s_visibilityExpression:String = "^visible|hidden|inherit$";
		private const s_unicodeBidiExpression:String = "^normal|embed|bidiOverride|inherit$";
		private const s_zIndexExpression:String = "^auto|((\\+|-)?\\d+)|inherit$";
		private const s_textAlignExpression:String = "^left|center|right|start|end|inherit$";
		
		//} endregion
		
		//{ region Attribute Value Validation
		public static var cachedRegex:Dictionary = new Dictionary();
		/**
		 * Validate an attribute by testing syntax against the given regular expression
		 *
		 * @param matchExpression Regular expression of syntax
		 * @param attribute Attribute to test
		 */ 
		private function validAttributeValue(matchExpression:String, attribute:TimedTextAttributeBase):Boolean
		{
			var matchRE:RegExp;
			if (cachedRegex[matchExpression])
			{
				matchRE = cachedRegex[matchExpression];
			}
			else
			{
				matchRE = new RegExp(matchExpression);
				cachedRegex[matchExpression] = matchRE;
				
			}
			var value:String = StringUtils.trim(attribute.value);
			
			if (matchRE.test(value))
			{
				_styling[attribute.localName] = value;
			}
			else
			{
				error("Erroneous value " + attribute.value + " for attribute " + attribute.localName + " on " + this);
			}
			return true;
		}
		
		/**
		 * Validate a style attribute value
		 * 
		 * @param attribute timed text attribute to be validated
		 */
		private function validStyleAttributeValue(attribute:TimedTextAttributeBase):void 
		{
			if (attribute.value == "inherit")
			{
				/// to do - remove inherit as a legal value for attributes.
				_styling[attribute.localName] = new Inherit();
			}
			else
			{
				var value:String = StringUtils.trim(attribute.value);
				switch (attribute.localName)
				{
					case "backgroundColor":
						_styling["backgroundColor"] = ColorExpression.parse(value);
						break;
					case "color":
						_styling["color"] = ColorExpression.parse(value);
						break;
					case "direction":
						validAttributeValue(s_directionExpression, attribute);
						break;
					case "display":
						validAttributeValue(s_displayExpression, attribute);
						break;
					case "displayAlign":
						validAttributeValue(s_displayAlignExpression, attribute);
						break;
					case "dynamicFlow":
						// error("dynamicFlow attribute not supported " + this);
						break;
					case "extent":
						if (value == "auto")
						{
							_styling[attribute.localName] = AutoExtent.instance;
						}
						else
						{
							_styling[attribute.localName] = Extent.getExtent(value);
						};
						break;
					case "fontFamily":
						var newFontString:String = value.replace("sansSerif", "_sans");
							newFontString = newFontString.replace("serif", "_serif");
							newFontString = newFontString.replace("monospaceSansSerif", "Monaco, \"Lucida Console\", _typewriter");
							newFontString = newFontString.replace("monospaceSerif", "_typewriter");
							newFontString = newFontString.replace("monospace", "_typewriter");
							newFontString = newFontString.replace("proportionalSansSerif", "_sans");
							newFontString = newFontString.replace("proportionalSerif", "_serif");
						_styling["fontFamily"] = newFontString;
						break;
					case "fontSize":
						if(validAttributeValue(s_fontSizeExpression, attribute))
						{
							_styling["fontSize"] = FontSize.getFontSize(value);
						} else {
							_styling["fontSize"] = FontSize.getFontSize("1c");
						}
						break;
					case "fontStyle":
						if (validAttributeValue(s_fontStyleExpression, attribute))
						{
							switch (value)
							{
								case "italic": 
									_styling["fontStyle"] = FontStyleAttributeValue.ITALIC;
									break;
								case "oblique": 
									_styling["fontStyle"] = FontStyleAttributeValue.OBLIQUE;
									break;
								case "reverseOblique": 
									_styling["fontStyle"] = FontStyleAttributeValue.REVERSE_OBLIQUE;
									break;
								default: 
									_styling["fontStyle"] = FontStyleAttributeValue.REGULAR;
									break;
							}
						} 
						break;
					case "fontWeight":
						if (validAttributeValue(s_fontWeightExpression, attribute))
						{
							_styling["fontWeight"] = 
								(value=="bold")
								? FontWeightAttributeValue.BOLD 
								: FontWeightAttributeValue.REGULAR;
						}
						break;
					case "lineHeight":
						if (validAttributeValue(s_lineHeightExpression, attribute))
						{
							_styling["lineHeight"] = 
								(value=="normal")
								? NormalHeight.instance
								: LineHeight.getLineHeight(value);
						}
						break;
					case "opacity":
						if (validAttributeValue(s_opacityExpression, attribute))
						{
							_styling["opacity"] = parseFloat(value);
						}
						break;
					case "origin":
						switch (value)
						{
							case "auto":
								_styling["origin"] = AutoOrigin.instance;
								break;
							case "inherit":
								_styling["origin"] = new Inherit();
								break;
							default:
								_styling["origin"] = Origin.getOrigin(value);
								break;
						};
						break;
					case "overflow":
						validAttributeValue(s_overflowExpression, attribute);
						break;
					case "padding":
						if (validAttributeValue(s_paddingExpression, attribute))
						{
							_styling["padding"] = PaddingThickness.getPaddingThickness(value);
						}
						break;
					case "showBackground":
						validAttributeValue(s_showBackgroundExpression, attribute);
						break;
					case "textAlign":
						validAttributeValue(s_textAlignExpression, attribute);
						break;
					case "textDecoration":
						if (validAttributeValue(s_textDecorationExpression, attribute))
						{
							var matchRE:RegExp = new RegExp(s_textDecorationExpression,"g");
							var result:Array = matchRE.exec(value);
							
							while (result != null) 
							{ 
								switch(result.toString())
								{
									case TextDecorationAttributeValue.UNDERLINE.value: 
										_styling["textDecoration"] = TextDecorationAttributeValue.UNDERLINE;
										break;
									case TextDecorationAttributeValue.NO_UNDERLINE.value: 
										_styling["textDecoration"] = TextDecorationAttributeValue.NO_UNDERLINE;
										break;
									case TextDecorationAttributeValue.LINE_THROUGH.value: 
										_styling["lineThrough"] = TextDecorationAttributeValue.LINE_THROUGH;
										break;
									case TextDecorationAttributeValue.NO_LINE_THROUGH.value: 
										_styling["lineThrough"] = TextDecorationAttributeValue.NO_LINE_THROUGH;
										break;
									case TextDecorationAttributeValue.NONE.value: 
										_styling["textDecoration"] = TextDecorationAttributeValue.NONE;
										break;
								}
								
								result = matchRE.exec(value); 
							}
						}
						break;
					case "textOutline":
						_styling["textOutline"] = new TextOutline(value);
						break;
					case "unicodeBidi":
						validAttributeValue(s_unicodeBidiExpression, attribute);
						break;
					case "visibility":
						validAttributeValue(s_visibilityExpression, attribute);
						break;
					case "wrapOption":
						validAttributeValue(s_wrapOptionExpression, attribute);
						break;
					case "writingMode":
						validAttributeValue(s_writingModeExpression, attribute);
						break;
					case "zIndex":
						if (validAttributeValue(s_zIndexExpression, attribute))
						{
							if (value == "auto")
							{ 
								_styling["zIndex"] = defaultZ;
							} else
							{ 
								_styling["zIndex"] = parseInt(value) + defaultZ;
							}
							defaultZ += 0.0001; // allow for 10,000 regions with the same z order.
						}
						break;
					default:
						error("Erroneous style: namespace attribute " + attribute.localName + " on " + this);
						break;
				}
			}
		}
		
		/**
		 * Validate an XML attribute value
		 * 
		 * @param attribute
		 */
		protected function validXmlAttributeValue(attribute:TimedTextAttributeBase):void
		{
			switch (attribute.localName)
			{
				case "lang":
					language = attribute.value;
					break;
				case "space":
					_styling[attribute.localName] = attribute.value;
					break;
				case "id":
					if (this.id == null)
					{
						this.id = attribute.value;
					}
					else
					{
						error("multiple xml:id defined on " + this);
					}
					if (this is RegionElement) root.regions[attribute.value] = this as RegionElement;
					if (this is StyleElement) root.styles[attribute.value] = this as StyleElement;
					if (this is AgentElement) root.agents[attribute.value] = this as AgentElement;
					break;
				default:
					error("Erroneous xml: namespace attribute " + attribute.localName + " on " + this);
					break;
			};
		}
		
		/**
		 * Validate an metadata attribute value
		 * 
		 * @param attribute
		 */
		private function validMetadataAttributeValue(attribute:TimedTextAttributeBase):void
		{			
			switch (attribute.localName)
			{
				case "agent":
					trace("// ToDo - ensure its an IDREF to an agent element.");
					break;
				case "role":
					switch (attribute.value)
					{
						case "action":
						case "caption":
						case "description":
						case "dialog":
						case "expletive":
						case "kinesic":
						case "lyrics":
						case "music":
						case "narration":
						case "quality":
						case "sound":
						case "source":
						case "suppressed":
						case "reproduction":
						case "thought":
						case "title":
						case "transcription":
							metadata[attribute.localName] = attribute.value;
							break;
						default:
							if (attribute.value.indexOf("x-")==0)
							{
								metadata[attribute.localName] = attribute.value;
							}
							else
							{
								error("Erroneous metadata namespace attribute " + attribute.localName + " on " + this);
							}
							break;
					}
					break;
				default:
					error("Erroneous metadata namespace attribute " + attribute.localName + " on " + this);
					break;
			}
		}
		//} endregion
		
		
		
		
		
		
		
	
		
		
		/**
		 * Get recorded metadata for the given attribute
		 * @param attribute metadata attribute to retrieve
		 * @returns attribute value
		 */
		public function getMetadata(attribute:String):String
		{
			if (metadata[attribute] !== undefined)
			{
				return metadata[attribute] as String;
			}
			else
			{
				return "";
			}
		}
		//} endregion
	}
}