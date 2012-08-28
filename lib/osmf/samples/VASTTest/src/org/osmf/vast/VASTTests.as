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
package org.osmf.vast
{
	import flexunit.framework.TestSuite;
	
	import org.osmf.vast.loader.TestVASTLoader;
	import org.osmf.vast.media.TestDefaultVASTMediaFileResolver;
	import org.osmf.vast.media.TestVASTImpressionProxyElement;
	import org.osmf.vast.media.TestVASTMediaGenerator;
	import org.osmf.vast.media.TestVASTTrackingProxyElement;
	import org.osmf.vast.parser.TestVASTParser;

	public class VASTTests extends TestSuite
	{
		public function VASTTests(param:Object=null)
		{
			super(param);
			
			addTestSuite(TestVASTLoader);
			addTestSuite(TestVASTParser);
			addTestSuite(TestDefaultVASTMediaFileResolver);
			addTestSuite(TestVASTImpressionProxyElement);
			addTestSuite(TestVASTMediaGenerator);
			addTestSuite(TestVASTTrackingProxyElement);
		}
	}
}
