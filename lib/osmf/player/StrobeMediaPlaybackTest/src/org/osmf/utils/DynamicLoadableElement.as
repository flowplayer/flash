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
	import __AS3__.vec.Vector;
	
	import org.osmf.media.LoadableElementBase;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.traits.LoaderBase;
	
	public class DynamicLoadableElement extends LoadableElementBase
	{
		public function DynamicLoadableElement(resource:MediaResourceBase, loader:LoaderBase, alternateLoaders:Vector.<LoaderBase>)
		{
			super(resource, loader);
			
			this.alternateLoaders = alternateLoaders;
		}
		
		override public function set resource(value:MediaResourceBase):void
		{
			// Make sure the appropriate loader is set up front.
			loader = getLoaderForResource(value, alternateLoaders);
			
			super.resource = value;
		}
		
		private var alternateLoaders:Vector.<LoaderBase>;
	}
}