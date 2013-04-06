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
	public class AutoExtent extends Extent
	{
		private static var _instance:AutoExtent;
		
		public static function get instance():AutoExtent
		{
			if( _instance == null ) _instance = new AutoExtent( new SingletonLock() );
			return _instance;
		}
		
		public function AutoExtent( lock:SingletonLock )
		{
			// Verify that the lock is the correct class reference.
			if ( lock is SingletonLock )
			{
				super(-1,-1);
			} else 
			{	
				throw new Error( "Invalid Singleton access.  Use AutoExtent.instance." );
			}
		}
	}
}

/**
 * This is a private class declared outside of the package
 * that is only accessible to classes inside of the AutoExtent.as
 * file.  Because of that, no outside code is able to get a
 * reference to this class to pass to the constructor, which
 * enables us to prevent outside instantiation.
 */
internal class SingletonLock{};