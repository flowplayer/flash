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
	import org.flexunit.Assert;
	import org.osmf.traits.BufferTrait;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.TimeTrait;
	import org.osmf.traits.DisplayObjectTrait;

	public class MediaTraitResolverBaseTestCase
	{
		public function constructResolver(type:String, traitOfType:MediaTraitBase):MediaTraitResolver
		{
			return null;	
		}
		
		[Test(expects="Error")]
		public function testAddTraitNull():void
		{
			var type:String = MediaTraitType.TIME;
			var resolver:MediaTraitResolver = constructResolver(type, new TimeTrait());
			
			resolver.addTrait(null);
		}
		
		[Test(expects="Error")]
		public function testAddTrait():void
		{
			var type:String = MediaTraitType.TIME;
			var resolver:MediaTraitResolver = constructResolver(type, new TimeTrait());	
		
			resolver.addTrait(new DisplayObjectTrait(null));
		}
	}
}