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
*  Contributor(s): Akamai Technologies
* 
*****************************************************/
package org.osmf.mast.model
{
	import __AS3__.vec.Vector;
	
	/**
	 * This class represents the top level of the MAST
	 * document object model.
	 */
	public class MASTDocument
	{
		/**
		 * Constructor.
		 * 
		 * @param version The MAST document version number if
		 * available in the document.
		 */
		public function MASTDocument(version:Number)
		{
			_version = version;
		}
		
		/**
		 * The collection of triggers from the MAST document.
		 */
		public function get triggers():Vector.<MASTTrigger>
		{
			return _triggers;
		}
		
		/**
		 * Adds a MASTTrigger object to the collection of MAST triggers.
		 */
		public function addTrigger(value:MASTTrigger):void
		{
			if (_triggers == null)
			{
				_triggers = new Vector.<MASTTrigger>();
			}
			
			_triggers.push(value);
		}
		
		private var _triggers:Vector.<MASTTrigger>;
		private var _version:Number;
	}
}
