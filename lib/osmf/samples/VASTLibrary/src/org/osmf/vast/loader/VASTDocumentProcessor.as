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
*  Contributor(s): Eyewonder, LLC
*  
*****************************************************/
package org.osmf.vast.loader
{
	import flash.events.EventDispatcher;
	
	import org.osmf.utils.HTTPLoader;
	import org.osmf.vast.model.VASTDataObject;
	import org.osmf.vast.model.VASTDocument;
	import org.osmf.vast.parser.base.VAST2TrackingData;

	CONFIG::LOGGING
	{
	import org.osmf.logging.Logger;
	import org.osmf.logging.Log;
	}

	[Event("processed")]
	[Event("processingFailed")]
	
	internal class VASTDocumentProcessor extends EventDispatcher
	{
		/**
		 * @private Exposes the same interface as VAST1DocumentProcessor and VAST2DocumentProcessor.
		 * Determines which processor to use based on the VAST version stored in the VASTDataObject.
		 */	
		public function VASTDocumentProcessor(maxNumWrapperRedirects:Number, httpLoader:HTTPLoader)
		{
			super();
			
			this.maxNumWrapperRedirects = maxNumWrapperRedirects;
			this.httpLoader = httpLoader;
		}
		/**
		 * @private
		 */	
		public function processVASTDocument(documentContents:String, trackingData:VAST2TrackingData = null):void
		{
			var processingFailed:Boolean = false;
			var vastDocument:VASTDocument = null;
			var documentXML:XML = null;
			
			try
			{
				documentXML = new XML(documentContents);
			}
			catch (error:TypeError)
			{
				processingFailed = true;
			}
			
			if (documentXML != null)
			{
				var vastVersion:Number;
				if(documentXML.localName() == VAST_1_ROOT){
					vastVersion = VASTDataObject.VERSION_1_0;
				}else if(documentXML.localName() == VAST_2_ROOT){
					vastVersion = documentXML.@version;
				}
				
				switch(vastVersion)
				{
					case VASTDataObject.VERSION_1_0:
						var vast1DocumentProcessor:VAST1DocumentProcessor = new VAST1DocumentProcessor(maxNumWrapperRedirects, httpLoader);
						vast1DocumentProcessor.addEventListener(VASTDocumentProcessedEvent.PROCESSED, cloneDocumentProcessorEvent);
						vast1DocumentProcessor.addEventListener(VASTDocumentProcessedEvent.PROCESSING_FAILED, cloneDocumentProcessorEvent);						
						vast1DocumentProcessor.processVASTDocument(documentContents);					
					break;
					case VASTDataObject.VERSION_2_0:
						var vast2DocumentProcessor:VAST2DocumentProcessor = new VAST2DocumentProcessor(maxNumWrapperRedirects, httpLoader);
						vast2DocumentProcessor.addEventListener(VASTDocumentProcessedEvent.PROCESSED, cloneDocumentProcessorEvent);
						vast2DocumentProcessor.addEventListener(VASTDocumentProcessedEvent.PROCESSING_FAILED, cloneDocumentProcessorEvent); 					
						vast2DocumentProcessor.processVASTDocument(documentContents, trackingData);
					break;
					default:
						processingFailed = true;
					break;
				}			
			}
			if (processingFailed)
			{
				CONFIG::LOGGING
				{
					logger.debug("[VAST] Processing failed for document with contents: " + documentContents);
				}
				
				dispatchEvent(new VASTDocumentProcessedEvent(VASTDocumentProcessedEvent.PROCESSING_FAILED));
			}			
		}
		
		private function cloneDocumentProcessorEvent(event:VASTDocumentProcessedEvent):void
		{
			var parser:EventDispatcher = event.target as EventDispatcher;
			parser.removeEventListener(VASTDocumentProcessedEvent.PROCESSED, cloneDocumentProcessorEvent);
			parser.removeEventListener(VASTDocumentProcessedEvent.PROCESSING_FAILED, cloneDocumentProcessorEvent); 
			dispatchEvent(event.clone());
		}

		private var maxNumWrapperRedirects:Number;
		private var httpLoader:HTTPLoader;
		
		private static const VAST_1_ROOT:String = "VideoAdServingTemplate";
		private static const VAST_2_ROOT:String = "VAST";
		
		CONFIG::LOGGING
		private static const logger:Logger = Log.getLogger("org.osmf.vast.loader.VASTDocumentProcessor");
	}
}