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
package org.osmf.utils
{
	import __AS3__.vec.Vector;
	
	import org.osmf.elements.ProxyElement;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.traits.AudioTrait;
	import org.osmf.traits.BufferTrait;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;
	
	public class DynamicProxyElement extends ProxyElement
	{
		public function DynamicProxyElement(wrappedElement:MediaElement=null, traitTypes:Array=null, loader:LoaderBase=null, resource:MediaResourceBase=null)
		{
			super(wrappedElement);
			
			if (traitTypes != null || loader != null || resource != null)
			{
				initialize(traitTypes, loader, resource);
			}
		}
				
		public function doAddTrait(type:String, instance:MediaTraitBase):void
		{
			this.addTrait(type,instance);
		}

		public function doRemoveTrait(type:String):MediaTraitBase
		{
			return this.removeTrait(type);
		}
		
		public function setBlockedTraits(traits:Vector.<String>):void
		{
			super.blockedTraits = traits;
		}
		
		private function initialize(traitTypes:Array, loader:LoaderBase, resource:MediaResourceBase):void
		{
			this.resource = resource;
		
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
						case MediaTraitType.BUFFER:
							trait = new BufferTrait();
							break;
						case MediaTraitType.LOAD:
							trait = new LoadTrait(loader, resource);
							break;
						case MediaTraitType.PLAY:
							trait = new PlayTrait();
							break;
						case MediaTraitType.SEEK:
							trait = new SeekTrait(null);
							break;
						case MediaTraitType.TIME:
							trait = new TimeTrait();
							break;
						case MediaTraitType.DISPLAY_OBJECT:
							trait = new DisplayObjectTrait(null);
							break;
						default:
							throw new ArgumentError();
					}
					
					addTrait(traitType, trait);
				}
			}
		}
	}
}