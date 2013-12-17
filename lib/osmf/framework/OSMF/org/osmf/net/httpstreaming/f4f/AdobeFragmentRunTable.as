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
package org.osmf.net.httpstreaming.f4f
{
	import __AS3__.vec.Vector;
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Fragment run table. Each entry in the table is the first fragment of a sequence of 
	 * fragments that have the same duration.
	 */
	internal class AdobeFragmentRunTable extends FullBox
	{
		/**
		 * Constructor
		 * 
		 * @param bi The box info that contains the size and type of the box
		 * @param parser The box parser to be used to assist constructing the box
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function AdobeFragmentRunTable()
		{
			super();
			
			_fragmentDurationPairs = new Vector.<FragmentDurationPair>();
		}
		
		/**
		 * The time scale for this run table.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get timeScale():uint
		{
			return _timeScale;
		}
		
		public function set timeScale(value:uint):void
		{
			_timeScale = value;
		}

		/**
		 * The quality segment URL modifiers.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get qualitySegmentURLModifiers():Vector.<String>
		{
			return _qualitySegmentURLModifiers;
		}

		public function set qualitySegmentURLModifiers(value:Vector.<String>):void
		{
			_qualitySegmentURLModifiers = value;
		}

		/**
		 * A list of <first fragment, duration> pairs.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get fragmentDurationPairs():Vector.<FragmentDurationPair>
		{
			return _fragmentDurationPairs;
		}
		
		/**
		 * Append a fragment duration pair to the list. The accrued duration for the newly appended
		 * fragment duration needed to be calculated. This is basically the total duration till the
		 * time spot that the newly appended fragment duration pair represents.
		 * 
		 * @param fdp The <first fragment, duration> pair to be appended to the list.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function addFragmentDurationPair(fdp:FragmentDurationPair):void
		{
			_fragmentDurationPairs.push(fdp);
		}
		
		/**
		 * Given a time spot in terms of the time scale used by the fragment table, returns the corresponding
		 * Id of the fragment that contains the time spot.
		 * 
		 * @return the Id of the fragment that contains the time spot.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function findFragmentIdByTime(time:Number, totalDuration:Number, live:Boolean=false):FragmentAccessInformation
		{
			if (_fragmentDurationPairs.length <= 0)
			{
				return null;
			}
			
			var fdp:FragmentDurationPair = null;
			
			for (var i:uint = 1; i < _fragmentDurationPairs.length; i++)
			{
				fdp = _fragmentDurationPairs[i];
				if (fdp.durationAccrued >= time)
				{
					return validateFragment(calculateFragmentId(_fragmentDurationPairs[i - 1], time), totalDuration, live);
				}
			}
			
			return validateFragment(calculateFragmentId(_fragmentDurationPairs[_fragmentDurationPairs.length - 1], time), totalDuration, live);
		}
		
		/**
		 * Given a fragment id, check whether the current fragment is valid or a discontinuity.
		 * If the latter, skip to the nearest fragment and return the new fragment id.
		 * 
		 * @return the Id of the fragment that is valid.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function validateFragment(fragId:uint, totalDuration:Number, live:Boolean=false):FragmentAccessInformation
		{
			var size:uint = _fragmentDurationPairs.length - 1;
			var fai:FragmentAccessInformation = null;

			for (var i:uint = 0; i < size; i++)
			{
				var curFdp:FragmentDurationPair = _fragmentDurationPairs[i];
				var nextFdp:FragmentDurationPair = _fragmentDurationPairs[i+1];
				if ((curFdp.firstFragment <= fragId) && (fragId < nextFdp.firstFragment))
				{
					if (curFdp.duration <= 0)
					{
						fai = getNextValidFragment(i+1, totalDuration);
					}
					else
					{
						fai = new FragmentAccessInformation();
						fai.fragId = fragId;
						fai.fragDuration = curFdp.duration;
						fai.fragmentEndTime = curFdp.durationAccrued + curFdp.duration * (fragId - curFdp.firstFragment + 1);
					}
					
					break;
				}
				else if ((curFdp.firstFragment <= fragId) && endOfStreamEntry(nextFdp))
				{
					if (curFdp.duration > 0)
					{
						var timeResidue:Number = totalDuration - curFdp.durationAccrued;
						var timeDistance:Number = (fragId - curFdp.firstFragment + 1) * curFdp.duration;
						var fragStartTime:Number = (fragId - curFdp.firstFragment) * curFdp.duration;
						if (timeResidue > fragStartTime)
						{
							if (!live || ((fragStartTime + curFdp.duration + curFdp.durationAccrued) <= totalDuration))
							{
								fai = new FragmentAccessInformation();
								fai.fragId = fragId;
								fai.fragDuration = curFdp.duration;
								if (timeResidue >= timeDistance)
								{
									fai.fragmentEndTime = curFdp.durationAccrued + timeDistance;
								}
								else
								{
									fai.fragmentEndTime = curFdp.durationAccrued + timeResidue;
								}
								break;				
							}
						}						
					}
					
				}
			}
			if (fai == null)
			{
				var lastFdp:FragmentDurationPair = _fragmentDurationPairs[size];
				if (lastFdp.duration > 0 && fragId >= lastFdp.firstFragment)
				{
					timeResidue = totalDuration - lastFdp.durationAccrued;
					timeDistance = (fragId - lastFdp.firstFragment + 1) * lastFdp.duration;
					fragStartTime = (fragId - lastFdp.firstFragment) * lastFdp.duration;
					if (timeResidue > fragStartTime)
					{
						if (!live || ((fragStartTime + lastFdp.duration + lastFdp.durationAccrued) <= totalDuration))
						{
							fai = new FragmentAccessInformation();
							fai.fragId = fragId;
							fai.fragDuration = lastFdp.duration;
							if (timeResidue >= timeDistance)
							{
								fai.fragmentEndTime = lastFdp.durationAccrued + timeDistance;
							}
							else
							{
								fai.fragmentEndTime = lastFdp.durationAccrued + timeResidue;
							}
						}
					}						
				}
			}

			return fai;
		}
		
		private function getNextValidFragment(startIdx:uint, totalDuration:Number):FragmentAccessInformation
		{
			var fai:FragmentAccessInformation = null;
			for (var i:uint = startIdx; i < _fragmentDurationPairs.length; i++)
			{
				var fdp:FragmentDurationPair = _fragmentDurationPairs[i];
				if (fdp.duration > 0)
				{
					fai = new FragmentAccessInformation();
					fai.fragId = fdp.firstFragment;
					fai.fragDuration = fdp.duration;
					fai.fragmentEndTime = fdp.durationAccrued + fdp.duration;
					
					break;
				}
			}
			
			return fai;
		}
		
		private function endOfStreamEntry(fdp:FragmentDurationPair):Boolean
		{
			return (fdp.duration == 0 && fdp.discontinuityIndicator == 0);
		}
		
		/**
		 * Given a fragment id, return the number of fragments after the 
		 * fragment with the id given.
		 * 
		 * @return the number of fragments after the fragment with the id given.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function fragmentsLeft(fragId:uint, currentMediaTime:Number):uint
		{
			if (_fragmentDurationPairs == null || _fragmentDurationPairs.length == 0)
			{
				return 0;
			}
			
			var fdp:FragmentDurationPair = _fragmentDurationPairs[fragmentDurationPairs.length - 1] as FragmentDurationPair;
			var fragments:uint = (currentMediaTime - fdp.durationAccrued) / fdp.duration + fdp.firstFragment - fragId -1;
			
			return fragments;
		}		
		
		/**
		 * @return whether the fragment table is complete.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function tableComplete():Boolean
		{
			if (_fragmentDurationPairs == null || _fragmentDurationPairs.length <= 0)
			{
				return false;
			}
			
			var fdp:FragmentDurationPair = _fragmentDurationPairs[fragmentDurationPairs.length - 1] as FragmentDurationPair;
			return (fdp.duration == 0 && fdp.discontinuityIndicator == 0);
		}
		
		public function adjustEndEntryDurationAccrued(value:Number):void
		{
			var fdp:FragmentDurationPair = _fragmentDurationPairs[_fragmentDurationPairs.length - 1];
			if (fdp.duration == 0)
			{
				fdp.durationAccrued = value;
			}
		}
		
		public function getFragmentDuration(fragId:uint):Number
		{
			var fdp:FragmentDurationPair = null;
			var i:uint = 0;			
			while ((i<_fragmentDurationPairs.length) && (_fragmentDurationPairs[i].firstFragment <= fragId))
			{
				i++;
			}
			if (i)
				return _fragmentDurationPairs[i-1].duration;
			else
				return 0;
		}


		// Internal
		//
		
		/**
		 * @private
		 * 
		 * return the first FragmentDurationPair whose index >= i that is not a discontinuity,
		 * or null if no such FragmentDurationPair exists.
		 **/
		private function findNextValidFragmentDurationPair(index:uint):FragmentDurationPair
		{
			for (var i:uint = index; i < _fragmentDurationPairs.length; ++i)
			{
				var fdp:FragmentDurationPair = _fragmentDurationPairs[i];
				if (fdp.duration > 0)
				{
					return fdp;
				}
			}
			
			return null;
		}
		
		/**
		 * @private
		 * 
		 * return the first FragmentDurationPair whose index < i that is not a discontinuity,
		 * or null if no such FragmentDurationPair exists.
		 **/
		private function findPrevValidFragmentDurationPair(index:uint):FragmentDurationPair
		{
			var i:uint = index;
			if(i > _fragmentDurationPairs.length)
			{
				i = _fragmentDurationPairs.length;
			}
			for (; i > 0; --i)
			{
				var fdp:FragmentDurationPair = _fragmentDurationPairs[i-1];
				if (fdp.duration > 0)
				{
					return fdp;
				}
			}
			return null;
		}
		
		private function calculateFragmentId(fdp:FragmentDurationPair, time:Number):uint
		{
			if (fdp.duration <= 0)
			{
				return fdp.firstFragment;
			}
			
			var deltaTime:Number = time - fdp.durationAccrued;
			// this is the old code. i'm pretty sure that its code faulty for
			// deltaTime that is an exact multiple of duration:
			//
			//var count:uint = (deltaTime > 0)? deltaTime / fdp.duration : 1;
			//if ((deltaTime % fdp.duration) > 0)
			//{
			//	count++;
			//}
			//return fdp.firstFragment + count - 1;
			return fdp.firstFragment + uint(deltaTime / fdp.duration);
		}
		
		
		/**
		 * @return the id of the first (non-discontinuity) fragment in the FRT, or 0 if no such fragment exists
		 **/
		public function get firstFragmentId():uint
		{
			var fdp:FragmentDurationPair = findNextValidFragmentDurationPair(0);
			if(fdp == null)
			{
				return 0;
			}
			return fdp.firstFragment;
		}
		
		/**
		 * @return true if the fragment is in a true gap within the middle of the content (discontinuity type 2).
		 * returns false if fragment < first fragment number
		 * returns false if fragment >= last fragment number
		 **/
		public function isFragmentInGap(fragmentId:uint):Boolean
		{
			var inGap:Boolean = false;
			forEachGap(function(opt:Object):Boolean
			{
				var fdp:FragmentDurationPair = opt.fdp as FragmentDurationPair;
				var nextFdp:FragmentDurationPair = opt.nextFdp as FragmentDurationPair;
				var gapStartFragmentId:Number = fdp.firstFragment;
				var gapEndFragmenId:Number = nextFdp.firstFragment;
				if(gapStartFragmentId <= fragmentId && fragmentId < gapEndFragmenId)
				{
					inGap = true;
				}
				return !inGap;
			})
			return inGap;
		}
		
		/**
		 * @return true if the fragment is time is in a true gap within the middle of the content (discontinuity type 2).
		 * returns false if time is < time of the first fragment
		 * returns false if time is >= time the last fragment
		 **/
		public function isTimeInGap(time:Number, fragmentInterval:uint):Boolean
		{
			var inGap:Boolean = false;
			forEachGap(function(opt:Object):Boolean
			{
				var fdp:FragmentDurationPair = opt.fdp as FragmentDurationPair;
				var prevFdp:FragmentDurationPair = opt.prevFdp as FragmentDurationPair;
				var nextFdp:FragmentDurationPair = opt.nextFdp as FragmentDurationPair;
				var prevEndTime:Number = prevFdp.durationAccrued + prevFdp.duration * (fdp.firstFragment - prevFdp.firstFragment);
				var nextStartTime:Number = nextFdp.durationAccrued;
				var idealGapStartTime:Number = (Math.max(fdp.firstFragment, 1)-1) * fragmentInterval;
				var idealGapEndTime:Number = (Math.max(nextFdp.firstFragment, fdp.firstFragment + 1, 1) - 1) * fragmentInterval;
				var gapStartTime:Number = Math.min(prevEndTime, idealGapStartTime);
				var gapEndTime:Number = Math.max(nextStartTime, idealGapEndTime);
				if(gapStartTime <= time && time < gapEndTime)
				{
					inGap = true;
				}
				return !inGap;
			})
			return inGap;
		}
		
		/**
		 * @private
		 * @return the number of fragments within a gap (discontinuity 2)
		 **/
		public function countGapFragments():uint
		{
			var count:uint = 0;
			forEachGap(function(opt:Object):void {
				var fdp:FragmentDurationPair = opt.fdp as FragmentDurationPair;
				var nextFdp:FragmentDurationPair = opt.nextFdp as FragmentDurationPair;
				var gapStartFragmentId:Number = fdp.firstFragment;
				var gapEndFragmentId:Number = uint(Math.max(nextFdp.firstFragment, gapStartFragmentId));
				count += gapEndFragmentId - gapStartFragmentId;
			});
			return count;
		}
		
		/**
		 * @private
		 * calls f for each true gap (discontinuity of type 2) found within the FRT. f will be passed
		 * an Object argument (arg) with 3 fields.
		 * 
		 * arg.fdp will be the discontinuity entry.
		 * arg.prevFdp will be the previous non-discontinuity entry
		 * arg.nextFdp will be the next non-discontinuity entry
		 * 
		 * if f returns false, iteration will halt
		 * if f returns true, iteration will continue
		 **/
		private function forEachGap(f:Function):void
		{
			if (_fragmentDurationPairs.length <= 0)
			{
				return;
			}
			
			// search for gaps, then check if the desired time is in that gap
			for(var i:uint = 0; i < _fragmentDurationPairs.length; ++i)
			{
				var fdp:FragmentDurationPair = _fragmentDurationPairs[i];
				
				if(fdp.duration != 0 ||
					fdp.discontinuityIndicator != 2)
				{
					// skip until we find a discontinuity of type 2
					continue;
				}
				
				// gaps should only be present in the middle of content,
				// so there should always be a previous valid entry and 
				// a next valid entry.
				
				// figure out the previous valid entry
				var prevFdp:FragmentDurationPair = findPrevValidFragmentDurationPair(i);
				if(prevFdp == null // very uncommon case: there are no non-discontinuities before the discontinuity
					|| prevFdp.firstFragment > fdp.firstFragment) // very uncommon case: fragment numbers are out of order
				{
					continue;
				}
				
				// search forwards for the first non-discontinuity
				var nextFdp:FragmentDurationPair = findNextValidFragmentDurationPair(i+1);
				if(nextFdp == null // very uncommon case: there are no valid fragments after the discontinuity
					|| fdp.firstFragment > nextFdp.firstFragment) // very uncommon case: fragment numbers are out of order
				{
					continue;
				}
				
				var shouldContinue:Boolean = f({
					fdp:fdp,
					prevFdp:prevFdp,
					nextFdp:nextFdp
				});
				if(!shouldContinue)
				{
					return;
				}
			}
		}
		
		/**
		 * @return the fragment information for the first fragment in the FRT whose fragment number
		 * is greater than or equal to fragment id. special cases:
		 *
		 *   if fragmentId is in a gap, the first fragment after the gap will be returned.
		 *   if fragmentId is in a skip, the first fragment after the skip will be returned.
		 *   if fragmentId is before the first fragment-duration-pair, the first fragment will be returned.
		 *   if fragmentId is after the last fragment-duration-pair, it will be assumed to exist.
		 *       (in other words, the live point is ignored).
		 *
		 *   if there are no valid entries in the FRT, returns null. this is the only situation that returns null.
		 **/
		public function getFragmentWithIdGreq(fragmentId:uint):FragmentAccessInformation
		{
			var desiredFdp:FragmentDurationPair = null;
			var desiredFragmentId:uint = 0;
			forEachInterval(function(opt:Object):Boolean
			{
				var fdp:FragmentDurationPair = opt.fdp as FragmentDurationPair;
				var isLast:Boolean = opt.isLast as Boolean;
				var startFragmentId:uint = opt.startFragmentId as uint;
				var endFragmentId:uint = opt.endFragmentId as uint;
				
				if(fragmentId < startFragmentId)
				{
					// before the given interval
					desiredFdp = fdp;
					desiredFragmentId = startFragmentId;
					return false; // stop iterating
				}
				else if(isLast)
				{
					// catch all in the last entry
					desiredFdp = fdp;
					desiredFragmentId = fragmentId;
					return false;
				}
				else if(fragmentId < endFragmentId)
				{
					// between the start and end of this interval
					desiredFdp = fdp;
					desiredFragmentId = fragmentId;
					return false; // stop iterating
				}
				else
				{
					// beyond this interval, but not the last entry 
					return true; // keep iterating
				}
			});
			
			if(desiredFdp == null)
			{
				// no fragment entries case
				return null;
			}
			
			if(desiredFragmentId < desiredFdp.firstFragment)
			{
				// probably won't ever hit this
				// just make sure that we're before the start 
				desiredFragmentId = desiredFdp.firstFragment;
			}
			
			var fai:FragmentAccessInformation = new FragmentAccessInformation();
			fai.fragId = desiredFragmentId;
			fai.fragDuration = desiredFdp.duration;
			fai.fragmentEndTime = desiredFdp.durationAccrued + (desiredFragmentId - desiredFdp.firstFragment + 1) * desiredFdp.duration;
			return fai;
		}
		
		
		/**
		 * @return the fragment information for the first fragment in the FRT that contains a time
		 * greater than or equal to fragment time. special cases:
		 *
		 *   if time is in a gap, the first fragment after the gap will be returned.
		 *   if time is in a skip, the first fragment after the skip will be returned.
		 *   if time is before the first fragment-duration-pair, the first fragment will be returned.
		 *   if time is after the last fragment-duration-pair, it will be assumed to exist.
		 *       (in other words, the live point is ignored).
		 *
		 *   if there are no valid entries in the FRT, returns null. this is the only situation that returns null.
		 **/
		public function getFragmentWithTimeGreq(fragmentTime:Number):FragmentAccessInformation
		{
			var desiredFdp:FragmentDurationPair = null;
			var desiredFragmentStartTime:Number = 0;
			forEachInterval(function(opt:Object):Boolean
			{
				var fdp:FragmentDurationPair = opt.fdp as FragmentDurationPair;
				var isLast:Boolean = opt.isLast as Boolean;
				var startTime:Number = opt.startTime as Number;
				var endTime:Number = opt.endTime as Number;
				
				if(fragmentTime < startTime)
				{
					// before the given interval
					desiredFdp = fdp;
					desiredFragmentStartTime = startTime;
					return false; // stop iterating
				}
				else if(isLast)
				{
					// catch all in the last entry
					desiredFdp = fdp;
					desiredFragmentStartTime = fragmentTime;
					return false;
				}
				else if(fragmentTime < endTime)
				{
					// between the start and end of this interval
					desiredFdp = fdp;
					desiredFragmentStartTime = fragmentTime;
					return false; // stop iterating
				}
				else
				{
					// beyond this interval, but not the last entry 
					return true; // keep iterating
				}
			});
			
			if(desiredFdp == null)
			{
				// no fragment entries case
				return null;
			}
			
			var desiredFragmentId:uint = calculateFragmentId(desiredFdp, desiredFragmentStartTime);
			var fai:FragmentAccessInformation = new FragmentAccessInformation();
			fai.fragId = desiredFragmentId;
			fai.fragDuration = desiredFdp.duration;
			fai.fragmentEndTime = desiredFdp.durationAccrued + (desiredFragmentId - desiredFdp.firstFragment + 1) * desiredFdp.duration;
			return fai;
		}
		
		/**
		 * @private
		 * calls f for each set of fragments advertised by the FRT. f will be passed
		 * an Object argument (arg) with 6 fields.
		 * 
		 * arg.fdp will be the entry corresponding to the fragment range.
		 * arg.isLast will be true if this is the last entry in the table
		 * arg.startFragmentId will be the id of the first fragment in the interval
		 * arg.endFragmentId will be the id of the last fragment in the interval + 1
		 * arg.startTime will be the start time of the first fragment in the interval
		 * arg.endTime will be the end time of the last fragment in the interval
		 * 
		 * if f returns false, iteration will halt
		 * if f returns true, iteration will continue
		 *
		 * f will be called in ascending startFragmentId order.
		 **/
		private function forEachInterval(f:Function):void
		{
			// search for gaps, then check if the desired time is in that gap
			for(var i:uint = 0; i < _fragmentDurationPairs.length; ++i)
			{
				var fdp:FragmentDurationPair = _fragmentDurationPairs[i];
				if(fdp.duration == 0)
				{
					// some kind of discontinuity
					continue;
				}
					
				var startFragmentId:uint = fdp.firstFragment;
				var startTime:Number = fdp.durationAccrued;
				
				// find the valid entry or the next skip, gap, or skip+gap
				var isLast:Boolean = true;
				for(var j:uint = i + 1; j < _fragmentDurationPairs.length; ++j) 
				{
					if(_fragmentDurationPairs[j].duration != 0 || // next is valid entry
						_fragmentDurationPairs[j].discontinuityIndicator == 1 || // next is skip
						_fragmentDurationPairs[j].discontinuityIndicator == 2 || // next is gap
						_fragmentDurationPairs[j].discontinuityIndicator == 3) // next is skip+gap
					{
						isLast = false;
						break;
					}
					else
					{
						// eof or some unknown kind of discontinuity
					}
				}
				
				var endFragmentId:uint;
				var endTime:Number;
				if(isLast)
				{
					// there's no next entry
					endFragmentId = 0;
					endTime = Number.NaN;
				}
				else 
				{
					endFragmentId = _fragmentDurationPairs[j].firstFragment;
					if(startFragmentId > endFragmentId) // very uncommon case: fragment numbers are out of order
					{
						continue;
					}
					endTime = startTime + (endFragmentId - startFragmentId) * fdp.duration;
				}
				
				var shouldContinue:Boolean = f({
					fdp:fdp,
					isLast:isLast,
					startFragmentId:startFragmentId,
					endFragmentId:endFragmentId,
					startTime:startTime,
					endTime:endTime
				});
				if(!shouldContinue || isLast)
				{
					return;
				}
			}
		}
		
		private var _timeScale:uint;
		private var _qualitySegmentURLModifiers:Vector.<String>;
		private var _fragmentDurationPairs:Vector.<FragmentDurationPair>;
	}
}
