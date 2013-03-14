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
package org.osmf.syndication.model.extensions.itunes
{
	import __AS3__.vec.Vector;
	
	/**
	 * ITunesExplicitType enumerates all available values
	 * for the explicit tag. This tag should be used to 
	 * indicate whether or not your podcast contains explicit 
	 * material. The three values for this tag are "yes", "no", and "clean".
	 **/
	public final class ITunesExplicitType
	{
		/**
		 * Indicates the podcast contains explicit material.
		 **/
		public static const EXPLICIT_YES:String	= "yes";
		
		/**
		 * Indicates the podcast does not contain explicit material.
		 **/
		public static const EXPLICIT_NO:String	= "no";
		
		/**
		 * Indicates the podcast does not contain explicit material.
		 * This is the same as "no" but may cause the iTunes UI to 
		 * behave differently.
		 * 
		 * @see http://www.apple.com/itunes/podcasts/specs.html#explicit
		 **/
		public static const EXPLICIT_CLEAN:String = "clean";
		
		/**
		 * @private
		 * 
		 * Collection of all explicit types.
		 **/
		public static const ALL_TYPES:Vector.<String> = Vector.<String>([EXPLICIT_YES, EXPLICIT_NO, EXPLICIT_CLEAN]);
	}
}
