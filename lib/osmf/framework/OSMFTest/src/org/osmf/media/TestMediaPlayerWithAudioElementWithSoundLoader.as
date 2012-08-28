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
package org.osmf.media
{
	import flash.media.SoundMixer;
	
	import org.osmf.elements.AudioElement;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.TestConstants;
	
	public class TestMediaPlayerWithAudioElementWithSoundLoader extends TestMediaPlayer
	{
		// Overrides
		//
				
		override public function tearDown():void
		{
			super.tearDown();
			
			// Kill all sounds.
			SoundMixer.stopAll();
		}

		override protected function createMediaElement(resource:MediaResourceBase):MediaElement
		{
			return new AudioElement(resource as URLResource);
		}
		
		override protected function get hasLoadTrait():Boolean
		{
			return true;
		}
		
		override protected function get expectedBytesTotalAfterLoad():Number
		{
			return 30439;
		}
		
		override protected function get resourceForMediaElement():MediaResourceBase
		{
			return new URLResource(TestConstants.LOCAL_SOUND_FILE);
		}

		override protected function get invalidResourceForMediaElement():MediaResourceBase
		{
			return INVALID_RESOURCE;
		}
		
		override protected function get existentTraitTypesOnInitialization():Array
		{
			return [MediaTraitType.LOAD];
		}

		override protected function get existentTraitTypesAfterLoad():Array
		{
			return [ MediaTraitType.AUDIO
				   , MediaTraitType.LOAD
				   , MediaTraitType.PLAY
				   , MediaTraitType.SEEK
				   , MediaTraitType.TIME
				   ];
		}
		
		[Test]
		override public function testDisplayObjectEventGeneration():void
		{
			super.testDisplayObjectEventGeneration();
		}
				
		// Internals
		//

		private static const INVALID_RESOURCE:URLResource = new URLResource(TestConstants.LOCAL_INVALID_SOUND_FILE);
	}
}
