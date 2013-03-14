/*****************************************************
*  
*  Copyright 2010 Eyewonder, LLC.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Eyewonder, LLC.
*  Portions created by Eyewonder, LLC. are Copyright (C) 2010 
*  Eyewonder, LLC. A Limelight Networks Business. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.vast.loader
{
	import flash.events.EventDispatcher;
	import org.osmf.events.LoadEvent;
	import org.osmf.media.URLResource;
	import org.osmf.traits.LoadState;
	import org.osmf.utils.HTTPLoader;
	import org.osmf.vast.model.VAST2Translator;
	import org.osmf.vast.model.VASTDataObject;
	import org.osmf.vast.parser.VAST2Parser;
	import org.osmf.vast.parser.base.VAST2TrackingData;
	import org.osmf.vast.parser.base.events.ParserErrorEvent;
	import org.osmf.vast.parser.base.events.ParserEvent;
	
	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
		import org.osmf.logging.Log;
	}

	[Event("processed")]
	[Event("processingFailed")]
	
	internal class VAST2DocumentProcessor extends EventDispatcher
	{
		
		/**
		 * Processor for VAST 2 documents.  
		 * 
		 * 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function VAST2DocumentProcessor(maxNumWrapperRedirects:Number, httpLoader:HTTPLoader)
		{
			super();
			
			this.maxNumWrapperRedirects = maxNumWrapperRedirects;
			this.httpLoader = httpLoader;
		}
		
		/**
		 *Takes a VAST document, converts it to XML, then submits it to the parser for parsing.
		 * 
		 * @param documentContents The VAST document that holds the raw VAST information
		 * @trackingData A data transfer object for tracking data.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function processVASTDocument(documentContents:String, trackingData:VAST2TrackingData = null):void
		{
			var processingFailed:Boolean = false;
			
			var vastDocument:VAST2Translator = null;
			
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
				parser = new VAST2Parser(trackingData);
				parser.addEventListener(ParserEvent.XML_PARSED, onXMLParsed);
				parser.addEventListener(ParserErrorEvent.XML_ERROR, onXMLParseError);
				parser.parse(documentXML);
			}
		}
		
		private function onXMLParsed(event:ParserEvent):void
		{
			parser.removeEventListener(ParserEvent.XML_PARSED, onXMLParsed);
			parser.removeEventListener(ParserErrorEvent.XML_ERROR, onXMLParseError);
			
			if(parser.isVASTXMLWRAPPER)
			{
				CONFIG::LOGGING
				{
				logger.debug("[VAST] " + parser.adTagTitle + " is a VAST wrapper tag.")
				}
				loadVASTWrapper(parser);
			}
			else
			{
				CONFIG::LOGGING
				{
				logger.debug("[VAST] " + parser.adTagTitle + " is a VAST tag.")
				}
				var translator:VAST2Translator = new VAST2Translator(parser);
				dispatchEvent(new VASTDocumentProcessedEvent(VASTDocumentProcessedEvent.PROCESSED, translator));
			}
		}
		
		private function onXMLParseError(event:ParserErrorEvent):void
		{
			parser.removeEventListener(ParserEvent.XML_PARSED, onXMLParsed);
			parser.removeEventListener(ParserErrorEvent.XML_ERROR, onXMLParseError);
			CONFIG::LOGGING
			{
				logger.debug("[VAST] Error Parsing Tag: " + event.description);
			}
			dispatchEvent(new VASTDocumentProcessedEvent(VASTDocumentProcessedEvent.PROCESSING_FAILED));			
		}
		
		private function loadVASTWrapper(parser:VAST2Parser):void
		{			
			if(this.maxNumWrapperRedirects <= 0)
			{
				CONFIG::LOGGING
				{
					logger.debug("[VAST] Reached max number of redirects. Canceling wrapper request. Increase maxNumWrapperRedirects or remove some wrapper redirect tags");
				}
				
				dispatchEvent(new VASTDocumentProcessedEvent(VASTDocumentProcessedEvent.PROCESSING_FAILED));
				return;
			}				

			if(parser._Wrapper.VASTAdTagURL == "" || parser._Wrapper.VASTAdTagURL == null)
			{
				dispatchEvent(new VASTDocumentProcessedEvent(VASTDocumentProcessedEvent.PROCESSING_FAILED));
				return;
			}
			
			CONFIG::LOGGING
			{
				logger.debug("[VAST] Ad " + parser.adTagID + " is a wrapper, loading...");
			}
						
			// Use another VASTLoader to load the wrapper, decrementing
			// our redirect count so that we don't redirect too many times.
			var wrapperLoader:VASTLoader = new VASTLoader( Math.max(-1, maxNumWrapperRedirects - 1), httpLoader, parser._trackingData);	
			var wrapperResource:URLResource = new URLResource(parser._Wrapper.VASTAdTagURL);
			var wrapperLoadTrait:VASTLoadTrait = new VASTLoadTrait(wrapperLoader, wrapperResource);
			
			wrapperLoadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onWrapperLoadStateChange);
			wrapperLoadTrait.load();
		
			function onWrapperLoadStateChange(event:LoadEvent):void
			{
				if (event.loadState == LoadState.READY)
				{
                	var processedDocument:VASTDataObject;
                	if (wrapperLoadTrait.vastDocument.vastVersion == VASTDataObject.VERSION_2_0) {
                    	var translator:VAST2Translator = wrapperLoadTrait.vastDocument as VAST2Translator;
                    	var parser:VAST2Parser = translator.vastParser as VAST2Parser;
                    	processedDocument = new VAST2Translator(parser);
                	}
                	else {
                    	processedDocument = wrapperLoadTrait.vastDocument;
                	}

                	CONFIG::LOGGING
                	{
                    	logger.debug("[VAST] Load Wrapper Complete");

                	}
                	dispatchEvent(new VASTDocumentProcessedEvent(VASTDocumentProcessedEvent.PROCESSED, processedDocument));
				}
				else if (event.loadState == LoadState.LOAD_ERROR)
				{
					wrapperLoadTrait.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onWrapperLoadStateChange);
					
					var tagId:String = "";
					if(parser != null)
						tagId = parser.adTagID;
						
					CONFIG::LOGGING
					{
						logger.debug("[VAST] Wrapper ad " + tagId + " load failed");					
					}

					dispatchEvent(new VASTDocumentProcessedEvent(VASTDocumentProcessedEvent.PROCESSING_FAILED));
				}
			}
		}
		
		private var maxNumWrapperRedirects:Number;
		private var httpLoader:HTTPLoader;
		private var parser:VAST2Parser;
		
		CONFIG::LOGGING
		private static const logger:Logger = Log.getLogger("org.osmf.vast.loader.VASTDocumentProcessor");
	}
}
