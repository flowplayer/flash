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
package org.osmf.smpte.tt.vocabulary
{
	public class Namespaces
	{
		
		static public const TTML_NS_REGEXP:RegExp = /^http\:\/\/www\.w3\.org\/(?:ns\/ttml|2006\/(?:02|04|10)\/ttaf1)/;
		
		static public const DEFAULT_TTML_NS:Namespace = new Namespace("http://www.w3.org/ns/ttml"); // default root namespace
		
		static public var TTML_NS:Namespace = new Namespace("http://www.w3.org/ns/ttml"); //root namespace
		static public var TTML_PARAMETER_NS:Namespace = new Namespace("ttp","http://www.w3.org/ns/ttml#parameter");  //ttp:
		static public var TTML_STYLING_NS:Namespace = new Namespace("tts","http://www.w3.org/ns/ttml#styling"); //tts:
		static public var TTML_METADATA_NS:Namespace = new Namespace("ttm","http://www.w3.org/ns/ttml#metadata"); //ttm:
		static public var XML_NS:Namespace = new Namespace("xml","http://www.w3.org/XML/1998/namespace"); //xml: 
		
		static public function useLegacyNamespace(ns:Namespace=null):void {
			if(!ns){
				ns = new Namespace("http://www.w3.org/2006/10/ttaf1");	
			}
			TTML_NS = ns;
			TTML_PARAMETER_NS = new Namespace("ttp",ns+"#parameter");
			TTML_STYLING_NS = new Namespace("tts",ns+"#styling");
			TTML_METADATA_NS = new Namespace("ttm",ns+"#metadata");
		}
	}
}