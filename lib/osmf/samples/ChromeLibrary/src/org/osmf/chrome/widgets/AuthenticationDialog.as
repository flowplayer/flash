/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
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
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/

package org.osmf.chrome.widgets
{
	import flash.events.MouseEvent;
	
	import org.osmf.chrome.assets.AssetsManager;
	import org.osmf.events.DRMEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.DRMState;
	import org.osmf.traits.DRMTrait;
	import org.osmf.traits.MediaTraitType;
	
	public class AuthenticationDialog extends Widget
	{		
		// Overrides
		//
		
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			super.configure(xml, assetManager);
			
			submit = getChildWidget("submitButton") as ButtonWidget;
			submit.addEventListener(MouseEvent.CLICK, onSubmitClick);
			
			cancel = getChildWidget("cancelButton") as ButtonWidget;
			cancel.addEventListener(MouseEvent.CLICK, onCancelClick);
			
			userName = getChildWidget("username") as LabelWidget;
			password = getChildWidget("password") as LabelWidget;
			
			_open = false;
			updateVisibility();
		}
		
		// Internals
		//
		
		private static const OFFSET_X:Number = 10;
		
		private var userName:LabelWidget;
		private var password:LabelWidget;
		private var submit:ButtonWidget;
		private var cancel:ButtonWidget;
		
		private var _open:Boolean;
		
		private function onSubmitClick(event:MouseEvent):void
		{
			_open = false;
			updateVisibility();
			
			authenticating = true;
			drm.authenticate(userName.text, password.text);
		}
		
		private function onCancelClick(event:MouseEvent):void
		{
			_open = false;
			updateVisibility();
		}
		
		private function updateVisibility():void
		{
			visible = _open;
		}
		
		// Overrides
		//
		
		override protected function get requiredTraits():Vector.<String>
		{
			return _requiredTraits;
		}
		
		override protected function processRequiredTraitsAvailable(element:MediaElement):void
		{
			drm = element.getTrait(MediaTraitType.DRM) as DRMTrait;
			drm.addEventListener(DRMEvent.DRM_STATE_CHANGE, onDRMStateChange);
			
			onDRMStateChange();
		}
		
		override protected function processRequiredTraitsUnavailable(element:MediaElement):void
		{
			if (drm)
			{
				drm.removeEventListener(DRMEvent.DRM_STATE_CHANGE, onDRMStateChange);
				drm = null;
				authenticating = false;
			}
			
			updateVisibility();
		}
		
		// Internals
		//
		
		private var drm:DRMTrait;
		private var authenticating:Boolean;
		
		/* static */
		private static const _requiredTraits:Vector.<String> = new Vector.<String>;
		_requiredTraits[0] = MediaTraitType.DRM;
		
		private function onDRMStateChange(event:DRMEvent=null):void
		{
			if (drm)
			{
				_open = drm.drmState == DRMState.AUTHENTICATION_NEEDED;
				if (_open == false && authenticating == true)
				{
					if (drm.drmState == DRMState.AUTHENTICATION_COMPLETE)
					{
						authenticating = false;
					}
					else if (drm.drmState == DRMState.AUTHENTICATION_ERROR)
					{
						authenticating = false;
						_open = true;	
					}
				}
			}
			else
			{
				_open = false;
			}
			updateVisibility();
		}
	}
}