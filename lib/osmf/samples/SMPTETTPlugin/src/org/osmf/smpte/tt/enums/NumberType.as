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
package org.osmf.smpte.tt.enums
{
	import org.osmf.smpte.tt.enums.Enum;
	
	public class NumberType extends Enum
	{
		{initEnum(NumberType);} // static ctor

		public static const SHORT:NumberType  = new NumberType();
		public static const INT:NumberType    = new NumberType();
		public static const UINT:NumberType   = new NumberType();
		public static const FLOAT:NumberType  = new NumberType();
		public static const DOUBLE:NumberType = new NumberType();
		public static const LONG:NumberType   = new NumberType();
		public static const ULONG:NumberType  = new NumberType();
		public static const NUMBER:NumberType = new NumberType();
	}
}