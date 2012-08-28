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
	import org.osmf.media.MediaFactory;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	
	public class MockPlaylistLoader extends PlaylistLoader
	{
		public function MockPlaylistLoader(factory:MediaFactory=null, resourceConstructorFunction:Function=null)
		{
			super(factory, resourceConstructorFunction);
		}
		
		public function set playlistContent(value:String):void
		{
			_playlistContent = value;
		}
		
		override protected function executeLoad(loadTrait:LoadTrait):void 
		{
			updateLoadTrait(loadTrait, LoadState.LOADING);
			processPlaylistContent(_playlistContent, loadTrait);
		}
		
		// Internals
		//
		
		private var _playlistContent:String;
	}
}