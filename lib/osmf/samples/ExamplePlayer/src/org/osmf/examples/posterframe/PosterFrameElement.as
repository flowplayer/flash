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
package org.osmf.examples.posterframe
{
	import org.osmf.elements.ImageElement;
	import org.osmf.elements.ImageLoader;
	import org.osmf.media.URLResource;
	import org.osmf.traits.MediaTraitType;
	
	/**
	 * A PosterFrameElement is a playable Image Element.  Making it playable
	 * ensures it shows up as a poster frame.
	 **/
	public class PosterFrameElement extends ImageElement
	{
		public function PosterFrameElement(resource:URLResource=null, loader:ImageLoader=null)
		{
			super(resource, loader);
		}
		
		/**
		 * @private
		 **/
		override protected function processReadyState():void
		{
			super.processReadyState();
			
			addTrait(MediaTraitType.PLAY, new PosterFramePlayTrait());
		}
		
		/**
		 *  @private 
		 */ 
		override protected function processUnloadingState():void
		{
			super.processUnloadingState();
			
			removeTrait(MediaTraitType.PLAY);	
		}
	}
}