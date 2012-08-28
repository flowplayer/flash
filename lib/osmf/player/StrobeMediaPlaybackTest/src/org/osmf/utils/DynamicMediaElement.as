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
 * 
 **********************************************************/

package org.osmf.utils
{
	import flash.display.Sprite;
	
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.traits.AudioTrait;
	import org.osmf.traits.BufferTrait;
	import org.osmf.traits.DRMTrait;
	import org.osmf.traits.DVRTrait;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.DynamicStreamTrait;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;
	
	public class DynamicMediaElement extends MediaElement
	{
		public function DynamicMediaElement(traitTypes:Array=null, loader:LoaderBase=null, resource:MediaResourceBase=null, useDynamicTraits:Boolean=false)
		{
			this.resource = resource;
			
			var doCreateSeekTrait:Boolean = false;
			
			if (traitTypes != null)
			{
				for each (var traitType:String in traitTypes)
				{
					var trait:MediaTraitBase = null;
					
					switch (traitType)
					{
						case MediaTraitType.AUDIO:
							trait = new AudioTrait();
							break;
						case MediaTraitType.LOAD:
							trait = useDynamicTraits ? new DynamicLoadTrait(loader, resource) : new LoadTrait(loader, resource);
							break;
						case MediaTraitType.PLAY:
							trait = useDynamicTraits ? new DynamicPlayTrait() : new PlayTrait();
							break;
						case MediaTraitType.SEEK:
							doCreateSeekTrait = true;
							continue;
						case MediaTraitType.TIME:
							trait = useDynamicTraits ? new DynamicTimeTrait() : new TimeTrait();
							timeTrait = trait as TimeTrait;
							break;
						case MediaTraitType.DISPLAY_OBJECT:
							trait = useDynamicTraits ? new DynamicDisplayObjectTrait(new Sprite()) : new DisplayObjectTrait(new Sprite());
							break;
						default:
							break;
					}
					
					if (trait != null)
					{
						doAddTrait(traitType, trait);
					}
				}
			}
			
			if (doCreateSeekTrait)
			{
				var seekTrait:SeekTrait = useDynamicTraits ? new DynamicSeekTrait(DynamicTimeTrait(timeTrait)) : new SeekTrait(timeTrait);
				doAddTrait(MediaTraitType.SEEK, seekTrait);
			}
		}
		
		public function doAddTrait(traitType:String, instance:MediaTraitBase):void
		{
			this.addTrait(traitType, instance);
		}

		public function doRemoveTrait(traitType:String):MediaTraitBase
		{
			return this.removeTrait(traitType);
		}
		
		private var timeTrait:TimeTrait;
	}
}