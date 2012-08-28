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
	import flash.display.DisplayObject;
	
	import org.osmf.traits.DisplayObjectTrait;
	
	public class DynamicDisplayObjectTrait extends DisplayObjectTrait
	{
		public function DynamicDisplayObjectTrait(displayObject:DisplayObject, mediaWidth:Number=0, mediaHeight:Number=0)
		{
			super(displayObject, mediaWidth, mediaHeight);
		}
		
		public function set displayObject(value:DisplayObject):void
		{
			setDisplayObject(value);
		}
	
		public function setSize(width:Number, height:Number):void
		{
			setMediaSize(width, height);
		}
	}
}