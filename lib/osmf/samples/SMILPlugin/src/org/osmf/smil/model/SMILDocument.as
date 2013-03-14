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
	
	import org.osmf.utils.OSMFStrings;

	/**
	 * Represents the root level elements of a SMIL document.
	 */	
	public class SMILDocument
	{
		/**
		 * Adds a root level element to the collection of
		 * elements.
		 */
		public function addElement(value:SMILElement):void
		{
			if (elements == null)
			{
				elements = new Vector.<SMILElement>();		
			}
			
			elements.push(value);
		}
		
		/**
		 * The number of root level elements.
		 */
		public function get numElements():int
		{
			var num:int = 0;
			
			if (elements != null)
			{
				num = elements.length;
			}
			
			return num;
		}
		
		/**
		 * Returns the SMILElement at the specified index
		 * in the collection.
		 * 
		 * @throws RangeError if the index is out of range.
		 */
		public function getElementAt(index:int):SMILElement
		{
			if (elements != null && index < elements.length)
			{
				return elements[index];
			}
			
			throw new RangeError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
		}
		
		private var elements:Vector.<SMILElement>;
	}
}
