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
 **********************************************************/

package org.osmf.player.configuration
{
	import org.flexunit.asserts.*;
	import org.osmf.player.chrome.assets.AssetLoader;
	import org.osmf.player.chrome.assets.AssetsManager;
	
	public class TestSkinParser
	{		
		[Test]
		public function testParser():void
		{
			var parser:SkinParser = new SkinParser();
			
			assertNotNull(parser);
			
			var assetsManager:AssetsManager = new AssetsManager();
			parser.parse
				(	<skin>
						<element id="a" src="src_a"/>
						<elements basePath="g1bp/">
							<element id="b" src="src_b"/>
							<element id="c" src="src_c"/>
						</elements>
					</skin>
				,	assetsManager
				);
			
			var assetLoader:AssetLoader = assetsManager.getLoader("b");
			assertNotNull(assetLoader);
			assertEquals("g1bp/src_b", assetsManager.getResource(assetLoader).url);
			
			assetLoader = assetsManager.getLoader("c");
			assertNotNull(assetLoader);
			assertEquals("g1bp/src_c", assetsManager.getResource(assetLoader).url);
			
			assetLoader = assetsManager.getLoader("a");
			assertNotNull(assetLoader);
			assertEquals("src_a", assetsManager.getResource(assetLoader).url);
		}
	}
}