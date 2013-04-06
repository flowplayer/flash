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
package org.osmf.smpte.tt.model.parameter
{
	import org.osmf.smpte.tt.model.AnonymousSpanElement;
	import org.osmf.smpte.tt.model.TimedTextAttributeBase;
	
	public class FeatureElement extends ParameterElement
	{
		public function FeatureElement()
		{
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
		
		protected override function validAttributes():void
		{
			for each (var attribute:TimedTextAttributeBase in attributes)
			{
				if (attribute.isXmlAttribute())
				{	
					validXmlAttributeValue(attribute);
				} else 
				{
					switch (attribute.localName)
					{
						case "value":
							validParameterAttribute(attribute, true, text);
							break;
						default:
							error("Erroneous feature attribute " + attribute.localName + " on " + this);
							break;
					}
				}
			}			
		}
		
		protected override function validElements():void
		{
			var child:uint = 0;
			var sb:String = "";
			var childElement:AnonymousSpanElement;
			while (child < children.length)
			{
				childElement = children[child] as AnonymousSpanElement;
				if(childElement)
				{
					sb += childElement.text;
					child++;
				}
			}
			text = sb;
			
			if (children.length != child)
			{
				error(children[child] + " is not allowed in " + this + " at position " + child);
			}
		}
	}
}