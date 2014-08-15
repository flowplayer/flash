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
	import flash.utils.Dictionary;
	
	import org.osmf.smpte.tt.model.TimedTextAttributeBase;
	import org.osmf.smpte.tt.model.TimedTextElementBase;
	import org.osmf.smpte.tt.utilities.DictionaryUtils;
	
	public class ParameterElement extends TimedTextElementBase
	{
		public static var features:Dictionary = new Dictionary();
		public static var extensions:Dictionary = new Dictionary();
		public static var transformProfile:Dictionary = new Dictionary();
		public static var presentationProfile:Dictionary = new Dictionary();
		public static var profile:Vector.<FeatureValue> = new Vector.<FeatureValue>();
		
		public function ParameterElement()
		{
		}
		
		public static function initializeParameters():void
		{
			DictionaryUtils.clear(ParameterElement.features);
			DictionaryUtils.clear(ParameterElement.extensions);
		}
		
		public static function setProfile(profileXML:XML):void
		{
			var baseUri:String = "http://www.w3.org/ns/ttml/feature";
			var profileNS:Namespace = profileXML.namespace();
			ParameterElement.profile.length = 0;
			var featuresXML:XMLList = profileXML..profileNS::feature;
			for each(var f:XML in featuresXML){
				var fv:FeatureValue = new FeatureValue();
				fv.required = (f.@value == "required");
				fv.label = baseUri + f.text();
				ParameterElement.profile.push(fv);
			}
		}

		public static function setStaticProfiles(transform:XML, presentation:XML):void
		{
			
			var baseUri:String = "http://www.w3.org/ns/ttml/feature";
			
			var transformNS:Namespace = transform.namespace();
			
			DictionaryUtils.clear(ParameterElement.transformProfile);
			var featuresXML:XMLList = transform..transformNS::feature;
			var f:XML, fv:FeatureValue;
			for each(f in featuresXML)
			{
				fv = new FeatureValue();
				fv.required = (f.@value == "required");
				fv.label = baseUri + f.text();
				ParameterElement.transformProfile[fv.label] = fv.required;
			}
			
			DictionaryUtils.clear(ParameterElement.presentationProfile);
			var presentationNS:Namespace = presentation.namespace();
			featuresXML = presentation..presentationNS::feature;
			for each(f in featuresXML)
			{
				fv = new FeatureValue();
				fv.required = (f.@value == "required");
				fv.label = baseUri + f.text();
				ParameterElement.presentationProfile[fv.label] = fv.required;
			}
		}
		
		public static function get nonFeatures():Vector.<String>
		{
			var set:Vector.<String> = new Vector.<String>();
			for each(var f:FeatureValue in ParameterElement.profile)
			{
				if (!f.required) set.push(f.label);
			}
			return set;
		}
		
		protected override function validParameterAttribute(attribute:TimedTextAttributeBase, feature:Boolean=false, value:String=""):void
		{
			var baseUri:String = (parent as ParameterElement).baseAttributeValue();
			var key:String = baseUri + value;
			var valInt:int;
			switch (attribute.localName)
			{
				case "value":
					if (feature)
					{
						if (ParameterElement.features[key] !== undefined)
						{
							valInt = ParameterElement.features[key] as int;
							valInt |= int(attribute.value == "required");
							ParameterElement.features[key] = ((valInt & 1)==1);
						}
						else
						{
							ParameterElement.features[key] = attribute.value == "required";
						}
					}
					else
					{
						if (ParameterElement.extensions[key] !== undefined)
						{
							valInt = ParameterElement.extensions[key] as int;
							valInt |= int(attribute.value == "required");
							ParameterElement.extensions[key] =  ((valInt & 1)==1);
						}
						else
						{
							ParameterElement.extensions[key] = attribute.value == "required";
						}
					}
					break;
				default:
					error("Erroneous parameter attribute " + attribute.localName + " on " + this);
					break;
			};
		}

		protected function baseAttributeValue():String
		{
			for each (var attribute:TimedTextAttributeBase in attributes)
			{
				if(attribute.localName == "base") return attribute.value;
			}
			return "http://www.w3.org/ns/ttml/feature";
		}
		
	}
}