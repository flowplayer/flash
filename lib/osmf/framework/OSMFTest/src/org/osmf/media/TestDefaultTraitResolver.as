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
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.TimeTrait;
	
	import org.flexunit.Assert;

	public class TestDefaultTraitResolver extends MediaTraitResolverBaseTestCase
	{
		override public function constructResolver(type:String, traitOfType:MediaTraitBase):MediaTraitResolver
		{
			return new DefaultTraitResolver(type, traitOfType);
		}
		
		[Test(expects="Error")]
		public function testDefaultTraitResolver():void
		{		
			new DefaultTraitResolver(MediaTraitType.AUDIO, new TimeTrait());
		}
			
		[Test(expects="Error")]
		public function testDefaultTraitResolverNull():void
		{
			new DefaultTraitResolver(MediaTraitType.TIME, null);
		}
		
		[Test]
		public function testResolvedTrait():void
		{
			var t1:TimeTrait = new TimeTrait();
			var resolver:DefaultTraitResolver = new DefaultTraitResolver(MediaTraitType.TIME, t1);
			
			Assert.assertEquals(MediaTraitType.TIME, resolver.type);
			Assert.assertEquals(t1, resolver.resolvedTrait);

			var t2:TimeTrait = new TimeTrait();
			resolver.addTrait(t2);
			Assert.assertEquals(t2, resolver.resolvedTrait);
			
			resolver.removeTrait(t2);
			Assert.assertEquals(t1, resolver.resolvedTrait);
		}
	}
}