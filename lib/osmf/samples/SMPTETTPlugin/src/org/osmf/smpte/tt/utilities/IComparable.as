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
package org.osmf.smpte.tt.utilities
{
	public interface IComparable
	{
		/**
		 * Compares this object with the specified object for order. Returns a negative integer, zero, or a positive
		 * integer as this object is less than, equal to, or greater than the specified object.
		 *
		 * @param other the object to be compared
		 * @return a negative integer, zero, or a positive integer as this object is less than, equal to, or greater than the specified object.
		 */
		function compareTo(object:Object):int;
	}
}