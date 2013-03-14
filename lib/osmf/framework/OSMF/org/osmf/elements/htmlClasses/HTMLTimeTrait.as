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
*****************************************************/
package org.osmf.elements.htmlClasses
{
	import org.osmf.elements.HTMLElement;
	import org.osmf.traits.TimeTrait;

	[ExcludeClass]
	
	/**
	 * @private
	 */
	public class HTMLTimeTrait extends TimeTrait
	{
		public function HTMLTimeTrait(owner:HTMLElement)
		{
			this.owner = owner;
			
			super(NaN);
		}

		public function set duration(value:Number):void
		{
			setDuration(value);
		}
		
		public function set currentTime(value:Number):void
		{
			setCurrentTime(value);
		}
		
		// Internals
		//
		
		private var owner:HTMLElement;
		private var internalMutation:int;
	}
}