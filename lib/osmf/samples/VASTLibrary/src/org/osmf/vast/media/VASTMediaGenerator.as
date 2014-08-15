/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*
*  Contributor(s): Eyewonder, LLC
*  
*****************************************************/
package org.osmf.vast.media
{
	import __AS3__.vec.Vector;
	
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.vast.model.VAST2Translator;
	import org.osmf.vast.model.VASTDataObject;
	import org.osmf.vast.model.VASTDocument;
	
	/**
	 * Utility class for creating MediaElements from a VASTDocument.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class VASTMediaGenerator
	{
		
		public static const PLACEMENT_LINEAR:String = VAST2Translator.PLACEMENT_LINEAR;
		public static const PLACEMENT_NONLINEAR:String = VAST2Translator.PLACEMENT_NONLINEAR;
		
		/**
		 * Constructor.
		 * 
		 * @param mediaFileResolver The resolver to use when a VASTDocument
		 * contains multiple representations of the same content (MediaFile).
		 * If null, this object will use a DefaultVASTMediaFileResolver.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function VASTMediaGenerator(mediaFileResolver:IVASTMediaFileResolver=null, mediaFactory:MediaFactory=null)
		{
			super();
			
			this.mediaFileResolver =
				 mediaFileResolver != null
				 ? mediaFileResolver
				 : new DefaultVASTMediaFileResolver();
			this.mediaFactory = mediaFactory;	 
				 
				 vast1MediaGenerator = new VAST1MediaGenerator(mediaFileResolver, mediaFactory);
				 vast2MediaGenerator = new VAST2MediaGenerator(DefaultVAST2MediaFileResolver(mediaFileResolver), mediaFactory);
		}
		
		/**
		 * Creates all relevant MediaElements from the specified VAST document.
		 * 
		 * @param vastDocument The VASTDocument that holds the raw VAST information.
		 * 
		 * @returns A Vector of MediaElements, where each MediaElement
		 * represents a different VASTAd within the VASTDocument. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function createMediaElements(vastDocument:VASTDataObject, placement:String = ""):Vector.<MediaElement>
		{
				switch(vastDocument.vastVersion)
				{
					case VASTDataObject.VERSION_1_0:
						return vast1MediaGenerator.createMediaElements(vastDocument as VASTDocument);					
					break;
					case VASTDataObject.VERSION_2_0:
						return vast2MediaGenerator.createMediaElements(vastDocument as VAST2Translator, placement);
					break;
					default:
						return vast1MediaGenerator.createMediaElements(vastDocument as VASTDocument);	
					break;
				}			
		}
		
		private var mediaFactory:MediaFactory;
		private var mediaFileResolver:IVASTMediaFileResolver;
		private var vast1MediaGenerator:VAST1MediaGenerator;
		private var vast2MediaGenerator:VAST2MediaGenerator;
	}
}