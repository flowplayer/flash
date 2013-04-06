/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.test.smil.parser
{
	import flash.errors.IllegalOperationError;
	
	import flexunit.framework.TestCase;
	
	import org.osmf.smil.model.SMILDocument;
	import org.osmf.smil.model.SMILElement;
	import org.osmf.smil.model.SMILElementType;
	import org.osmf.smil.model.SMILMediaElement;
	import org.osmf.smil.parser.SMILParser;
	import org.osmf.test.smil.SMILTestConstants;
	import org.osmf.utils.URL;

	public class TestSMILParser extends TestCase
	{
		public function TestSMILParser(methodName:String=null)
		{
			super(methodName);
		}

		public function testParser():void
		{
			// A valid file
			internalTestParser(SMILTestConstants.SMIL_DOCUMENT_CONTENTS_FULL);
			
			// A file with no <body> tag
			try
			{
				internalTestParser(SMILTestConstants.SMIL_DOCUMENT_CONTENTS_NO_BODY);
				fail();
			}
			catch (e:IllegalOperationError)
			{
			}
			
			// null data
			try
			{
				var parser:SMILParser = new SMILParser();
				var document:SMILDocument = parser.parse(null);
				fail();
			}
			catch (e:ArgumentError)
			{
			}
			
			// empty data
			try
			{
				parser = new SMILParser();
				document = parser.parse("");
				fail();
			}
			catch (e:ArgumentError)
			{
			}
			
			// An rtmp dynamic streaming file
			internalTestParser(SMILTestConstants.SMIL_DOCUMENT_CONTENTS_MBR);
			
		}
		
		private function internalTestParser(rawData:XML):void
		{
			var parser:SMILParser = new SMILParser();
			var document:SMILDocument = parser.parse(rawData.toXMLString());
			
			assertTrue(document.numElements > 0);
			for (var i:int = 0; i < document.numElements; i++)
			{
				var element:SMILElement = document.getElementAt(i);
				testChildren(element);
			}
			
			function testChildren(element:SMILElement):void
			{
				assertTrue(element.type != null);
				if (element.type == SMILElementType.VIDEO)
				{
					validateVideoElement(element);
				}
				
				for (var j:int = 0; j < element.numChildren; j++)
				{
					testChildren(element.getChildAt(j));
				}
			}
			
			function validateVideoElement(element:SMILMediaElement):void
			{
				assertTrue(element.type == SMILElementType.VIDEO);
				// Use the URL class to validate it's a valid URL
				var uri:URL = new URL(element.src);
				assertTrue(uri.path.length > 0);
			}
		}
	}
}
