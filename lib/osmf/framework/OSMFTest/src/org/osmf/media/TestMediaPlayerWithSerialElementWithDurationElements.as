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
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.media
{
	import org.osmf.elements.DurationElement;
	import org.osmf.elements.SerialElement;
	import org.osmf.traits.MediaTraitType;
	
	public class TestMediaPlayerWithSerialElementWithDurationElements extends TestMediaPlayer
	{
		// Overrides
		//
				
		override protected function createMediaElement(resource:MediaResourceBase):MediaElement
		{
			var serial:SerialElement = new SerialElement();
			serial.addChild(new DurationElement(1.0));
			serial.addChild(new DurationElement(0.5));
			return serial;
		}
		
		override protected function get hasLoadTrait():Boolean
		{
			return false;
		}
		
		override protected function get resourceForMediaElement():MediaResourceBase
		{
			return new URLResource("http://example.com");
		}

		override protected function get invalidResourceForMediaElement():MediaResourceBase
		{
			return null;
		}
		
		override protected function get existentTraitTypesOnInitialization():Array
		{
			return	[ MediaTraitType.TIME
					, MediaTraitType.SEEK
					, MediaTraitType.PLAY
					];
		}

		override protected function get existentTraitTypesAfterLoad():Array
		{
			return	[ MediaTraitType.TIME
					, MediaTraitType.SEEK
					, MediaTraitType.PLAY
					];
		}
		
		[Test]
		override public function testDisplayObjectEventGeneration():void
		{
			super.testDisplayObjectEventGeneration();
		}
	}
}
