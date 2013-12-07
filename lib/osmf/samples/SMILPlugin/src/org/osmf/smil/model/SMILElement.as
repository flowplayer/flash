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
	 * Represents an element in a SMIL document.
	 */
	public class SMILElement
	{
		/**
		 * Constructor.
		 * 
		 * @param type Should be one of the constants defined in <code>SMILElementType</code>.
		 * @see SMILElementType
		 */
		public function SMILElement(type:String)
		{
			_type = type;
		}
		
		/**
		 * The type of element. Value will be one of the 
		 * constants defined in <code>SMILElementType</code>.
		 */
		public function get type():String
		{
			return _type;
		}
		
		/**
		 * Adds a child element.
		 */
		public function addChild(child:SMILElement):void
		{
			if (children == null)
			{
				children = new Vector.<SMILElement>();
			}
			
			children.push(child);
		}
		
		/**
		 * Returns the number of child elements.
		 */
		public function get numChildren():int
		{
			var num:int = 0;
			
			if (children != null)
			{
				num = children.length;
			}
			
			return num;
		}
		
		/**
		 * Returns the child element at the specified index.
		 * 
		 * @throws RangeError is the index specified is out of range.
		 */
		public function getChildAt(index:int):SMILElement
		{
			if (children != null && index < children.length)
			{
				return children[index];
			}
			
			throw new RangeError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
		}
		
		private var _type:String;
		private var children:Vector.<SMILElement>;
	}
}
