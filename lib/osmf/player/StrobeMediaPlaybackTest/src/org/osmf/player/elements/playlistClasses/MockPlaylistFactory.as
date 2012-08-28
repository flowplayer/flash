/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 *  The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 *  (the "License"); you may not use this file except in
 *  compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 **********************************************************/

package org.osmf.player.elements.playlistClasses
{
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	
	public class MockPlaylistFactory extends MediaFactory
	{
		public function MockPlaylistFactory()
		{
			constructors = {};
			super();
		}
		
		public function addMediaContstructor(url:String, constructor:Function):void
		{
			constructors[url] = constructor;
		}
		
		override public function createMediaElement(resource:MediaResourceBase):MediaElement
		{
			var result:MediaElement;
			var urlResource:URLResource = resource as URLResource;
			if (urlResource != null)
			{
				var constructor:Function = constructors[urlResource.url];
				if (constructor != null)
				{
					result = constructor(resource);
				}
			}
			return result;
		}
		
		private var constructors:Object;
	}
}