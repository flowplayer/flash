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
	import org.osmf.smpte.tt.errors.SMPTETTException;
	import org.osmf.smpte.tt.model.MetadataElement;
	import org.osmf.smpte.tt.model.TimedTextAttributeBase;
	import org.osmf.smpte.tt.model.TimedTextElementBase;
	import org.osmf.smpte.tt.model.metadata.MetadataElement;
	import org.osmf.smpte.tt.timing.TimeTree;
	import org.osmf.smpte.tt.utilities.DictionaryUtils;
	
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
			
			while (child < children.length
				&& ((children[child] is org.osmf.smpte.tt.model.MetadataElement) 
					|| (children[child] is org.osmf.smpte.tt.model.metadata.MetadataElement)
					|| (children[child] is FeatureElement)))
			{
				child++;
			}
			
			if (children.length != child)
			{
				error(children[child] + " is not allowed in " + this + " at position " + child);
			}
			
			// now check each of the children is individually valid
			for each (var element:TimedTextElementBase in children)
			{
				element.valid();
			}
		}
	}
}