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
package org.osmf.vast.parser {
	

	import flash.events.Event;
	
	import org.osmf.vast.parser.base.Parser;
	import org.osmf.vast.parser.base.VAST2InLineElement;
	import org.osmf.vast.parser.base.VAST2Time;
	import org.osmf.vast.parser.base.VAST2TrackingData;
	import org.osmf.vast.parser.base.VAST2WrapperElement;
	import org.osmf.vast.parser.base.events.ParserEvent;
	
	/**
	 * Parse VAST formatted XML ad tags.
	 * 
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public dynamic class VAST2Parser extends Parser {
		
		// Static vars also need to be replicated in ../../VAST2Parser.as legacy file since static vars can't be inherited
		public static const TOGGLE_VAST_WRAPPER_CALLED:String = "toggleVastWrapperCalled";
		
		public var _adTagID : String;
		

		public var _trackingData : VAST2TrackingData;
		public var _InLine : VAST2InLineElement;
		public var _Wrapper : VAST2WrapperElement;

		/*public var _vastVars : Object;*/
		public var _isVASTXML : Boolean = false;
		public var _isVASTXMLWrapper : Boolean = false;
		private var VASTVersion:Number = 2.0; // TODO this has to be set by one of the VAST parsers
		
		private var _LinearAdsArray:Array;
		private var _NonLinearAdsArray:Array;
		private var _CompanionAdsArray:Array;
		
		public function VAST2Parser(trackingData:VAST2TrackingData = null) {
			//UIFDebugMessage.getInstance()._debugMessage(3, "Init VAST2Parser", "Instream", "VAST2Parser (v1)");
			super();
			tagType = "VAST2";
		
			_adTagID = "";
			
			if (trackingData != null)
				_trackingData = trackingData;
			else
				_trackingData = new VAST2TrackingData();
				
			_Wrapper = new VAST2WrapperElement();
			_InLine = new VAST2InLineElement();
		
			/*_vastVars = new Object();*/
		}
		
	
		/**
		 * performs a check to see if the xml passed to it is VAST
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	 
		public override function checkFormat(data:XML):Boolean
		{
			//UIFDebugMessage.getInstance()._debugMessage(3, "In checkFormat() ", "Instream", "VAST2Parser (v1)");
			
			if(String(data.name()) == "VAST")
			{
				
				return true;
			}
			else
			{ 
				return false;
			}
		}
		
		//stores vast tags in the _vastVars object
		protected function createVASTvars() : void {
			
			//UIFDebugMessage.getInstance()._debugMessage(3, "In createVASTvars() ", "Instream", "VAST2Parser (v1)");
			
			if(!_isVASTXML && !_isVASTXMLWrapper) {
				dispatchError(4);
				return;
			}


			//check For VAST 2 restrictions
			if ( VASTv2RestrictionFound() )
			{
				dispatchError(4);
			}
			else
			{
				createCreativesArrays();
				dispatchEvent(new ParserEvent(ParserEvent.XML_PARSED, this));
			}
		}

		/*
			Data is only tested if all wrappers have been parsed already, so we don't throw a false alarm here.
			
			Checks three cases,
			a) NonLinear is filled and Linear is not
			b) If NonLinear and Linear are given, ignore the NonLinear
			c) Linear is of type SWF
		*/
		private function VASTv2RestrictionFound():Boolean
		{
			var error:Boolean = false;
			

			
			return error;
		}
		
		//break down the parsed data into arrays of same typed ad formats
		private function createCreativesArrays():void
		{
			_LinearAdsArray = new Array();
			_NonLinearAdsArray = new Array();
			_CompanionAdsArray = new Array();
			
			for (var i:uint =0; i < _InLine.Creatives.length; i++)
			{
				//always returns a length of 0, even if it contains something - therefore it's always pushed
				if (_InLine.Creatives[i].Linear)
				{
					_LinearAdsArray.push(_InLine.Creatives[i].Linear);
				}
				
				//creatives are pushed into an array, therefore we test if the have a length
				var j:Number = 0;
				if (_InLine.Creatives[i].NonLinearAds.length > 0)
				{
					for (j = 0; j < _InLine.Creatives[i].NonLinearAds.length; j++)
					{
						_NonLinearAdsArray.push(_InLine.Creatives[i].NonLinearAds[j]);
					}
				}
					
				//creatives are pushed into an array, therefore we test if the have a length				
				if (_InLine.Creatives[i].CompanionAds.length > 0)
				{
					for (j = 0; j < _InLine.Creatives[i].CompanionAds.length; j++)
					{
						_CompanionAdsArray.push(_InLine.Creatives[i].CompanionAds[j]);
					}
				}
			}
		}
		
		protected override function parseXMLData() : void {
			//Parse Data Here: _adTagXML:XMLDocument is the XML Data
			
			//UIFDebugMessage.getInstance()._debugMessage(3, "In parseXMLData() ", "Instream", "VAST2Parser (v1)");
			
			var i:Number = 0;
			var j:Number = 0;
			var Impression:Object;
			
			if(mainXML.Ad != undefined) {
				_adTagID = mainXML.Ad.@id;
			}
				
			if(mainXML.Ad.Wrapper.AdSystem != undefined) {
				_isVASTXMLWrapper = true;
				dispatchEvent(new Event(VAST2Parser.TOGGLE_VAST_WRAPPER_CALLED));
				_Wrapper = new VAST2WrapperElement( mainXML.Ad.Wrapper, _trackingData);
				_Wrapper.parseXMLData();

			} else {
				_isVASTXML = true;
				_isVASTXMLWrapper = false;
				_InLine = new VAST2InLineElement(mainXML.Ad.InLine, _trackingData);
				_InLine.parseXMLData();
			}
			
			createVASTvars();
			createCreativesArrays();
		}

		//VAST Getters/Setters
		
		/**
		 * Returns a boolean indicating whether it's a VAST XML
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get isVASTXML() : Boolean {
			return _isVASTXML;
		}
		
		/**
		 * Returns a boolean indicating whether it's a VAST Wrapper XML
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get isVASTXMLWRAPPER() : Boolean 
		{
			return _isVASTXMLWrapper;
		}
		
		/**
		 * Returns a string indicating the ID of the current adTag
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get adTagID() : String 
		{
			return _adTagID;
		}
		
		/**
		 * Returns a string indicating adTagWrapperSystem of the XML file
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get adTagWrapperSystem() : String 
		{
			return _Wrapper.AdSystem;
		}

		/**
		 * Returns a string indicating the VASTAdTagURL 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get VASTAdTagURL() : String 
		{
			return _Wrapper.VASTAdTagURL;
		}

		/**
		 * Returns a string indicating the adTagSystem 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get adTagSystem() : String 
		{
			if (_isVASTXMLWrapper)
				return _Wrapper.AdSystem;
			else
				return _InLine.AdSystem;
		}

		/**
		 * Returns a string indicating the adTagTitle 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get adTagTitle() : String 
		{
			return _InLine.AdTitle;
		}

		/**
		 * Returns a string indicating the adTagImpressionURL 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get adTagImpressionURL() : Array 
		{
			return _trackingData.impressionArray;
		}

		/**
		 * Returns an array of impression urls
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get impressionArray() : Array
		{
			return _trackingData.impressionArray;
		}

		/**
		 * Returns an array of clickThru urls
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get clickThruArray() : Array
		{
			return _trackingData.clickTrackingArray;
		}
		
		/**
		 * Returns an array of error urls
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get errorArray() : Array
		{
			return _trackingData.errorArray;
		}

		/**
		 * Returns an array of tracking urls
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get trackingArray() : Array 
		{
			return _trackingData.trackingArray;
		}

		/**
		 * Returns the duration of the media file
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get adTagVASTDuration() : VAST2Time 
		{
			//return _InLine.Creatives.Linear.videoDuration;
			return _LinearAdsArray[0].videoDuration;
		}

		/**
		 * Returns a string with the clickThru url
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get adTagClickThrough() : String 
		{
			if (_LinearAdsArray.length > 0)
				return _LinearAdsArray[0].ClickThrough;
			else
				return "";
			}
		/**
		 * Returns a string with the clickThru url
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get adTagClickThroughNonLinear() : String 
		{
			if (_NonLinearAdsArray.length > 0)
				return _NonLinearAdsArray[0].nonLinearClickThrough;
			else
				return "";
		}
		/**
		 * Returns an array of media file urls
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get mediafileArray() : Array
		{
			return _LinearAdsArray[0].MediaFiles;
		}

		/**
		 * Returns an array of tracking urls for the start event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get trkStartEvent() : Array 
		{
			return _trackingData.trkStartEvent;
		}
		
		/**
		 * Returns an array of tracking urls for the midpoint event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get trkMidPointEvent() : Array 
		{
			return _trackingData.trkMidPointEvent;
		}
		/**
		 * Returns an array of tracking urls for the first quartile event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get trkFirstQuartileEvent() : Array 
		{
			return _trackingData.trkFirstQuartileEvent;
		}
		/**
		 * Returns an array of tracking urls for the third quartile event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get trkThirdQuartileEvent() : Array 
		{
			return _trackingData.trkThirdQuartileEvent;
		}
		/**
		 * Returns an array of tracking urls for the complete event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get trkCompleteEvent() : Array 
		{
			return _trackingData.trkCompleteEvent;
		}
		/**
		 * Returns an array of tracking urls for the mute event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get trkMuteEvent() : Array 
		{
			return _trackingData.trkMuteEvent;
		}
		/**
		 * Returns an array of tracking urls for the pause event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get trkPauseEvent() : Array 
		{
			return _trackingData.trkPauseEvent;
		}
		/**
		 * Returns an array of tracking urls for the replay event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get trkReplayEvent() : Array 
		{
			return _trackingData.trkReplayEvent;
		}
		/**
		 * Returns an array of tracking urls for the fullscreen event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get trkFullScreenEvent() : Array 
		{
			return _trackingData.trkFullScreenEvent;
		}
		/**
		 * Returns an array of tracking urls for the stop event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get trkStopEvent() : Array 
		{
			return _trackingData.trkStopEvent;
		}
		/**
		 * Returns an array of tracking urls for the creativeView event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get trkCreativeViewEvent() : Array 
		{
			return _trackingData.trkCreativeViewEvent;
		}
		/**
		 * Returns an array of tracking urls for the unmute event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get trkUnmuteEvent() : Array 
		{
			return _trackingData.trkUnmuteEvent;
		}
		/**
		 * Returns an array of tracking urls for the click tracking
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get clickTrackingArray() : Array 
		{
			return _trackingData.clickTrackingArray;
		}
		/**
		 * Returns an array of tracking urls for the close event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get trkCloseEvent() : Array 
		{
			return _trackingData.trkCloseEvent;
		}
		/**
		 * Returns an array of tracking urls for the rewind event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get trkRewindEvent() : Array 
		{
			return _trackingData.trkRewindEvent;
		}
		/**
		 * Returns an array of tracking urls for the resume event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get trkResumeEvent() : Array 
		{
			return _trackingData.trkResumeEvent;
		}
		/**
		 * Returns an array of tracking urls for the expand event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get trkExpandEvent() : Array 
		{
			return _trackingData.trkExpandEvent;
		}
		/**
		 * Returns an array of tracking urls for the collapse event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get trkCollapseEvent() : Array 
		{
			return _trackingData.trkCollapseEvent;
		}
		/**
		 * Returns an array of tracking urls for the accept invitation event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get trkAcceptInvitationEvent() : Array 
		{
			return _trackingData.trkAcceptInvitationEvent;
		}
		/**
		 * Returns an array of tracking urls for the nonlinear  creativeView event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get trkCreativeViewEventNonLinear() : Array
		{
			return _trackingData.trkCreativeViewEventNonLinear;
		}
		/**
		 * Returns an array of tracking urls for the nonlinear start event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkStartEventNonLinear() : Array
		{
			return _trackingData.trkStartEventNonLinear;
		}
		/**
		 * Returns an array of tracking urls for the nonlinear firstquartile event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkFirstQuartileEventNonLinear() : Array
		{
			return _trackingData.trkFirstQuartileEventNonLinear;
		}
		/**
		 * Returns an array of tracking urls for the nonlinear thirdquartile event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkThirdQuartileEventNonLinear() : Array
		{
			return _trackingData.trkThirdQuartileEventNonLinear;
		}
		
		/**
		 * Returns an array of tracking urls for the nonlinear midpoint event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkMidPointEventNonLinear() : Array
		{
			return _trackingData.trkMidPointEventNonLinear;
		}
		
		/**
		 * Returns an array of tracking urls for the nonlinear complete event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkCompleteEventNonLinear() : Array
		{
			return _trackingData.trkCompleteEventNonLinear;
		}
		
		/**
		 * Returns an array of tracking urls for the nonlinear mute event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkMuteEventNonLinear() : Array
		{
			return _trackingData.trkMuteEventNonLinear;
		}							
		/**
		 * Returns an array of tracking urls for the nonlinear  unmute event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkUnmuteEventNonLinear(): Array  
		{
			return _trackingData.trkUnmuteEventNonLinear;
		}
		
		/**
		 * Returns an array of tracking urls for the nonlinear pause event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkPauseEventNonLinear(): Array  
		{
			return _trackingData.trkPauseEventNonLinear;
		}
		
		/**
		 * Returns an array of tracking urls for the nonlinear fullscreen event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkFullScreenEventNonLinear(): Array 
		{
			return _trackingData.trkFullScreenEventNonLinear;
		}
		
		/**
		 * Returns an array of tracking urls for the nonlinear click trackers
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get clickTrackingArrayNonLinear() : Array
		{
			return _trackingData.clickTrackingArrayNonLinear;
		}
		
		/**
		 * Returns an array of tracking urls for the nonlinear rewind event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkRewindEventNonLinear() : Array
		{
			return _trackingData.trkRewindEventNonLinear;
		}
		
		/**
		 * Returns an array of tracking urls for the nonlinear close event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkCloseEventNonLinear() : Array
		{
			return _trackingData.trkCloseEventNonLinear;
		}
		
		/**
		 * Returns an array of tracking urls for the nonlinear resume event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkResumeEventNonLinear() : Array
		{
			return _trackingData.trkResumeEventNonLinear;
		}
		
		/**
		 * Returns an array of tracking urls for the nonlinear expand event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkExpandEventNonLinear() : Array
		{
			return _trackingData.trkExpandEventNonLinear;
		}
		/**
		 * Returns an array of tracking urls for the nonlinear collapse event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkCollapseEventNonLinear() : Array
		{
			return _trackingData.trkCollapseEventNonLinear;
		}
		
		/**
		 * Returns an array of tracking urls for the nonlinear accept invitation event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkAcceptInvitationEventNonLinear() : Array
		{
			return _trackingData.trkAcceptInvitationEventNonLinear;
		}		
		/**
		 * Returns an array of urls for companion ads
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get companionArray() : Array
		{
			return _CompanionAdsArray;
		}
		/**
		 * Returns an array of urls for nonlinear ads
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get nonlinearArray() : Array
		{
			return _NonLinearAdsArray;
		}
		/**
		 * Returns an array of urls for clickThrus (deprecated)
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get trkClickThru(): Array 
		{
			return _trackingData._clickTrackingArray;
		}
			
		
	}

/* End package */
}
