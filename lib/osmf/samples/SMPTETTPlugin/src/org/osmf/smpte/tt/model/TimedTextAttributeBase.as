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
	import org.osmf.smpte.tt.styling.AutoExtent;
	import org.osmf.smpte.tt.styling.AutoOrigin;
	import org.osmf.smpte.tt.styling.Colors;
	import org.osmf.smpte.tt.styling.FontSize;
	import org.osmf.smpte.tt.styling.FontStyleAttributeValue;
	import org.osmf.smpte.tt.styling.FontWeightAttributeValue;
	import org.osmf.smpte.tt.styling.PaddingThickness;
	import org.osmf.smpte.tt.styling.TextDecorationAttributeValue;
	import org.osmf.smpte.tt.vocabulary.Namespaces;

	public class TimedTextAttributeBase
	{
		public function TimedTextAttributeBase()
		{
		}
		
		public var parent:TimedTextElementBase;
		
		public var localName:String;
		
		public var namespace:Namespace;

		public var value:String;
		
		public static function getInitialStyle(property:String):Object
		{
			var obj:* = "";
			switch (property)
			{
				case "backgroundColor":
					obj = Colors.Transparent;
					break;
				case "color":
					obj = Colors.White;  // spec says transparent
					break;
				case "direction":
					obj = "auto";  // this is not what the spec says, but we need it to respect writingMode.
					break;
				case "display":
					obj = "auto";
					break;
				case "displayAlign":
					obj = "before";
					break;
				case "dynamicFlow":
					obj = "none";
					break;
				case "extent":
					obj = AutoExtent.instance;
					break;
				case "fontFamily":
					obj = "default";
					break;
				case "fontSize":
					obj = FontSize.getFontSize("1c");
					break;
				case "fontStyle":
					obj = FontStyleAttributeValue.REGULAR;
					break;
				case "fontWeight":
					obj = FontWeightAttributeValue.REGULAR;
					break;
				case "lineHeight":
					obj = null;  // stand in for normal.
					break;
				case "opacity":
					obj = 1.0;
					break;
				case "origin":
					obj = AutoOrigin.instance;
					break;
				case "overflow": 
					obj = "hidden";
					break;
				case "padding":
					obj = PaddingThickness.getPaddingThickness("0px");
					break;
				case "showBackground":
					obj = "always";
					break;
				case "textAlign":
					obj = "start";
					break;
				case "textDecoration":
					obj = TextDecorationAttributeValue.NONE;
					break;
				case "textOutline":
					obj = null; // new TextOutline("none");
					break;
				case "unicodeBidi":
					obj = "undefined";
					break;
				case "visibility":
					obj = "visible";
					break;
				case "wrapOption":
					obj = "wrap";
					break;
				case "writingMode":
					obj = "lrtb";
					break;
				case "zIndex":
					obj = "auto";
					break;
					
				// these are defaults for the xml attributes
				case "space":
					obj = "default";
					break;
				case "lang":
					obj = "en-us";
					break;
					
				case "region":
					obj = "";  // this is not a style per se, but we use the same mechanics.
					break;
					
					// the following cases are for internal styles
				case "#preserve":
					obj = false;
					break;
				default: 
					obj = "";
					break;
			}
			return obj;
		}
		
		/** 
		 * Test whether this attribute is in the Timed Text Parameter namespace
		 */
		public function isParameterAttribute():Boolean
		{
			if(!namespace) return false;
			
			var flag:int = 0;
			flag |= int(namespace.uri == Namespaces.TTML_NS.uri+"#parameter");
			return ((flag & 1) == 1);
		}
		
		/** 
		 * Test whether this attribute is in a Timed Text Parameter namespace
		 */
		public function isProfileAttribute():Boolean
		{
			if(!namespace) return false;
			
			var flag:int = 0;
			flag |= int(namespace.uri.indexOf(Namespaces.TTML_NS.uri+"/profile")==0);
			return ((flag & 1) == 1);
		}
		
		/** 
		 * Test whether this attribute is in a Timed Text Style namespace
		 */
		public function isStyleAttribute():Boolean
		{
			if(!namespace) return false;
			
			var flag:int = 0;
			flag |= int(namespace.uri == Namespaces.TTML_NS.uri+"#style");
			flag |= int(namespace.uri == Namespaces.TTML_NS.uri+"#styling");
			flag |= int(namespace.uri == Namespaces.TTML_NS.uri+"#style-extension");
			return ((flag & 1) == 1);
		}
		
		/** 
		 * Test whether this attribute is in a Timed Text Metadata namespace
		 */
		public function isMetadataAttribute():Boolean
		{
			if(!namespace) return false;
			
			var flag:int = 0;
			flag |= int(namespace.uri == Namespaces.TTML_NS.uri+"#metadata-extension");
			flag |= int(namespace.uri == Namespaces.TTML_NS.uri+"#metadata");
			return ((flag & 1) == 1);
		}
		
		/** 
		 * Test whether this attribute is in a Timed Text Feature namespace
		 */
		public function isFeatureAttribute():Boolean
		{
			if(!namespace) return false;
			
			var flag:int = 0;
			flag |= int(namespace.uri.indexOf(Namespaces.TTML_NS.uri+"feature")==0);
			return ((flag & 1) == 1);
		}
		
		/** 
		 * Test whether this attribute is in a Timed Text Extension namespace
		 * [deprecated] this is expected to be removed from timed text
		 */
		public function isExtensionAttribute():Boolean
		{
			if(!namespace) return false;
			
			var flag:int = 0;
			flag |= int(namespace.uri.indexOf(Namespaces.TTML_NS.uri+"/extension")==0);
			return ((flag & 1) == 1);
		}
		
		/** 
		 * Test whether this attribute is in an intrinsic XML attribute
		 */
		public function isXmlAttribute():Boolean
		{
			
			// trace("isXmlAttribute()? "+namespace+" "+this.localName +"="+ this.value)
			
			if(!namespace) return false;
			
			return namespace == Namespaces.XML_NS; // "http://www.w3.org/XML/1998/namespace";
		}
		
		/** 
		 * Test whether this attribute is in any Timed Text namespace
		 */
		public function isTimedTextAttribute():Boolean
		{
			if(!namespace) return false;
			
			var flag:int = 0;
			flag |= int(isMetadataAttribute() || isStyleAttribute() || isParameterAttribute());
			flag |= int(namespace==Namespaces.TTML_NS);
			
			return ((flag & 1) == 1);
		}
	}
}