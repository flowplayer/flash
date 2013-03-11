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
package org.osmf.vast.parser.base
{	
	/**
	 *  A DTO for tracking data
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	 
	
	public dynamic class VAST2TrackingData
	{

		private var _impressionArray : Array;
		private var _surveyArray : Array;
		private var _errorArray : Array;
		//Linear
		private var _trkCreativeViewEvent:Array;
		private var _trkStartEvent:Array;
		private var _trkMidPointEvent:Array;
		private var _trkFirstQuartileEvent:Array;
		private var _trkThirdQuartileEvent:Array;
		private var _trkCompleteEvent:Array;
		private var _trkMuteEvent:Array;
		private var _trkUnmuteEvent:Array; 
		private var _trkPauseEvent:Array;
		private var _trkFullScreenEvent:Array;
		private var _trkCloseEvent:Array;	
		private var _clickTrackingArray:Array;
		private var _trkRewindEvent:Array;
		private var _trkResumeEvent:Array;
		private var _trkExpandEvent:Array;
		private var _trkCollapseEvent:Array;
		private var _trkAcceptInvitationEvent:Array;		
		//Nonlinear
		private var _trkCreativeViewEventNonLinear:Array;
		private var _trkStartEventNonLinear:Array;
		private var _trkMidPointEventNonLinear:Array;
		private var _trkFirstQuartileEventNonLinear:Array;
		private var _trkThirdQuartileEventNonLinear:Array;
		private var _trkCompleteEventNonLinear:Array;
		private var _trkMuteEventNonLinear:Array;
		private var _trkUnmuteEventNonLinear:Array; 
		private var _trkPauseEventNonLinear:Array;
		private var _trkFullScreenEventNonLinear:Array;
		private var _trkCloseEventNonLinear:Array;	
		private var _clickTrackingArrayNonLinear:Array;
		private var _trkRewindEventNonLinear:Array;
		private var _trkResumeEventNonLinear:Array;
		private var _trkExpandEventNonLinear:Array;
		private var _trkCollapseEventNonLinear:Array;
		private var _trkAcceptInvitationEventNonLinear:Array;		
		
		public function VAST2TrackingData():void
		{
			_impressionArray = new Array();
			_surveyArray = new Array();
			_errorArray = new Array();
			//Linear
			_trkCreativeViewEvent = new Array();
			_trkStartEvent = new Array();
			_trkMidPointEvent = new Array();
			_trkFirstQuartileEvent = new Array();
			_trkThirdQuartileEvent = new Array();
			_trkCompleteEvent = new Array();
			_trkMuteEvent = new Array(); 
			_trkUnmuteEvent = new Array(); 
			_trkPauseEvent = new Array();
			_trkFullScreenEvent = new Array();
			_trkCloseEvent = new Array();
			_clickTrackingArray = new Array();
			_trkRewindEvent = new Array();
			_trkResumeEvent = new Array();
			_trkExpandEvent = new Array();
			_trkCollapseEvent = new Array();
			_trkAcceptInvitationEvent = new Array();
			//Nonlinear
			_trkCreativeViewEventNonLinear = new Array();
			_trkStartEventNonLinear = new Array();
			_trkMidPointEventNonLinear = new Array();
			_trkFirstQuartileEventNonLinear = new Array();
			_trkThirdQuartileEventNonLinear = new Array();
			_trkCompleteEventNonLinear = new Array();
			_trkMuteEventNonLinear = new Array(); 
			_trkUnmuteEventNonLinear = new Array(); 
			_trkPauseEventNonLinear = new Array();
			_trkFullScreenEventNonLinear = new Array();
			_trkCloseEventNonLinear = new Array();
			_clickTrackingArrayNonLinear = new Array();
			_trkRewindEventNonLinear = new Array();
			_trkResumeEventNonLinear = new Array();
			_trkExpandEventNonLinear = new Array();
			_trkCollapseEventNonLinear = new Array();
			_trkAcceptInvitationEventNonLinear = new Array();
		}
		
		
		public function get impressionArray() : Array { return _impressionArray;} 
		public function set impressionArray(val:Array):void { _impressionArray = val; }
		public function get surveyArray() : Array { return _surveyArray;} 
		public function set surveyArray(val:Array):void { _surveyArray = val; }	
		public function get errorArray() : Array { return _errorArray;} 
		public function set errorArray(val:Array):void { _errorArray = val; }
		//Linear
		public function get clickTrackingArray() : Array { return _clickTrackingArray;} 
		public function set clickTrackingArray(val:Array):void { _clickTrackingArray = val; }
		public function get trkStartEvent() : Array { return _trkStartEvent;} 
		public function set trkStartEvent(val:Array):void { _trkStartEvent = val; }
		public function get trkCreativeViewEvent() : Array { return _trkCreativeViewEvent;} 
		public function set trkCreativeViewEvent(val:Array):void { _trkCreativeViewEvent = val; }
		public function get trkMidPointEvent() : Array { return _trkMidPointEvent;} 
		public function set trkMidPointEvent(val:Array):void { _trkMidPointEvent = val; }
		public function get trkFirstQuartileEvent() : Array { return _trkFirstQuartileEvent;} 
		public function set trkFirstQuartileEvent(val:Array):void { _trkFirstQuartileEvent = val; }
		public function get trkThirdQuartileEvent() : Array { return _trkThirdQuartileEvent;} 
		public function set trkThirdQuartileEvent(val:Array):void { _trkThirdQuartileEvent = val; }
		public function get trkCompleteEvent() : Array { return _trkCompleteEvent;} 
		public function set trkCompleteEvent(val:Array):void { _trkCompleteEvent = val; }
		public function get trkMuteEvent() : Array { return _trkMuteEvent;} 
		public function set trkMuteEvent(val:Array):void { _trkMuteEvent = val; }
		public function get trkUnmuteEvent() : Array { return _trkUnmuteEvent;} 
		public function set trkUnmuteEvent(val:Array):void { _trkUnmuteEvent = val; }
		public function get trkPauseEvent() : Array { return _trkPauseEvent;} 
		public function set trkPauseEvent(val:Array):void { _trkPauseEvent = val; }
		public function get trkFullScreenEvent() : Array { return _trkFullScreenEvent;} 
		public function set trkFullScreenEvent(val:Array):void { _trkFullScreenEvent = val; }
		public function get trkCloseEvent() : Array { return _trkCloseEvent;} 
		public function set trkCloseEvent(val:Array):void { _trkCloseEvent = val; }
		public function get trkRewindEvent() : Array { return _trkRewindEvent;} 
		public function set trkRewindEvent(val:Array):void { _trkRewindEvent = val; }
		public function get trkResumeEvent() : Array { return _trkResumeEvent;} 
		public function set trkResumeEvent(val:Array):void { _trkResumeEvent = val; }
		public function get trkExpandEvent() : Array { return _trkExpandEvent;} 
		public function set trkExpandEvent(val:Array):void { _trkExpandEvent = val; }
		public function get trkCollapseEvent() : Array { return _trkCollapseEvent;} 
		public function set trkCollapseEvent(val:Array):void { _trkCollapseEvent = val; }
		public function get trkAcceptInvitationEvent() : Array { return _trkAcceptInvitationEvent;} 
		public function set trkAcceptInvitationEvent(val:Array):void { _trkAcceptInvitationEvent = val; }
		//Nonlinear
		public function get trkStartEventNonLinear() : Array { return _trkStartEventNonLinear;} 
		public function set trkStartEventNonLinear(val:Array):void { _trkStartEventNonLinear = val; }
		public function get trkCreativeViewEventNonLinear() : Array { return _trkCreativeViewEventNonLinear;} 
		public function set trkCreativeViewEventNonLinear(val:Array):void { _trkCreativeViewEventNonLinear = val; }
		public function get trkMidPointEventNonLinear() : Array { return _trkMidPointEventNonLinear;} 
		public function set trkMidPointEventNonLinear(val:Array):void { _trkMidPointEventNonLinear = val; }
		public function get trkFirstQuartileEventNonLinear() : Array { return _trkFirstQuartileEventNonLinear;} 
		public function set trkFirstQuartileEventNonLinear(val:Array):void { _trkFirstQuartileEventNonLinear = val; }
		public function get trkThirdQuartileEventNonLinear() : Array { return _trkThirdQuartileEventNonLinear;} 
		public function set trkThirdQuartileEventNonLinear(val:Array):void { _trkThirdQuartileEventNonLinear = val; }
		public function get trkCompleteEventNonLinear() : Array { return _trkCompleteEventNonLinear;} 
		public function set trkCompleteEventNonLinear(val:Array):void { _trkCompleteEventNonLinear = val; }
		public function get trkMuteEventNonLinear() : Array { return _trkMuteEventNonLinear;} 
		public function set trkMuteEventNonLinear(val:Array):void { _trkMuteEventNonLinear = val; }
		public function get trkUnmuteEventNonLinear() : Array { return _trkUnmuteEventNonLinear;} 
		public function set trkUnmuteEventNonLinear(val:Array):void { _trkUnmuteEventNonLinear = val; }
		public function get trkPauseEventNonLinear() : Array { return _trkPauseEventNonLinear;} 
		public function set trkPauseEventNonLinear(val:Array):void { _trkPauseEventNonLinear = val; }
		public function get trkFullScreenEventNonLinear() : Array { return _trkFullScreenEventNonLinear;} 
		public function set trkFullScreenEventNonLinear(val:Array):void { _trkFullScreenEventNonLinear = val; }
		public function get trkCloseEventNonLinear() : Array { return _trkCloseEventNonLinear;} 
		public function set trkCloseEventNonLinear(val:Array):void { _trkCloseEventNonLinear = val; }
		public function get trkRewindEventNonLinear() : Array { return _trkRewindEventNonLinear;} 
		public function set trkRewindEventNonLinear(val:Array):void { _trkRewindEventNonLinear = val; }
		public function get trkResumeEventNonLinear() : Array { return _trkResumeEventNonLinear;} 
		public function set trkResumeEventNonLinear(val:Array):void { _trkResumeEventNonLinear = val; }
		public function get trkExpandEventNonLinear() : Array { return _trkExpandEventNonLinear;} 
		public function set trkExpandEventNonLinear(val:Array):void { _trkExpandEventNonLinear = val; }
		public function get trkCollapseEventNonLinear() : Array { return _trkCollapseEventNonLinear;} 
		public function set trkCollapseEventNonLinear(val:Array):void { _trkCollapseEventNonLinear = val; }
		public function get trkAcceptInvitationEventNonLinear() : Array { return _trkAcceptInvitationEventNonLinear;} 
		public function set trkAcceptInvitationEventNonLinear(val:Array):void { _trkAcceptInvitationEventNonLinear = val; }
		public function get clickTrackingArrayNonLinear() : Array { return _clickTrackingArrayNonLinear;} 
		public function set clickTrackingArrayNonLinear(val:Array):void { _clickTrackingArrayNonLinear = val; }
				
		// Prevent errors
		public function get trkStopEvent() : Array { return trkCloseEvent;} 
		public function set trkStopEvent(val:Array):void { }
		public function get trkReplayEvent() : Array { return new Array();} 
		public function set trkReplayEvent(val:Array):void { }
		

	}
}
