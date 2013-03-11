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
package org.osmf.smil.model
{
	import __AS3__.vec.Vector;
	
	/**
	 * Enumeration of different SMIL element types.
	 */
	public class SMILElementType
	{
		/**
		 * The sequence type.
		 */
		public static const SEQUENCE:String = "seq";
		
		/**
		 * The parallel type.
		 */
		public static const PARALLEL:String = "par";
		
		/**
		 * The switch type.
		 */
		public static const SWITCH:String = "switch";
		
		/**
		 * The video type.
		 */
		public static const VIDEO:String = "video";
		
		/**
		 * The image type.
		 */
		public static const IMAGE:String = "img";
		
		/**
		 * The audio type.
		 */
		public static const AUDIO:String = "audio";
		
		/**
		 * The meta tag.
		 */
		public static const META:String = "meta";
		
		/**
		 * @private
		 * 
		 * Collection of all SMIL types.
		 */
		public static const ALL_TYPES:Vector.<String> = Vector.<String>( [ 	SEQUENCE, 
																			PARALLEL, 
																			SWITCH, 
																			VIDEO, 
																			IMAGE,
																			AUDIO,
																			META ] );
	}
}
