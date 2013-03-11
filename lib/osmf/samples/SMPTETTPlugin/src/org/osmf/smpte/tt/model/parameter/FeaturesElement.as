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
	import org.osmf.smpte.tt.model.MetadataElement;
	import org.osmf.smpte.tt.model.TimedTextAttributeBase;
	import org.osmf.smpte.tt.model.TimedTextElementBase;
	import org.osmf.smpte.tt.model.metadata.MetadataElement;
	
	public class FeaturesElement extends ParameterElement
	{
		public function FeaturesElement()
		{
		}
		
		protected override function validAttributes():void
		{
			
			for each (var attribute:TimedTextAttributeBase in attributes)
			{
				if (attribute.isXmlAttribute())
				{	
					switch (attribute.localName)
					{
						case "base":
							break;
						default:
							validXmlAttributeValue(attribute);
							break;
					}
				} else 
				{
					error("Erroneous feature attribute " + attribute.localName + " on " + this);

				}
			}			
		}
		
		protected override function validElements():void
		{
			var child:uint = 0;
			// check each of the children is individually valid
			for each (var element:TimedTextElementBase in children)
			{
				if (element is org.osmf.smpte.tt.model.MetadataElement
					|| element is org.osmf.smpte.tt.model.metadata.MetadataElement
					|| element is FeatureElement)
				{
					child++;
					element.valid();
				}
				else
				{
					error(element + " is not allowed in " + this + " at position " + (children.length-child));
					continue;
				}
			}
		}
	}
}