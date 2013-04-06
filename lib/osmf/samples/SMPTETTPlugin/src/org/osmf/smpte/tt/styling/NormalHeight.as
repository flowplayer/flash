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
package org.osmf.smpte.tt.styling
{
	public class NormalHeight extends LineHeight
	{
		private static var _instance:NormalHeight;
		
		public static function get instance():NormalHeight
		{
			if( _instance == null ) _instance = new NormalHeight( new SingletonLock() );
			return _instance;
		}
		
		public function NormalHeight( lock:SingletonLock )
		{
			// Verify that the lock is the correct class reference.
			if (lock is SingletonLock)
			{
				super("1.2c");
			} else 
			{	
				throw new Error( "Invalid Singleton access.  Use NormalHeight.instance." );
			}
		}
	}
}

internal class SingletonLock{}