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
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.Timer;
	
	import org.osmf.elements.f4mClasses.BootstrapInfo;
	import org.osmf.events.DVRStreamInfoEvent;
	import org.osmf.events.HTTPStreamingEvent;
	import org.osmf.events.HTTPStreamingEventReason;
	import org.osmf.events.HTTPStreamingFileHandlerEvent;
	import org.osmf.events.HTTPStreamingIndexHandlerEvent;
	import org.osmf.net.dvr.DVRUtils;
	import org.osmf.net.httpstreaming.HTTPStreamDownloader;
	import org.osmf.net.httpstreaming.HTTPStreamRequest;
	import org.osmf.net.httpstreaming.HTTPStreamRequestKind;
	import org.osmf.net.httpstreaming.HTTPStreamingFileHandlerBase;
	import org.osmf.net.httpstreaming.HTTPStreamingIndexHandlerBase;
	import org.osmf.net.httpstreaming.HTTPStreamingUtils;
	import org.osmf.net.httpstreaming.dvr.DVRInfo;
	import org.osmf.net.httpstreaming.flv.FLVTagScriptDataMode;
	import org.osmf.net.httpstreaming.flv.FLVTagScriptDataObject;
	import org.osmf.utils.OSMFSettings;
	import org.osmf.utils.URL;

	CONFIG::LOGGING 
	{	
		import org.osmf.logging.Logger;
	}

	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * The actual implementation of HTTPStreamingFileIndexHandlerBase.  It
	 * handles the indexing scheme of an F4V file.
	 */	
	public class HTTPStreamingF4FIndexHandler extends HTTPStreamingIndexHandlerBase
	{
		/*
		AdobePatentID="2390US01"
		*/

		/**
		 * Default Constructor.
		 *
		 * @param fileHandler The associated file handler object which is responsable for processing the actual data.
		 * 					  We need this object as it may process bootstrap information found into the stream.
		 * @param fragmentsThreshold The default threshold for fragments.   
		 */
		public function HTTPStreamingF4FIndexHandler(fileHandler:HTTPStreamingFileHandlerBase, fragmentsThreshold:uint = DEFAULT_FRAGMENTS_THRESHOLD)
		{
			super();
			
			// listen for any bootstrap box information dispatched by file handler
			fileHandler.addEventListener(HTTPStreamingFileHandlerEvent.NOTIFY_BOOTSTRAP_BOX, onBootstrapBox);
			
			_bestEffortF4FHandler.addEventListener(HTTPStreamingFileHandlerEvent.NOTIFY_BOOTSTRAP_BOX, onBestEffortF4FHandlerNotifyBootstrapBox);
		}
		
		/**
		 * @private
		 */
		override public function dvrGetStreamInfo(indexInfo:Object):void
		{
			_invokedFromDvrGetStreamInfo = true;
			playInProgress = false;
			initialize(indexInfo);
		} 
		
		/**
		 * Initializes the index handler.
		 * 
		 * @param indexInfor The index information.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		override public function initialize(indexInfo:Object):void
		{
			// Make sure we have an info object of the expected type.
			_f4fIndexInfo = indexInfo as HTTPStreamingF4FIndexInfo;
			if (_f4fIndexInfo == null || _f4fIndexInfo.streamInfos == null || _f4fIndexInfo.streamInfos.length <= 0)
			{
				CONFIG::LOGGING
				{			
					logger.error("indexInfo object wrong or contains insufficient information!");
				}
				
				dispatchEvent(new HTTPStreamingEvent(HTTPStreamingEvent.INDEX_ERROR));
				return;					
			}
			
			_indexUpdating = false;
			_pendingIndexLoads = 0;
			_pendingIndexUpdates = 0;
			_pendingIndexUrls = new Object();
			
			playInProgress = false;
			_pureLiveOffset = NaN;

			_serverBaseURL = _f4fIndexInfo.serverBaseURL;			
			_streamInfos = _f4fIndexInfo.streamInfos;

			var bootstrapBox:AdobeBootstrapBox;
			var streamCount:int = _streamInfos.length;
			
			_streamQualityRates = [];
			_streamNames = [];
			
			_bootstrapBoxesURLs = new Vector.<String>(streamCount);
			_bootstrapBoxes = new Vector.<AdobeBootstrapBox>(streamCount);
			for (var quality:int = 0; quality < streamCount; quality++)
			{
				var streamInfo:HTTPStreamingF4FStreamInfo = _streamInfos[quality];
				if (streamInfo != null)
				{
					_streamQualityRates[quality]	= streamInfo.bitrate;
					_streamNames[quality] 			= streamInfo.streamName;
					
					var bootstrap:BootstrapInfo = streamInfo.bootstrapInfo;
					
					if (bootstrap == null || (bootstrap.url == null && bootstrap.data == null))
					{
						CONFIG::LOGGING
						{			
							logger.error("Bootstrap(" + quality + ")  null or contains inadequate information!");
						}
						
						dispatchEvent(new HTTPStreamingEvent(HTTPStreamingEvent.INDEX_ERROR));
						return;					
					}
					
					if (bootstrap.data != null)
					{
						bootstrapBox = processBootstrapData(bootstrap.data, quality);
						if (bootstrapBox == null)
						{
							CONFIG::LOGGING
							{			
								logger.error("BootstrapBox(" + quality + ") is null, potentially from bad bootstrap data!");
							}
							
							dispatchEvent(new HTTPStreamingEvent(HTTPStreamingEvent.INDEX_ERROR));
							return;					
						}
						_bootstrapBoxes[quality] = bootstrapBox;
					}
					else
					{
						_bootstrapBoxesURLs[quality] 	= HTTPStreamingUtils.normalizeURL(bootstrap.url);
						
						_pendingIndexLoads++;
						dispatchIndexLoadRequest(quality);
					}
				}
			}
			
			if (_pendingIndexLoads == 0)
			{
				notifyRatesReady();
				notifyIndexReady(0);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			destroyBootstrapUpdateTimer();
			
			_pendingIndexLoads = 0;
			_pendingIndexUpdates = 0;
			_pendingIndexUrls = new Object();
			
			_bestEffortNeedsToFireFragmentDuration = false;
			_bestEffortEnabled = true;
			if (_bestEffortNotifyBootstrapBoxInfo != null && _bestEffortNotifyBootstrapBoxInfo.hasOwnProperty("downloader"))
			{
				var downloader:HTTPStreamDownloader = _bestEffortNotifyBootstrapBoxInfo.downloader as HTTPStreamDownloader;
				if (downloader != null)
				{
					downloader.close(true);
				}
			}
		}
		
		/**
		 * Called when the index file has been loaded and is ready to be processed.
		 * 
		 * @param data The data from the loaded index file.
		 * @param indexContext An arbitrary context object which describes the loaded
		 * index file.  Useful for index handlers which load multiple index files
		 * (and thus need to know which one to process).
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		override public function processIndexData(data:*, indexContext:Object):void
		{
			var quality:int = indexContext as int;
			var bootstrapBox:AdobeBootstrapBox = processBootstrapData(data, quality);

			if (bootstrapBox == null)
			{
				CONFIG::LOGGING
				{			
					logger.error("BootstrapBox(" + quality + ") is null when attempting to process index data during a bootstrap update.");
				}
				
				dispatchEvent(new HTTPStreamingEvent(HTTPStreamingEvent.INDEX_ERROR));
				return;					
			}

			if (!_indexUpdating) 
			{
				// we are processing an index initialization
				_pendingIndexLoads--;

				CONFIG::LOGGING
				{			
					logger.debug("Pending index loads: " + _pendingIndexLoads);
				}
			}
			else
			{
				// we are processing an index update
				_pendingIndexUpdates--;

				CONFIG::LOGGING
				{			
					logger.debug("Pending index updates: " + _pendingIndexUpdates);
				}

				var requestedUrl:String = _bootstrapBoxesURLs[quality];
				if (requestedUrl != null && _pendingIndexUrls.hasOwnProperty(requestedUrl))
				{
					_pendingIndexUrls[requestedUrl].active = false;
				}
				
				if (_pendingIndexUpdates == 0)
				{
					_indexUpdating = false;
					// FM-924, onMetadata is called twice on http streaming live/dvr content 
					// It is really unnecessary to call onMetadata multiple times. The change of
					// media length is fixed for VOD, and is informed by the call dispatchDVRStreamInfo
					// for DVR. For "pure live", it does not really matter. Whenever MBR switching
					// happens, onMetadata will be called by invoking checkMetadata method.
					// 
					//notifyTotalDuration(bootstrapBox.totalDuration / bootstrapBox.timeScale, indexContext as int);
				}
			}
			
			CONFIG::LOGGING
			{			
				logger.debug("BootstrapBox(" + quality + ") loaded successfully." + 
					"[version:" + bootstrapBox.bootstrapVersion + 
					", fragments from frt:" + bootstrapBox.totalFragments +
					", fragments from srt:" + bootstrapBox.segmentRunTables[0].totalFragments + "]"
				);
			}
			updateBootstrapBox(quality, bootstrapBox, true /* sourceIsIndex */);
			
			if (_pendingIndexLoads == 0 && !_indexUpdating)
			{
				notifyRatesReady();
				notifyIndexReady(quality);
			}
		}	
		
		/**
		 * Returns the HTTPStreamRequest which encapsulates the file for the given
		 * playback time and quality.  If no such file exists for the specified time
		 * or quality, then this method should return null. 
		 * 
		 * @param time The time for which to retrieve a request object.
		 * @param quality The quality of the requested stream.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.0
		 */
		override public function getFileForTime(time:Number, quality:int):HTTPStreamRequest
		{
			if (   quality < 0 
				|| quality >= _streamInfos.length 
				|| time < 0)
			{
				CONFIG::LOGGING
				{
					logger.warn("Invalid parameters for getFileForTime(time=" + time + ", quality=" + quality + ").");	
				}
				return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);
			}
			
			// best effort fetch accounting. initially assume seeks are not best effort.
			_bestEffortState = BEST_EFFORT_STATE_OFF;
			
			var bootstrapBox:AdobeBootstrapBox = _bootstrapBoxes[quality];
			if (bootstrapBox == null)
				return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);
			
			if (!playInProgress && isStopped(bootstrapBox))
			{
				destroyBootstrapUpdateTimer();
				return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);
			}
							
			updateMetadata(quality);
			
			var streamRequest:HTTPStreamRequest;
			var desiredTime:Number = time * bootstrapBox.timeScale;

			// we should know the segment and fragment containing the desired time
			if(_bestEffortEnabled)
			{
				streamRequest = getFirstRequestForBestEffortSeek(desiredTime, quality, bootstrapBox);
			}
			else
			{
				streamRequest = getSeekRequestForNormalFetch(desiredTime, quality, bootstrapBox);
			}
			
			CONFIG::LOGGING
			{
				logger.debug("The url for ( time=" + time + ", quality=" + quality + ") = " + streamRequest.toString());
			}
			
			return streamRequest;
		}
				
		/**
		 * @private
		 * 
		 * helper for getFileForTime, called when best effort fetch is disabled.
		 * 
		 * @return the action to take, expressed as an HTTPStreamRequest
		 **/
		private function getSeekRequestForNormalFetch(
			desiredTime:Number,
			quality:int,
			bootstrapBox:AdobeBootstrapBox):HTTPStreamRequest
		{
			var streamRequest:HTTPStreamRequest = null;
			var refreshNeeded:Boolean = false;
			var currentTime:Number = bootstrapBox.currentMediaTime;
			var contentComplete:Boolean = bootstrapBox.contentComplete();
			var frt:AdobeFragmentRunTable = getFragmentRunTable(bootstrapBox);
			CONFIG::LOGGING
			{
				if (contentComplete)
				{
					logger.debug("Bootstrap reports that content is complete. If this is a live stream, then the publisher stopped it.");
				}
			}
			if (desiredTime <= currentTime)
			{
				if(frt != null)
				{
					_currentFAI = frt.findFragmentIdByTime(desiredTime, currentTime, contentComplete ? false : bootstrapBox.live);
				}
				if (_currentFAI == null || fragmentOverflow(bootstrapBox, _currentFAI.fragId))
				{
					// we're beyond the end of the bootstrap
					if (!bootstrapBox.live || contentComplete)
					{
						// we're either:
						// - vod, in which case we should stop playback
						// - live/DVR, and there's a null term, meaning the content is done
						return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);
					}
					else
					{
						// we're in live and we reached the end of content, but we're not done
						return initiateLivenessFailure(quality);
					}
				}
				else
				{
					// normal case: we found the fragment we were looking for. initiate a download request
					return initiateNormalDownload(bootstrapBox, quality);
				}
			}
			else if(bootstrapBox.live)
			{
				// we are trying to seek beyond the "live" point in the live scenario
				return initiateBootstrapRefresh(quality);
			}
			else
			{
				// we are trying to seek beyond the "live" point in the vod scenario
				return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);
			}
		}
		
		/**
		 * @private
		 */
		override public function getNextFile(quality:int):HTTPStreamRequest
		{
			if (quality < 0 || quality >= _streamInfos.length)
			{
				CONFIG::LOGGING
				{
					logger.warn("Invalid parameters for getNextFile(quality=" + quality + ").");	
				}
				return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);
			}
			
			var bootstrapBox:AdobeBootstrapBox = _bootstrapBoxes[quality];
			if (bootstrapBox == null)
				return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);
			
			if (!playInProgress && isStopped(bootstrapBox))
			{
				destroyBootstrapUpdateTimer();
				return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);
			}
			
			updateMetadata(quality);
			var streamRequest:HTTPStreamRequest = null;
			
			if(_bestEffortEnabled)
			{
				// best effort case
				if(_bestEffortState == BEST_EFFORT_STATE_OFF ||
					_bestEffortState == BEST_EFFORT_STATE_PLAY)
				{
					streamRequest = getNextRequestForBestEffortPlay(quality, bootstrapBox);
				}
				else
				{
					streamRequest = getNextRequestForBestEffortSeek(quality, bootstrapBox);
				}
			}
			else
			{
				streamRequest = getNextRequestForNormalPlay(quality, bootstrapBox);
			}
			
			CONFIG::LOGGING
			{
				logger.debug("Next url for (quality=" + quality + ") = " + streamRequest.toString());
			}
			
			return streamRequest;
		}
		
		/**
		 * @private
		 * 
		 * helper for getNextFile, called when best effort fetch is disabled.
		 * 
		 * @return the action to take, expressed as an HTTPStreamRequest
		 **/
		private function getNextRequestForNormalPlay(
			quality:int,
			bootstrapBox:AdobeBootstrapBox):HTTPStreamRequest
		{
			var streamRequest:HTTPStreamRequest;
			var currentTime:Number = bootstrapBox.currentMediaTime;
			
			var contentComplete:Boolean = bootstrapBox.contentComplete();
			CONFIG::LOGGING
			{
				if (contentComplete)
				{
					logger.debug("Bootstrap reports that content is complete. If this is a live stream, then the publisher stopped it.");
				}
			}
			
			var oldCurrentFAI:FragmentAccessInformation = _currentFAI;
			var frt:AdobeFragmentRunTable = getFragmentRunTable(bootstrapBox);
			if (oldCurrentFAI == null)
			{
				_currentFAI = null;
			}
			if(frt != null)
			{
				_currentFAI = frt.validateFragment(
					oldCurrentFAI.fragId + 1, // fragId
					currentTime, // totalDuration
					contentComplete ? false : bootstrapBox.live);
			}
			if (_currentFAI == null || fragmentOverflow(bootstrapBox, _currentFAI.fragId))
			{
				// we're beyond the end of the bootstrap
				_currentFAI = oldCurrentFAI;
				if (!bootstrapBox.live || contentComplete)
				{
					// we're either:
					// - vod, in which case we should stop playback
					// - live/DVR, and there's a null term, meaning the content is done
					return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);
				}
				else
				{
					// we're in live and we reached the end of content, but we're not done
					_currentFAI = oldCurrentFAI;
					return initiateLivenessFailure(quality);
				}
			}
			else
			{
				// normal case: we found the fragment we were looking for. initiate a download request
				return initiateNormalDownload(bootstrapBox, quality);
			}
		}
		
		
		/**
		 * @private
		 * 
		 * Initiates a live failed request (from getNextFile or getFileForTime).
		 * 
		 * @return the action to take, expressed as an HTTPStreamRequest
		 **/
		private function initiateLivenessFailure(quality:int):HTTPStreamRequest
		{
			adjustDelay();
			refreshBootstrapBox(quality);
			
			var livenessDelay:Number;
			if(_bestEffortEnabled)
			{
				// after half a fragment duration the bootstrap should be updated
				// but at least a second
				livenessDelay = Math.max((_f4fIndexInfo.bestEffortFetchInfo.fragmentDuration / 2) / 1000.0, 1);
			}
			else
			{
				// otherwise, just use the default delay
				livenessDelay = _delay;
			}
			return new HTTPStreamRequest(
				HTTPStreamRequestKind.LIVE_STALL,
				null, // url
				livenessDelay); // retryAfter
		}
		
		/**
		 * @private
		 * 
		 * Initiates a refresh request (from getNextFile or getFileForTime).
		 * 
		 * @return the action to take, expressed as an HTTPStreamRequest
		 **/
		private function initiateBootstrapRefresh(quality:int):HTTPStreamRequest
		{
			adjustDelay();
			refreshBootstrapBox(quality);
			return new HTTPStreamRequest(
				HTTPStreamRequestKind.RETRY,
				null, // url
				_delay); // retryAfter
		}
		
		/**
		 * @private
		 * 
		 * Initiates a normal download request (from getNextFile or getFileForTime).
		 * 
		 * @return the action to take, expressed as an HTTPStreamRequest
		 **/
		private function initiateNormalDownload(bootstrapBox:AdobeBootstrapBox, quality:int):HTTPStreamRequest
		{
			// if we had a pending BEF download, invalidate it
			stopListeningToBestEffortDownload();

			// if we encounter liveness in the future, restart BEFs
			// after the current fragment
			_bestEffortLivenessRestartPoint = _currentFAI.fragId;
			CONFIG::LOGGING
			{
				logger.debug("Setting _bestEffortLivenessRestartPoint to "+_bestEffortLivenessRestartPoint+" because of normal download.");
			}
			
			// remember that we started a download now
			_bestEffortLastGoodFragmentDownloadTime = new Date();
			
			playInProgress = true;
			updateQuality(quality);
			notifyFragmentDuration(_currentFAI.fragDuration / bootstrapBox.timeScale);
			return new HTTPStreamRequest(
				HTTPStreamRequestKind.DOWNLOAD,
				getFragmentUrl(quality, _currentFAI)); // url
		}
		
		/**
		 * Checks if specified fragment identifier overflows the actual 
		 * fragments contained into the bootstrap.
		 * 
		 * @param  bootstrapBox The bootstrap which contains the fragment run table.
		 * @param fragId Specified fragment identifier which must be checked.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.0
		 */
		private function fragmentOverflow(bootstrapBox:AdobeBootstrapBox, fragId:uint):Boolean
		{
			var fragmentRunTable:AdobeFragmentRunTable = bootstrapBox.fragmentRunTables[0];
			var fdp:FragmentDurationPair = fragmentRunTable.fragmentDurationPairs[0];
			var segmentRunTable:AdobeSegmentRunTable = bootstrapBox.segmentRunTables[0];
			return ((segmentRunTable == null) || ((segmentRunTable.totalFragments + fdp.firstFragment - 1) < fragId));
		}

		/**
		 * Checks if there is no more data available for a specified
		 * bootstrap and if we should stop playback.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.0
		 */
		private function isStopped(bootstrapBox:AdobeBootstrapBox):Boolean
		{
			var result:Boolean = false;
			
			if (_f4fIndexInfo.dvrInfo != null)
			{
				// in DVR scenario, the content is considered stopped once the dvr 
				// data is taken offline
				result = _f4fIndexInfo.dvrInfo.offline;
			}
			else if (bootstrapBox != null && bootstrapBox.live)
			{
				// in pure live, the content is considered stopped once the 
				// fragment run table reports complete flag is set
				var frt:AdobeFragmentRunTable = getFragmentRunTable(bootstrapBox);
				if (frt != null)
				{
					result = frt.tableComplete();
				}
			}
						
			return result;
		}
		
		/**
		 * Gets the url for specified fragment and quality.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		private function getFragmentUrl(quality:int, fragment:FragmentAccessInformation):String
		{
			var bootstrapBox:AdobeBootstrapBox = _bootstrapBoxes[quality];
			var frt:AdobeFragmentRunTable = getFragmentRunTable(bootstrapBox);
			var fdp:FragmentDurationPair = frt.fragmentDurationPairs[0];
			var segId:uint = bootstrapBox.findSegmentId(fragment.fragId - fdp.firstFragment + 1);
			
			return constructFragmentRequest(_serverBaseURL, _streamNames[quality], segId, fragment.fragId);
		}
		
		/**
		 * Constructs the url for specified parameters.
		 * 		  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		protected function constructFragmentRequest(serverBaseURL:String, streamName:String, segmentId:uint, fragmentId:uint):String
		{
			var requestUrl:String = "";
			if (streamName != null && streamName.indexOf("http") != 0)
			{
				requestUrl = serverBaseURL + "/" ;
			}
			requestUrl += streamName;
			
			var tempURL:URL = new URL(requestUrl);
			tempURL.path += "Seg" + segmentId + "-Frag" + fragmentId;
			
			requestUrl = tempURL.protocol + "://" + tempURL.host;
			if (tempURL.port != null && tempURL.port.length > 0)
			{
				requestUrl += ":" + tempURL.port;
			}
			requestUrl += "/" + tempURL.path;
			if (tempURL.query != null && tempURL.query.length > 0)
			{
				requestUrl += "?" + tempURL.query;
			}
			if (tempURL.fragment != null && tempURL.fragment.length > 0)
			{
				requestUrl += "#" + tempURL.fragment;
			}
			
			return requestUrl;
		}
		
		/**
		 * Returns the fragment run table from the specified bootstrap box.
		 * It assumes that there is only one fragment run table.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.0
		 */
		private function getFragmentRunTable(bootstrapBox:AdobeBootstrapBox):AdobeFragmentRunTable
		{
			if (bootstrapBox == null)
				return null;
			
			return bootstrapBox.fragmentRunTables[0];
		}

		/**
		 * Adjusts the delay for future inquires from clients.
		 * When the index handler needs more time to obtain data in order to
		 * respond to a request from its clients, it will return a response 
		 * requesting more time. This method varies the delay.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		private function adjustDelay():void
		{
			if (_delay < 1.0)
			{
				_delay = _delay * 2.0;
				if (_delay > 1.0)
				{
					_delay = 1.0;
				} 
			}
		}

		/**
		 * Issues a request for refreshing the specified quality bootstrap.
		 *
		 * @param quality Quality level for which a refresh should be requested.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.0
		 */
		private function refreshBootstrapBox(quality:uint):void
		{
			var requestedUrl:String = _bootstrapBoxesURLs[quality];
			if (requestedUrl == null)
				return;
			
			var pendingIndexUrl:Object = null;
			if (_pendingIndexUrls.hasOwnProperty(requestedUrl))
			{
				pendingIndexUrl = _pendingIndexUrls[requestedUrl];
			}
			else
			{
				pendingIndexUrl = new Object();
				pendingIndexUrl["active"] = false;
				pendingIndexUrl["date"] = null;
				_pendingIndexUrls[requestedUrl] = pendingIndexUrl;
			}

			var ignoreRefreshRequest:Boolean = pendingIndexUrl.active;
			var newRequestDate:Date = new Date();
			var elapsedTime:Number = 0;
			
			if (!ignoreRefreshRequest && OSMFSettings.hdsMinimumBootstrapRefreshInterval > 0)
			{
				var previousRequestDate:Date = pendingIndexUrl["date"];
				elapsedTime = Number.MAX_VALUE;
				if (previousRequestDate != null)
				{
					elapsedTime = newRequestDate.valueOf() - previousRequestDate.valueOf();
				}
				
				ignoreRefreshRequest = elapsedTime < OSMFSettings.hdsMinimumBootstrapRefreshInterval;
			}
			
			if (!ignoreRefreshRequest)
			{
				_pendingIndexUrls[requestedUrl].date = newRequestDate;
				_pendingIndexUrls[requestedUrl].active = true;
				_pendingIndexUpdates++;
				_indexUpdating = true;
				
				CONFIG::LOGGING
				{
					logger.debug("Refresh (quality=" + quality + ") using " + requestedUrl + ". [active=" + pendingIndexUrl.active + ", elapsedTime=" + elapsedTime.toFixed(2) + "]");
				}
				
				dispatchIndexLoadRequest(quality);
			}
			else
			{
				CONFIG::LOGGING
				{
					logger.debug("Refresh (quality=" + quality + ") ignored. [active=" + pendingIndexUrl.active + ", elapsedTime=" + elapsedTime.toFixed(2) + "]");
				}
			}
		}

		/**
		 * Updates the specified bootstrap box if the specified information
		 * is newer than the current one. If the updated box if the current one, 
		 * it also refreshes the associated DVR information.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		private function updateBootstrapBox(
			quality:int, 
			bootstrapBox:AdobeBootstrapBox,
			sourceIsIndex:Boolean):void
		{
			
			if (shouldAcceptBootstrapBox(quality, bootstrapBox, sourceIsIndex))
			{
				CONFIG::LOGGING
				{
					logger.debug("Bootstrap information for quality[" + quality + "] updated. ("
						+ ", live=" + bootstrapBox.live
						+ ", time=" + bootstrapBox.currentMediaTime
						+ ", first="+ bootstrapBox.fragmentRunTables[0].firstFragmentId
						+ ", gapCount="+ bootstrapBox.fragmentRunTables[0].countGapFragments()
						+ ", done="+ bootstrapBox.contentComplete() +")");
				}
				_bootstrapBoxes[quality] = bootstrapBox;
				_delay = 0.05;
				if (quality == _currentQuality)
				{
					dispatchDVRStreamInfo(bootstrapBox);
				}
			}
		}
		
		/**
		 * @return true if the specified bootstrap should be accepted over the existing bootstrap
		 */
		private function shouldAcceptBootstrapBox(quality:int,
												  newBootstrap:AdobeBootstrapBox,
												  sourceIsIndex:Boolean):Boolean
		{
			var existingBootstrap:AdobeBootstrapBox = _bootstrapBoxes[quality];
			if(newBootstrap == null ||
				newBootstrap.fragmentRunTables.length == 0 ||
				newBootstrap.segmentRunTables.length == 0)
			{
				// reject invalid
				return false;
			}
			var newFrt:AdobeFragmentRunTable = newBootstrap.fragmentRunTables[0];
			var newSrt:AdobeSegmentRunTable = newBootstrap.segmentRunTables[0];
			if(newFrt == null || newSrt == null)
			{
				// reject invalid
				return false;
			}
			if(newFrt.firstFragmentId == 0)
			{
				// don't accept bootstraps that have no valid entries
				return false;
			}
			if(existingBootstrap == null)
			{
				// accept if we don't have a bootstrap yet
				return true;
			}
			if(existingBootstrap.live != newBootstrap.live)
			{
				// bootstrap went from live to vod or vod to live
				// this is not good. reject the bootstrap.
				return false;
			}
			if(!existingBootstrap.live)
			{
				// VOD
				
				// accept newer bootstrap if the version is newer
				if(newBootstrap.version != existingBootstrap.version)
				{
					return newBootstrap.version > existingBootstrap.version;
				}
				
				// tie breaker is the media time
				return newBootstrap.currentMediaTime > existingBootstrap.currentMediaTime;
			}
			else
			{
				// LIVE
				
				if(!sourceIsIndex)
				{
					// do not accept bootstraps that are internal to the fragment since they lie.
					return false;
				}
			
				// historical note: we do not use the version anymore. with multiple packagers,
				// the version can become out of sync when there are discontinuities. fixing
				// this would require synchronization across packagers of bootstrap version which
				// would be done by deriving version from the common clock (currentMediaTime). thus
				// it makes sense to accept changes based on currentMediaTime instead and ignore
				// the version.
				
				var existingFrt:AdobeFragmentRunTable = existingBootstrap.fragmentRunTables[0];
				var existingSrt:AdobeSegmentRunTable = existingBootstrap.segmentRunTables[0];
				
				if(newBootstrap.currentMediaTime != existingBootstrap.currentMediaTime)
				{
					// prefer newer bootstraps
					return newBootstrap.currentMediaTime > existingBootstrap.currentMediaTime;
				}
				
				if(newFrt.firstFragmentId != existingFrt.firstFragmentId)
				{
					// prefer bootstraps with an earlier starting point
					return newFrt.firstFragmentId < existingFrt.firstFragmentId;
				}
				
				var newGapCount:uint = newFrt.countGapFragments();
				var existingGapCount:uint = existingFrt.countGapFragments();
				if(newGapCount != existingGapCount)
				{
					// prefer bootstraps with fewer gap fragments
					return newGapCount < existingGapCount;
				}
				
				if(newBootstrap.contentComplete() && !existingBootstrap.contentComplete())
				{
					// prefer done bootstraps
					return true;
				}
				
				// otherwise reject bootstraps
				return false;
			}
		}
		
		/**
		 * Processes bootstrap raw information and returns an AdobeBootstrapBox object.
		 * 
		 * @param data The raw representation of bootstrap.
		 * @param indexContext The index context used while processing bootstrap.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		private function processBootstrapData(data:*, indexContext:Object):AdobeBootstrapBox
		{
			var parser:BoxParser = new BoxParser();
			data.position = 0;
			parser.init(data);
			try
			{
				var boxes:Vector.<Box> = parser.getBoxes();
			}
			catch (e:Error)
			{
				boxes = null;
			}
			
			if (boxes == null || boxes.length < 1)
			{
				return null;
			}
			
			var bootstrapBox:AdobeBootstrapBox = boxes[0] as AdobeBootstrapBox;
			if (bootstrapBox == null)
			{
				return null;
			}
			
			if (_serverBaseURL == null || _serverBaseURL.length <= 0)
			{
				if (bootstrapBox.serverBaseURLs == null || bootstrapBox.serverBaseURLs.length <= 0)
				{
					// If serverBaseURL is not set from the external, we need to pick 
					// a server base URL from the bootstrap box. For now, we just
					// pick the first one. It is an error if the server base URL is null 
					// under this circumstance.
					return null;
				}
				
				_serverBaseURL = bootstrapBox.serverBaseURLs[0];
			}
			
			return bootstrapBox;
		}	

		/**
		 * Updates the current quality index. 
		 * 
		 * Also in MBR scenarios with protected content we need to append the additionalHeader 
		 * that contains the DRM metadata to the Flash Player for that fragment before any 
		 * additional TCMessage.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		private function updateQuality(quality:int):void
		{
			if (quality != _currentQuality)
			{
				// we preserve this for later comparison
				var prevAdditionalHeader:ByteArray = _currentAdditionalHeader;
				var newAdditionalHeader:ByteArray = _streamInfos[quality].additionalHeader;

				CONFIG::LOGGING
				{
					logger.debug("Quality changed from " + _currentQuality + " to " +  quality + ".");
				}
				_currentQuality = quality;
				_currentAdditionalHeader = newAdditionalHeader;
				
				// We compare the two DRM headers and if they are different we inject
				// the new one as script data into the underlying objects.
				// Strictly speaking, the != comparison of additional header is not enough. 
				// Ideally, we need to do bytewise comparison, however there might be a performance
				// hit considering the size of the additional header.
				if (newAdditionalHeader != null && newAdditionalHeader != prevAdditionalHeader)
				{
					CONFIG::LOGGING
					{
						logger.debug("Update of DRM header is required.");
					}
					dispatchAdditionalHeader(newAdditionalHeader);
				}
			}
		}

		/**
		 * Updates the metadata for the current quality.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		private function updateMetadata(quality:int):void
		{
			if (quality != _currentQuality)
			{
                var bootstrapBox:AdobeBootstrapBox = _bootstrapBoxes[quality];
				if (bootstrapBox != null)
				{
                    //#136 when we are streaming live and not in dvr mode set the duration to zero.
					notifyTotalDuration(bootstrapBox.live && !_f4fIndexInfo.dvrInfo ? 0 : bootstrapBox.totalDuration / bootstrapBox.timeScale, quality);
				}
			}
		}

		/**
		 * Dispatches the protected content header.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		private function dispatchAdditionalHeader(additionalHeader:ByteArray):void
		{
			var flvTag:FLVTagScriptDataObject = new FLVTagScriptDataObject();
			flvTag.data = additionalHeader;
			
			dispatchEvent(
				new HTTPStreamingEvent(
					HTTPStreamingEvent.SCRIPT_DATA
					, false
					, false
					, 0
					, flvTag
					, FLVTagScriptDataMode.FIRST
				)
			);
		}
		
		/**
		 * Dispatches the DVR information extracted from the specified bootstrap.
		 *  
		 * @param bootstrapBox The bootstrap box containing the DVR information.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		private function dispatchDVRStreamInfo(bootstrapBox:AdobeBootstrapBox):void
		{
			var frt:AdobeFragmentRunTable = getFragmentRunTable(bootstrapBox);
			
			var dvrInfo:DVRInfo = _f4fIndexInfo.dvrInfo;
			if (dvrInfo != null)
			{
				// update recording status from fragment runt table
				dvrInfo.isRecording = !frt.tableComplete();
				
				// calculate current duration
				var currentDuration:Number = bootstrapBox.totalDuration/bootstrapBox.timeScale;
				var currentTime:Number = bootstrapBox.currentMediaTime/bootstrapBox.timeScale;
				
				// update start time for the first time
				if (isNaN(dvrInfo.startTime))
				{
					if (!dvrInfo.isRecording)
					{
						dvrInfo.startTime = 0;
					}
					else
					{
						var beginOffset:Number = ((dvrInfo.beginOffset < 0) || isNaN(dvrInfo.beginOffset)) ? 0 : dvrInfo.beginOffset;
						var endOffset:Number = ((dvrInfo.endOffset < 0) || isNaN(dvrInfo.endOffset))? 0 : dvrInfo.endOffset;
						
						dvrInfo.startTime = DVRUtils.calculateOffset(beginOffset, endOffset, currentDuration);  
					}
					
					dvrInfo.startTime += (frt.fragmentDurationPairs)[0].durationAccrued/bootstrapBox.timeScale;
					if (dvrInfo.startTime > currentTime)
					{
						dvrInfo.startTime = currentTime;
					}
				}
				
				// update current length of the DVR window 
				dvrInfo.curLength = currentTime - dvrInfo.startTime;	
				
				// adjust the start time if we have a DVR rooling window active
				if ((dvrInfo.windowDuration != -1) && (dvrInfo.curLength > dvrInfo.windowDuration))
				{
					dvrInfo.startTime += dvrInfo.curLength - dvrInfo.windowDuration;
					dvrInfo.curLength = dvrInfo.windowDuration;
				}
				
				dispatchEvent(
					new DVRStreamInfoEvent(
						DVRStreamInfoEvent.DVRSTREAMINFO, 
						false, 
						false, 
						dvrInfo
					)
				); 								
			}	
		}

		
		/**
		 * Dispatches an event requesting loading/refreshing of the specified quality.
		 * 
		 * @param quality The quality level for which the request should be made.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		private function dispatchIndexLoadRequest(quality:int):void
		{
			dispatchEvent(
				new HTTPStreamingIndexHandlerEvent( 
					HTTPStreamingIndexHandlerEvent.REQUEST_LOAD_INDEX 
					, false
					, false
					, false
					, NaN
					, null
					, null
					, new URLRequest(_bootstrapBoxesURLs[quality])
					, quality
					, true
				)
			);
		}
		
		/**
		 * Notifies clients that rates are ready.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		private function notifyRatesReady():void
		{
			dispatchEvent( 
				new HTTPStreamingIndexHandlerEvent( 
					HTTPStreamingIndexHandlerEvent.RATES_READY
					, false
					, false
					, false
					, NaN
					, _streamNames
					, _streamQualityRates
				)
			);
		}
		
		/**
		 * Notifies clients that index is ready.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		private function notifyIndexReady(quality:int):void
		{
			var bootstrapBox:AdobeBootstrapBox = _bootstrapBoxes[quality];
			var frt:AdobeFragmentRunTable = getFragmentRunTable(bootstrapBox);
			
			if(!_bestEffortInited)
			{
				// initialize _bestEffortEnabled
				// best effort is only enabled if
				// - enabled in the f4m
				// - the stream is live (the first bootstrap is marked as live)
				// this codepath is executed via DVRGetStreamInfo
				// after the first bootstrap fetch, but
				// before the load state is ready.
				_bestEffortEnabled =_f4fIndexInfo.bestEffortFetchInfo != null && bootstrapBox.live;
				_bestEffortInited = true;
			}
			
			dispatchDVRStreamInfo(bootstrapBox);
			
			if (!_invokedFromDvrGetStreamInfo)
			{
				// in pure live scenario, update the "closest" position to live we want
				if (bootstrapBox.live && _f4fIndexInfo.dvrInfo == null && isNaN(_pureLiveOffset))
				{
					_pureLiveOffset = bootstrapBox.currentMediaTime - OSMFSettings.hdsPureLiveOffset * bootstrapBox.timeScale;
					if (_pureLiveOffset < 0)
					{
						_pureLiveOffset = NaN;
					}
					else
					{
						_pureLiveOffset = _pureLiveOffset / bootstrapBox.timeScale;
					}
				}
				
				// If the stream is live, initialize the bootstrap update timer
				// if we are in a live stream with rolling window feature activated
				if (bootstrapBox.live && _f4fIndexInfo.dvrInfo != null)
				{
					initializeBootstrapUpdateTimer();
				}
				
				if (frt.tableComplete())
				{
					// Destroy the timer if the stream is no longer recording
					destroyBootstrapUpdateTimer();
				}
				
				dispatchEvent(
					new HTTPStreamingIndexHandlerEvent(
						HTTPStreamingIndexHandlerEvent.INDEX_READY
						, false
						, false
						, bootstrapBox.live
						, _pureLiveOffset 
					)
				);
			}
			_invokedFromDvrGetStreamInfo = false;
		}

		/**
		 * Notifies clients that total duration is available through onMetadata message.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.0
		 */
		private function notifyTotalDuration(duration:Number, quality:int):void
		{
			var metaInfo:Object = _streamInfos[quality].streamMetadata;
			if (metaInfo == null)
			{
				metaInfo = new Object();
			}


			metaInfo.duration = duration;
			
			var sdo:FLVTagScriptDataObject = new FLVTagScriptDataObject();
			sdo.objects = ["onMetaData", metaInfo];
			dispatchEvent(
				new HTTPStreamingEvent(
					HTTPStreamingEvent.SCRIPT_DATA
					, false
					, false
					, 0
					, sdo
					, FLVTagScriptDataMode.IMMEDIATE
				)
			);
		}

		/**
		 * Notifies clients that total duration is available through onMetadata message.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.0
		 */
		private function notifyFragmentDuration(duration:Number):void
		{
			// Update the bootstrap update interval; we set its value to the fragment duration
			bootstrapUpdateInterval = duration * 1000;
			if (bootstrapUpdateInterval < OSMFSettings.hdsMinimumBootstrapRefreshInterval)
			{
				bootstrapUpdateInterval = OSMFSettings.hdsMinimumBootstrapRefreshInterval;
			}
			
			dispatchEvent(
				new HTTPStreamingEvent( 
					HTTPStreamingEvent.FRAGMENT_DURATION 
					, false
					, false
					, duration
					, null
					, null
				)
			);				
		}

		private function initializeBootstrapUpdateTimer():void
		{
			if (bootstrapUpdateTimer == null)
			{
				// This will regularly update the bootstrap information;
				// We just initialize the timer here; we'll start it in the first call of the getFileForTime method
				// or in the first call of getNextFile
				// The initial delay is 4000 (recommended fragment duration)
				bootstrapUpdateTimer = new Timer(bootstrapUpdateInterval);
				bootstrapUpdateTimer.addEventListener(TimerEvent.TIMER, onBootstrapUpdateTimer);
				bootstrapUpdateTimer.start();
			}
		}
		
		private function destroyBootstrapUpdateTimer():void
		{
			if (bootstrapUpdateTimer != null)
			{
				bootstrapUpdateTimer.removeEventListener(TimerEvent.TIMER, onBootstrapUpdateTimer);
				bootstrapUpdateTimer = null;
			}
		}

		/// Event handlers
		/**
		 * Handler called when bootstrap information is available from external objects
		 * (for exemple: the stream packager can insert bootstrap information into
		 * the stream itself, and this information is processed by file handler).
		 * 
		 * We will use it to update the bootstrap information for current quality.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */ 
		private function onBootstrapBox(event:HTTPStreamingFileHandlerEvent):void
		{
			CONFIG::LOGGING
			{
				logger.debug("Bootstrap box inside media stream found. Trying to update the bootstrap");
			}
			updateBootstrapBox(_currentQuality, event.bootstrapBox, false /* sourceIsIndex */);			
			
			// for best effort fetches, we will trigger the FRAGMENT_DURATION event after we finish the download.
			notifyFragmentDurationForBestEffort(event.bootstrapBox);
		}
		
		private function onBootstrapUpdateTimer(event:TimerEvent):void
		{ 
			if (_currentQuality != -1)
			{
				refreshBootstrapBox(_currentQuality);
				bootstrapUpdateTimer.delay = bootstrapUpdateInterval;
			}
		}
		
		/**
		 * @private
		 * 
		 * helper for getFileForTime, called when best effort fetch is enabled.
		 * 
		 * @return the action to take, expressed as an HTTPStreamRequest
		 **/
		private function getFirstRequestForBestEffortSeek(
			desiredTime:Number,
			quality:int,
			bootstrapBox:AdobeBootstrapBox):HTTPStreamRequest
		{
			bestEffortLog("Initiating best effort seek "+desiredTime);
			
			_bestEffortState = BEST_EFFORT_STATE_SEEK_BACKWARD;
			_bestEffortSeekTime = desiredTime;
			_bestEffortFailedFetches = 0;
			_bestEffortLastGoodFragmentDownloadTime = null;

			return getNextRequestForBestEffortSeek(quality, bootstrapBox);
		}
		
		/**
		 * @private
		 * 
		 * helper. called when best effort fetch is enabled during the initial seek
		 * (getFileForTime) as well as in subsequent iterations (getNextFile).
		 * 
		 * @return the action to take, expressed as an HTTPStreamRequest
		 **/
		private function getNextRequestForBestEffortSeek(
			quality:int,
			bootstrapBox:AdobeBootstrapBox):HTTPStreamRequest
		{
			var frt:AdobeFragmentRunTable = getFragmentRunTable(bootstrapBox);
			if(frt == null)
			{
				// rare case: there were no fragment run table entries
				bestEffortLog("Best effort done because the bootstrap box was invalid");
				return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);
			}
			
			// if we had a pending BEF download, invalidate it
			stopListeningToBestEffortDownload();
			
			_currentFAI = null;
			
			var bestEffortSeekResult:uint = doBestEffortSeek(bootstrapBox, frt);
			if(bestEffortSeekResult != 0)
			{
				// doing best effort
				// initialize stuff related to reading the f4f
				bestEffortLog("Best effort seek fetch for fragment "+bestEffortSeekResult);
				_bestEffortF4FHandler.beginProcessFile(true, _bestEffortSeekTime);
				_bestEffortSeekBuffer.length = 0;
				_bestEffortSeekBuffer.position = 0;
				return initiateBestEffortRequest(bestEffortSeekResult, quality);
			}
			else
			{
				// revert to normal fetch, usually because
				// - the desired time is present in the FRT.
				// - we're seeking to a time >= currentMediaTime (this occurs when
				//   when we're initially playing a live stream with no live offset.)
				// - or, all best effort fetches failed
				//
				// we are not calling findFragmentIdByTime here because there are edge cases
				// where findFragmentIdByTime will return null or invalid results. instead,
				// use the well-defined getFragmentWithTimeGreq.
				_bestEffortState = BEST_EFFORT_STATE_OFF;
				_currentFAI = frt.getFragmentWithTimeGreq(_bestEffortSeekTime);
				if (_currentFAI == null)
				{
					// we didn't find the time in the FRT.
					// this is usually because we're seeking to a time >= currentMediaTime,
					// or there are no FRT entries (rare).
					// in any case, initiate playback from the specified time.
					bestEffortLog("Best effort done because there were no bootstrap entries");
					_bestEffortState = BEST_EFFORT_STATE_OFF;
					_bestEffortLivenessRestartPoint = Math.max(guessFragmentIdForTime(_bestEffortSeekTime), 1) - 1; 
					_currentFAI = new FragmentAccessInformation();
					_currentFAI.fragId = _bestEffortLivenessRestartPoint;
					return getNextFile(quality);
				}
				else
				{
					// normal case. we found something, play it out.
					bestEffortLog("Normal seek request for fragment "+_currentFAI.fragId);
					return initiateNormalDownload(bootstrapBox, quality);
				}
			}
		}
		
		/**
		 * @private
		 * 
		 * @return the expected fragment number for the desired seek time
		 **/
		private function guessFragmentIdForTime(time:Number):uint
		{
			return uint(Math.floor(time / _f4fIndexInfo.bestEffortFetchInfo.fragmentDuration)) + 1;
		}
		
		/**
		 * @private
		 * 
		 * helper for getNextRequestForBestEffortSeek. figures out the next fragment number to best-effort-fetch for the current seek.
		 * 
		 * @return the fragment number to best effort fetch, or 0 to revert to normal fetch
		 **/
		private function doBestEffortSeek(
			bootstrapBox:AdobeBootstrapBox,
			frt:AdobeFragmentRunTable):uint
		{
			if(_bestEffortSeekTime >= bootstrapBox.currentMediaTime)
			{
				// don't do best effort if we're looking for a future time
				bestEffortLog("Seek time greter than current media time.");
				return 0;
			}

			if(!frt.isTimeInGap(_bestEffortSeekTime, _f4fIndexInfo.bestEffortFetchInfo.fragmentDuration))
			{
				// don't do best effort if the time is present in the frt
				bestEffortLog("Found seek time in FRT");
				return 0;
			}

			var firstFragment:FragmentAccessInformation = frt.getFragmentWithIdGreq(0);
			if(firstFragment != null)
			{
				// don't do best effort if we're looking for a time before the first bootstrap entry
				var firstFragmentStartTime:Number = firstFragment.fragmentEndTime - firstFragment.fragDuration;
				if(_bestEffortSeekTime < firstFragmentStartTime)
				{
					bestEffortLog("Seek time before first bootstrap entry time.");
					return 0;
				}
			}

			if(_bestEffortState == BEST_EFFORT_STATE_SEEK_BACKWARD)
			{
				var backwardSeekResult:uint = doBestEffortSeekBackward(frt);
				if(backwardSeekResult != 0)
				{
					return backwardSeekResult;
				}
				else
				{
					// backward seek failed
					_bestEffortState = BEST_EFFORT_STATE_SEEK_FORWARD;
					_bestEffortFailedFetches = 0;
				}
			}
			// _bestEffortState == BEST_EFFORT_STATE_SEEK_FORWARD
			var forwardSeekResult:uint = doBestEffortSeekForward(frt);
			if(forwardSeekResult != 0)
			{
				return forwardSeekResult;
			}
			else
			{
				// forward seek failed
				return 0;
			}
		}
		
		/**
		 * @private
		 * 
		 * helper for doBestEffortSeek. figures out the next fragment number to best-effort-fetch for the current seek
		 * while in backward fetch state.
		 * 
		 * @return the fragment number to best effort fetch, or 0 if we should not perform backward fetch.
		 **/
		private function doBestEffortSeekBackward(frt:AdobeFragmentRunTable):uint
		{
			// guess a fragment number for _bestEffortSeekTime
			if(_bestEffortFailedFetches >= _f4fIndexInfo.bestEffortFetchInfo.maxBackwardFetches)
			{
				// we exhausted all our best effort backward fetches. move to forwards search.
				bestEffortLog("Best effort seek backward failing due to too many failures");
				return 0;
			}
			var guessFragmentId:uint = guessFragmentIdForTime(_bestEffortSeekTime);
			if(guessFragmentId <= _bestEffortFailedFetches + 1)
			{
				// going backwards would hit fragment number 0
				bestEffortLog("Best effort seek backward hit fragment 0");
				return 0;
			}
			var nextFragmentId:uint = guessFragmentId - (_bestEffortFailedFetches + 1);
					
			// search the fragment run table to see if the desired fragment is already available
			if(!frt.isFragmentInGap(nextFragmentId))
			{
				// special case: the fragment we were going to request already exists in
				// the fragment run table, and already know from our findFragmentIdByTime
				// call that it doesn't contain the desired time. move to forwards search.
				bestEffortLog("Best effort seek backward hit an existing fragment "+nextFragmentId);
				return 0;
			}
			
			bestEffortLog("Best effort seek backward fetch "+nextFragmentId);
			return nextFragmentId; // true because this is a best effort fetch
		}
		
		/**
		 * @private
		 * 
		 * helper for doBestEffortSeek. figures out the next fragment number to best-effort-fetch for the current seek
		 * while in forward fetch state.
		 * 
		 * @return the fragment number to best effort fetch, or 0 if we should not perform forward fetch.
		 **/
		private function doBestEffortSeekForward(frt:AdobeFragmentRunTable):uint
		{
			if (_bestEffortFailedFetches >= _f4fIndexInfo.bestEffortFetchInfo.maxForwardFetches)
			{
				// all best effort fetches failed.
				// give up and just perform a normal seek.
				bestEffortLog("Best effort seek failing due to too many failures");
				return 0;
			}
			var nextFragmentId:uint = guessFragmentIdForTime(_bestEffortSeekTime) + _bestEffortFailedFetches;
			
			// search the fragment run table to see if the desired fragment is already available
			if(!frt.isFragmentInGap(nextFragmentId))
			{
				// special case: the fragment we were going to request already exists in
				// the fragment run table. just use that fragment.
				bestEffortLog("Best effort seek forward hit an existing fragment "+nextFragmentId);
				return 0;
			}
				
			// normal case: perform a best effort forward fetch
			bestEffortLog("Best effort seek forward fetch "+nextFragmentId);
			return nextFragmentId; // true because this is a best effort fetch
		}
		
		/**
		 * @private
		 * 
		 * helper for getNextFile. called when best effort fetch is enabled
		 * but we're not seeking.
		 * 
		 * @return the action to take, expressed as an HTTPStreamRequest
		 **/
		private function getNextRequestForBestEffortPlay(
			quality:int, 
			bootstrapBox:AdobeBootstrapBox):HTTPStreamRequest
		{
			// parse out the FRT and SRT
			var frt:AdobeFragmentRunTable = getFragmentRunTable(bootstrapBox);
			if(_currentFAI == null ||
				frt == null ||
				bootstrapBox == null ||
				bootstrapBox.segmentRunTables.length < 1 ||
				bootstrapBox.segmentRunTables[0].segmentFragmentPairs.length < 1)
			{
				// rare case #1: _currentFAI shouldn't ever be null.
				// rare case #2: FRT was invalid
				// rare case #3: SRT was invalid
				bestEffortLog("Best effort in a weird state.");
				return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);
			}
			var srt:AdobeSegmentRunTable = bootstrapBox.segmentRunTables[0];
			
			// figure out the next fragment to fetch
			var nextFragmentId : uint = _currentFAI.fragId + 1;
			
			// figure out the live point. the SRT is the best source for
			// how many fragments are available. this is roughly equivalent to the
			// check happening in fragmentOverflow
			var firstFragmentId:uint = frt.firstFragmentId;
			if(firstFragmentId == 0)
			{
				// rare case: FRT didn't contain any valid entries
				bestEffortLog("Best effort in a weird state.");
				return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);
			}
			var livePoint : uint = firstFragmentId + srt.totalFragments;
			
			// figure out what kind of situation we're in
			// liveness, dropout, done, or normal
			var situation:String;
			if(nextFragmentId >= livePoint)
			{
				if(bootstrapBox.contentComplete())
				{
					situation = BEST_EFFORT_PLAY_SITUAUTION_DONE;
				}
				else
				{
					situation = BEST_EFFORT_PLAY_SITUAUTION_LIVENESS;
				}
			}
			else
			{
				if(frt.isFragmentInGap(nextFragmentId))
				{
					situation = BEST_EFFORT_PLAY_SITUAUTION_DROPOUT;
				}
				else
				{ 
					situation = BEST_EFFORT_PLAY_SITUAUTION_NORMAL; 
				}
			}
			
			if(situation == BEST_EFFORT_PLAY_SITUAUTION_DROPOUT ||
				situation == BEST_EFFORT_PLAY_SITUAUTION_LIVENESS)
			{
				// try to do BEF, we can still bail if there were too many failures.
				
				bestEffortLog("Best effort in "+situation);
				
				if(situation == BEST_EFFORT_PLAY_SITUAUTION_LIVENESS &&
					_bestEffortLastGoodFragmentDownloadTime != null)
				{
					var now:Date = new Date();
					var nextPossibleBEFTime:Number =
						_bestEffortLastGoodFragmentDownloadTime.valueOf() + Math.max(_f4fIndexInfo.bestEffortFetchInfo.fragmentDuration, 1000);
					if(now.valueOf() < nextPossibleBEFTime)
					{
						// in order to prevent too many spurious liveness BEFs,
						// don't perform liveness BEF unless its been at least half a fragment interval since the last
						// successful download
						return initiateBootstrapRefresh(quality);
					}
				}
				
				if(_bestEffortState == BEST_EFFORT_STATE_OFF)
				{
					// we're beginning best effort fetch
					bestEffortLog("Best effort play start");
					_bestEffortState = BEST_EFFORT_STATE_PLAY;
					_bestEffortFailedFetches = 0;
				}
				
				if(_bestEffortFailedFetches < _f4fIndexInfo.bestEffortFetchInfo.maxForwardFetches)
				{
					// perform a best effort fetch
					return initiateBestEffortRequest(nextFragmentId, quality);
				}
				else
				{
					// oops, all best effort fetches failed.
					// give up and just perform a normal next
					bestEffortLog("Best effort play failing due to too many failures");
					// fall through to do non-BEF behavior
				}
			}
			
			// we're going to do the non-BEF behavior
			if(situation == BEST_EFFORT_PLAY_SITUAUTION_LIVENESS)
			{
				bestEffortLog("Best effort in liveness");
				
				// the next time through, restart just after the last good download point 
				_bestEffortState = BEST_EFFORT_STATE_OFF;
				_currentFAI.fragId = _bestEffortLivenessRestartPoint;
				
				return initiateLivenessFailure(quality);
			}
			else if(situation == BEST_EFFORT_PLAY_SITUAUTION_DONE)
			{
				bestEffortLog("Best effort done");
				return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);
			}
			else // implicit: situation is 'normal' or 'dropout'
			{			
				// figure out the next fragment id after the gap
				// we're not using validateFragment because it has incompatible behavior close to the live point
				var oldCurrentFAI:FragmentAccessInformation = _currentFAI;
				_currentFAI = frt.getFragmentWithIdGreq(nextFragmentId);
				if(_currentFAI == null)
				{
					// very rare case: couldn't get the fragment because there were no valid bootstrap entries.
					_currentFAI = oldCurrentFAI;
					bestEffortLog("Best effort done because there were no bootstrap entries");
					return initiateBootstrapRefresh(quality);
				}
				
				_bestEffortState = BEST_EFFORT_STATE_OFF; // make sure to set state to off in case we were in play state
				bestEffortLog("Normal play request for fragment "+_currentFAI.fragId);
				return initiateNormalDownload(bootstrapBox, quality);
			}
		}
		
		/**
		 * @private
		 * 
		 * Initiates a best effort request (from getNextFile or getFileForTime) and constructs an HTTPStreamRequest.
		 * 
		 * @return the action to take, expressed as an HTTPStreamRequest
		 **/
		private function initiateBestEffortRequest(nextFragmentId:uint, quality:int):HTTPStreamRequest
		{
			// if we had a pending BEF download, invalidate it
			stopListeningToBestEffortDownload();
			
			// update state
			_currentFAI = new FragmentAccessInformation();
			_currentFAI.fragId = nextFragmentId;
			_currentFAI.fragDuration = 0; // the only code that cares about this value is notifyFragmentDuration
			_currentFAI.fragmentEndTime = 0; // currently nobody cares about this value
			playInProgress = true;
			updateQuality(quality);
			
			// we don't know the fragment duration, so update the bootstrap frequently
			bootstrapUpdateInterval = OSMFSettings.hdsMinimumBootstrapRefreshInterval;
			
			// figure out the url to fetch
			var guessSegmentNumber:uint = uint(Math.ceil(Number(nextFragmentId) /
				(_f4fIndexInfo.bestEffortFetchInfo.segmentDuration/_f4fIndexInfo.bestEffortFetchInfo.fragmentDuration)));
			var guessUrl:String = constructFragmentRequest(
				_serverBaseURL, // serverBaseURL
				_streamNames[quality], // streamName
				guessSegmentNumber, // segmentId
				nextFragmentId); //fragmentId
			bestEffortLog("Best effort fetch for fragment "+nextFragmentId+" with url "+guessUrl+". State is "+_bestEffortState);
			
			// clean up best effort state
			_bestEffortDownloadReply = null;
			_bestEffortNeedsToFireFragmentDuration = false;
			
			// recreate the best effort download monitor
			// this protects us against overlapping best effort downloads
			_bestEffortDownloaderMonitor = new EventDispatcher();
			_bestEffortDownloaderMonitor.addEventListener(HTTPStreamingEvent.DOWNLOAD_COMPLETE, onBestEffortDownloadComplete);
			_bestEffortDownloaderMonitor.addEventListener(HTTPStreamingEvent.DOWNLOAD_ERROR, onBestEffortDownloadError);
			
			var streamRequest:HTTPStreamRequest =  new HTTPStreamRequest(
				HTTPStreamRequestKind.BEST_EFFORT_DOWNLOAD,
				guessUrl, // url
				-1, // retryAfter
				_bestEffortDownloaderMonitor); // bestEffortDownloaderMonitor
			
			// trigger a refresh
			adjustDelay();
			refreshBootstrapBox(quality);
			
			return streamRequest;
		}
		
		/**
		 * @private
		 *
		 * if we had a pending BEF download, invalid it
		 **/
		private function stopListeningToBestEffortDownload():void
		{
			if(_bestEffortDownloaderMonitor != null)
			{
				_bestEffortDownloaderMonitor.removeEventListener(HTTPStreamingEvent.DOWNLOAD_COMPLETE, onBestEffortDownloadComplete);
				_bestEffortDownloaderMonitor.removeEventListener(HTTPStreamingEvent.DOWNLOAD_ERROR, onBestEffortDownloadError);
				_bestEffortDownloaderMonitor = null;
			}
		}
		
		/**
		 * @private
		 * 
		 * Best effort backward seek needs to pre-parse the fragment in order to determine if the
		 * downloaded fragment actually contains the desired seek time. This method performs that parse.
		 **/
		private function bufferAndParseDownloadedBestEffortBytes(url:String, downloader:HTTPStreamDownloader):void
		{
			if(_bestEffortDownloadReply != null)
			{
				// if we already decided to skip or continue, don't parse new bytes
				return;
			}
			// annoying way to pass argument into onBestEffortF4FHandlerNotifyBootstrapBox
			_bestEffortNotifyBootstrapBoxInfo = {
				downloader: downloader,
				url: url
			};
			try
			{
				var downloaderAvailableBytes:uint = downloader.totalAvailableBytes;
				if(downloaderAvailableBytes > 0)
				{
					// buffer the downloaded bytes
					var downloadInput:IDataInput = downloader.getBytes(downloaderAvailableBytes);
					if(downloadInput != null)
					{
						downloadInput.readBytes(_bestEffortSeekBuffer, _bestEffortSeekBuffer.length, downloaderAvailableBytes);
					}
					
					// feed the bytes to our f4f handler in order to parse out the bootstrap box.
					while(_bestEffortF4FHandler.inputBytesNeeded > 0 &&
						_bestEffortF4FHandler.inputBytesNeeded <= _bestEffortSeekBuffer.bytesAvailable &&
						_bestEffortDownloadReply == null) // changes to non-null once we parse out the bootstrap box
					{
						_bestEffortF4FHandler.processFileSegment(_bestEffortSeekBuffer); 
					}
					if(_bestEffortDownloadReply == HTTPStreamingEvent.DOWNLOAD_CONTINUE)
					{
						// we're done parsing and the HTTPStreamSource is going to process the file,
						// restore the contents of the downloader
						downloader.clearSavedBytes();
						_bestEffortSeekBuffer.position = 0;
						downloader.appendToSavedBytes(_bestEffortSeekBuffer, _bestEffortSeekBuffer.length);
						_bestEffortSeekBuffer.length = 0; // release the buffer
					}
				}
			}
			finally
			{
				_bestEffortNotifyBootstrapBoxInfo = null;
			}
		}
		
		/**
		 * @private
		 * 
		 * Fired when the _bestEffortF4FHandler fires a NOTIFY_BOOTSTRAP_BOX event.
		 * This occurs during the pre-parsing that occurs in best effort backward fetch.
		 **/
		private function onBestEffortF4FHandlerNotifyBootstrapBox(event:HTTPStreamingFileHandlerEvent):void
		{
			var url:String = _bestEffortNotifyBootstrapBoxInfo.url as String;
			var downloader:HTTPStreamDownloader = _bestEffortNotifyBootstrapBoxInfo.downloader as HTTPStreamDownloader;
			
			if(_bestEffortDownloadReply != null)
			{
				bestEffortLog("Best effort found a bootstrap box in the downloaded fragment, but we already replied.");
				return;
			}
			
			var bootstrapBox:AdobeBootstrapBox = event.bootstrapBox;
			var frt:AdobeFragmentRunTable = getFragmentRunTable(bootstrapBox);
			if(frt == null)
			{
				bestEffortLog("Best effort download contained an invalid bootstrap box.");
				skipBestEffortFetch(url, downloader);
				return;
			}
			
			if(frt.fragmentDurationPairs.length != 1)
			{
				bestEffortLog("Best effort download has an FRT with more than 1 entry.");
				skipBestEffortFetch(url, downloader);
				return;
			}
			var fdp:FragmentDurationPair = frt.fragmentDurationPairs[0];
			if(fdp.duration == 0)
			{
				bestEffortLog("Best effort download FDP was a discontinuity.");
				skipBestEffortFetch(url, downloader);
				return;
			}
			var fragmentEndTime:Number = fdp.durationAccrued + fdp.duration;
			if(_bestEffortSeekTime < fragmentEndTime)
			{
				bestEffortLog("Best effort found the desired time within the downloaded fragment.");
				continueBestEffortFetch(url, downloader);
			}
			else
			{
				bestEffortLog("Best effort didn't find the desired time within the downloaded fragment.");
				skipBestEffortFetch(url, downloader);
				_bestEffortState = BEST_EFFORT_STATE_SEEK_FORWARD;
				_bestEffortFailedFetches = 0;
			}
		}
		
		/**
		 * @private
		 * 
		 * Invoked on HTTPStreamingEvent.DOWNLOAD_COMPLETE for best effort downloads
		 */
		private function onBestEffortDownloadComplete(event:HTTPStreamingEvent):void
		{
			if(_bestEffortDownloaderMonitor == null ||
				_bestEffortDownloaderMonitor != event.target as IEventDispatcher)
			{
				// we're receiving an event for a download we abandoned
				return;
			}
			bestEffortLog("Best effort download complete");
			
			// unregister the listeners
			stopListeningToBestEffortDownload();
			
			// forward the DOWNLOAD_COMPLETE to HTTPStreamSource, but change the reason
			var clone:HTTPStreamingEvent = new HTTPStreamingEvent(
				event.type,
				event.bubbles,
				event.cancelable,
				event.fragmentDuration,
				event.scriptDataObject,
				event.scriptDataMode,
				event.url,
				event.bytesDownloaded,
				HTTPStreamingEventReason.BEST_EFFORT,
				event.downloader);
			dispatchEvent(clone);
			
			if(_bestEffortDownloadReply != null)
			{
				// we already said "continue" or "skip"
				return;
			}
			
			switch(_bestEffortState)
			{
				case BEST_EFFORT_STATE_PLAY:
				case BEST_EFFORT_STATE_SEEK_FORWARD:
					// we successfully got a fragment.
					// tell HTTPStreamSource to go ahead and process this fragment.
					continueBestEffortFetch(event.url, event.downloader);
					break;
				case BEST_EFFORT_STATE_SEEK_BACKWARD:
					// in backward seek state we want to parse the fragment in order to see if it
					// has the time we want. parse any remaining bytes
					bufferAndParseDownloadedBestEffortBytes(event.url, event.downloader);
					if(_bestEffortDownloadReply == null)
					{
						// rare case: we downloaded the fragment, but we never found a bootstrap box.
						// just keep going
						skipBestEffortFetch(event.url, event.downloader);
					}
					break;
				default:
					bestEffortLog("Best effort download complete received while in unexpected state ("+_bestEffortState+")");
					break;
			}
		}
		
		/**
		 * @private
		 * 
		 * Invoked on HTTPStreamingEvent.DOWNLOAD_ERROR for best effort downloads
		 */
		private function onBestEffortDownloadError(event:HTTPStreamingEvent):void
		{
			if(_bestEffortDownloaderMonitor == null ||
				_bestEffortDownloaderMonitor != event.target as IEventDispatcher)
			{
				// we're receiving an event for a download we abandoned
				return;
			}
			// unregister our listeners
			stopListeningToBestEffortDownload();
			
			if(_bestEffortDownloadReply != null)
			{
				// special case: if we received some bytes and said "continue", but then the download failed.
				// there means there was a connection problem mid-download
				bestEffortLog("Best effort download error after we already decided to skip or continue.");
				dispatchEvent(event); // this stops playback
			}
			else if(event.reason == HTTPStreamingEventReason.TIMEOUT)
			{
				// special case: the download took too long and all the retries failed
				bestEffortLog("Best effort download timed out");
				dispatchEvent(event); // this stops playback
			}
			else
			{
				// failure due to http status code, or some other reason. resume best effort fetch
				bestEffortLog("Best effort download error.");
				++_bestEffortFailedFetches;
				skipBestEffortFetch(event.url, event.downloader);
			}
		}
		
		/**
		 * @private
		 * 
		 * After initiating a best effort fetch, call this function to tell the
		 * HTTPStreamSource that it should not continue processing the downloaded
		 * fragment.
		 * 
		 **/
		private function skipBestEffortFetch(url:String, downloader:HTTPStreamDownloader):void
		{
			if(_bestEffortDownloadReply != null)
			{
				bestEffortLog("Best effort wanted to skip fragment, but we're already replied with "+_bestEffortDownloadReply);
				return;
			}
			bestEffortLog("Best effort skipping fragment.");
			var event:HTTPStreamingEvent = new HTTPStreamingEvent(HTTPStreamingEvent.DOWNLOAD_SKIP,
				false, // bubbles
				false, // cancelable
				0, // fragmentDuration
				null, // scriptDataObject
				FLVTagScriptDataMode.NORMAL, // scriptDataMode 
				url, // url
				0, // bytesDownloaded
				HTTPStreamingEventReason.BEST_EFFORT, // reason
				downloader); // downloader
			dispatchEvent(event);
			
			_bestEffortDownloadReply = HTTPStreamingEvent.DOWNLOAD_SKIP;
			_bestEffortNeedsToFireFragmentDuration = false;
		}
		
		/**
		 * @private
		 * 
		 * After initiating a best effort fetch, call this function to tell the
		 * HTTPStreamSource that it may continue processing the downloaded fragment.
		 * A continue event is assumed to mean that best effort fetch is complete.
		 **/
		private function continueBestEffortFetch(url:String, downloader:HTTPStreamDownloader):void
		{
			if(_bestEffortDownloadReply != null)
			{
				bestEffortLog("Best effort wanted to continue, but we're already replied with "+_bestEffortDownloadReply);
				return;
			}
			bestEffortLog("Best effort received a desirable fragment.");
			
			var event:HTTPStreamingEvent = new HTTPStreamingEvent(HTTPStreamingEvent.DOWNLOAD_CONTINUE,
				false, // bubbles
				false, // cancelable
				0, // fragmentDuration
				null, // scriptDataObject
				FLVTagScriptDataMode.NORMAL, // scriptDataMode 
				url, // url
				0, // bytesDownloaded
				HTTPStreamingEventReason.BEST_EFFORT, // reason
				downloader); // downloader
			
			// if we encounter liveness in the future, restart BEFs
			// after the current fragment
			_bestEffortLivenessRestartPoint = _currentFAI.fragId;
			CONFIG::LOGGING
			{
				logger.debug("Setting _bestEffortLivenessRestartPoint to "+_bestEffortLivenessRestartPoint+" because of successful BEF download.");
			}
			
			// remember that we started a download now
			_bestEffortLastGoodFragmentDownloadTime = new Date();
			
			dispatchEvent(event);
			_bestEffortDownloadReply = HTTPStreamingEvent.DOWNLOAD_CONTINUE;
			_bestEffortNeedsToFireFragmentDuration = true;
			_bestEffortState = BEST_EFFORT_STATE_OFF;
		}
		
		/**
		 * @private
		 * 
		 * After initiating a best effort fetch, call this function to tell the
		 * HTTPStreamSource that a bad download error occurred. This causes HTTPStreamSource
		 * to stop playback with an error.
		 **/
		private function errorBestEffortFetch(url:String, downloader:HTTPStreamDownloader):void
		{
			bestEffortLog("Best effort fetch error.");
			var event:HTTPStreamingEvent = new HTTPStreamingEvent(HTTPStreamingEvent.DOWNLOAD_ERROR,
				false, // bubbles
				false, // cancelable
				0, // fragmentDuration
				null, // scriptDataObject
				FLVTagScriptDataMode.NORMAL, // scriptDataMode 
				url, // url
				0, // bytesDownloaded
				HTTPStreamingEventReason.BEST_EFFORT, // reason
				downloader); // downloader
			dispatchEvent(event);
			_bestEffortDownloadReply = HTTPStreamingEvent.DOWNLOAD_ERROR;
			_bestEffortNeedsToFireFragmentDuration = false;
		}
		
		/**
		 * @private
		 * 
		 * Fires FRAGMENT_DURATION in response to best effort fetch.
		 * 
		 * Normal downloads fire FRAGMENT_DURATION before the download starts.
		 * In the best effort case, the duration is unavailable at request time and only
		 * becomes available after the fragment downloaded and parsed (the duration is
		 * passed along with the fragment's boostrap box). Thus, in the best effor case,
		 * FRAGMENT_DURATION is fired after the fragment download completes. 
		 **/
		private function notifyFragmentDurationForBestEffort(bootstrapBox:AdobeBootstrapBox):void
		{
			if(!_bestEffortNeedsToFireFragmentDuration || // we only care if we haven't fired an event yet
				bootstrapBox == null) // safety check
			{
				return;
			}
			_bestEffortNeedsToFireFragmentDuration = false; // don't invoke again
			
			// look up the fragment duration in the fragment run table.
			var frt:AdobeFragmentRunTable = getFragmentRunTable(bootstrapBox);
			if(frt == null)
			{
				return;
			}
			var fragmentDuration:Number = frt.getFragmentDuration(_currentFAI.fragId);
			if(fragmentDuration == 0) // missing
			{
				return;
			}
			
			// unlike notifyFragmentDuration, we do not change bootstrapUpdateInterval since
			// we're getting the information at a later time (after we've downloaded the fragment)
			
			// fire the event
			bestEffortLog("Best effort fetch firing the fragment duration.");
			dispatchEvent(new HTTPStreamingEvent( 
				HTTPStreamingEvent.FRAGMENT_DURATION, // type
				false, // bubbles
				false, // cancelable
				fragmentDuration / bootstrapBox.timeScale, // fragmentDuration
				null, // scriptDataObject
				null)); // scriptDataMode
		}
		
		/**
		 * @private
		 * logging related to best effort fetch
		 **/
		private function bestEffortLog(s:String):void
		{
			CONFIG::LOGGING
			{
				logger.debug("BEST EFFORT: "+s);
			}
		}
		
		
		/**
		 * @inheritDoc
		 */	
		public override function get isBestEffortFetchEnabled():Boolean
		{
			return _bestEffortEnabled;
		}
		
//		/**
//		 * @private
//		 * 
//		 * Given timeBias, calculates the corresponding segment duration.
//		 */
//		internal function calculateSegmentDuration(abst:AdobeBootstrapBox, timeBias:Number):Number
//		{
//			var fragmentDurationPairs:Vector.<FragmentDurationPair> = (abst.fragmentRunTables)[0].fragmentDurationPairs;
//			var fragmentId:uint = currentFAI.fragId;
//			
//			var index:int =  fragmentDurationPairs.length - 1;
//			while (index >= 0)
//			{
//				var fragmentDurationPair:FragmentDurationPair = fragmentDurationPairs[index];
//				if (fragmentDurationPair.firstFragment <= fragmentId)
//				{
//					var duration:Number = fragmentDurationPair.duration;
//					var durationAccrued:Number = fragmentDurationPair.durationAccrued;
//					durationAccrued += (fragmentId - fragmentDurationPair.firstFragment) * fragmentDurationPair.duration;
//					if (timeBias > 0)
//					{
//						duration -= (timeBias - durationAccrued);
//					}
//					
//					return duration;
//				}
//				else
//				{
//					index--;
//				}
//			}
//			
//			return 0;
//		}
//
//		override public function getFragmentDurationFromUrl(fragmentUrl:String):Number
//		{
//			// we assume that there is only one afrt in bootstrap
//			
//			var tempFragmentId:String = fragmentUrl.substr(fragmentUrl.indexOf("Frag")+4, fragmentUrl.length);
//			var fragId:uint = uint(tempFragmentId);
//			var abst:AdobeBootstrapBox = bootstrapBoxes[_currentQuality];
//			var afrt:AdobeFragmentRunTable = abst.fragmentRunTables[0];
//			return afrt.getFragmentDuration(fragId);
//		}

		
		/// Internals		
		private var _currentQuality:int = -1;
		private var _currentAdditionalHeader:ByteArray = null;
		private var _currentFAI:FragmentAccessInformation = null;						// annoying way to pass argument into onBestEffortF4FHandlerNotifyBootstrapBox
		
		private var _pureLiveOffset:Number = NaN;
		
		private var _f4fIndexInfo:HTTPStreamingF4FIndexInfo = null;
		private var _bootstrapBoxes:Vector.<AdobeBootstrapBox> = null;
		private var _bootstrapBoxesURLs:Vector.<String> = null;
		private var _streamInfos:Vector.<HTTPStreamingF4FStreamInfo> = null;
		private var _streamNames:Array = null;
		private var _streamQualityRates:Array = null;
		private var _serverBaseURL:String = null;
		
		private var _delay:Number = 0.05;
		
		private var _indexUpdating:Boolean = false;
		private var _pendingIndexLoads:int = 0;
		private var _pendingIndexUpdates:int = 0;
		private var _pendingIndexUrls:Object = new Object();

		private var _invokedFromDvrGetStreamInfo:Boolean = false;
		
		
		private var playInProgress:Boolean;
		
		private var bootstrapUpdateTimer:Timer;
		private var bootstrapUpdateInterval:Number = 4000;
		public static const DEFAULT_FRAGMENTS_THRESHOLD:uint = 5;
		
		// _bestEffortState values
		private static const BEST_EFFORT_STATE_OFF:String = "off"; 											// not performing best effort fetch
		private static const BEST_EFFORT_STATE_PLAY:String = "play"; 										// doing best effort for liveness or dropout
		private static const BEST_EFFORT_STATE_SEEK_BACKWARD:String = "seekBackward";						// in the backward fetch phase of best effort seek
		private static const BEST_EFFORT_STATE_SEEK_FORWARD:String = "seekForward";							// in the forward fetch phase of best effort seek
		
		private var _bestEffortInited:Boolean = false;														// did we initialize _bestEffortEnabled?
		private var _bestEffortEnabled:Boolean = false;														// is BEF enabled at all?
		private var _bestEffortState:String =  BEST_EFFORT_STATE_OFF;										// the current state of best effort
		private var _bestEffortSeekTime:Number = 0;															// the time we're seeking to
		private var _bestEffortDownloaderMonitor:EventDispatcher = new EventDispatcher(); 					// Special dispatcher to handler the results of best-effort downloads.
		private var _bestEffortFailedFetches:uint = 0; 														// The number of fetches that have failed so far.
		private var _bestEffortDownloadReply:String = null;													// After initiating a download, this is the DOWNLOAD_CONTINUE or DOWNLOAD_SKIP reply that we sent
		private var _bestEffortNeedsToFireFragmentDuration:Boolean = false;									// Do we need to fire the FRAGMENT_DURATION event for the next fragment?
		private var _bestEffortF4FHandler:HTTPStreamingF4FFileHandler = new HTTPStreamingF4FFileHandler();	// used to pre-parse backward seeks
		private var _bestEffortSeekBuffer:ByteArray = new ByteArray();										// buffer for saving bytes when pre-parsing backward seek
		private var _bestEffortNotifyBootstrapBoxInfo:Object = null;										// hacky way to pass arguments to helper functions
		private var _bestEffortLivenessRestartPoint:uint = 0;												// if we have to restart BEF for liveness, the fragment number of the first BEF - 1
		private var _bestEffortLastGoodFragmentDownloadTime:Date = null;
		
		// constants used by getNextRequestForBestEffortPlay:
		private static const BEST_EFFORT_PLAY_SITUAUTION_NORMAL:String = "normal";
		private static const BEST_EFFORT_PLAY_SITUAUTION_DROPOUT:String = "dropout";
		private static const BEST_EFFORT_PLAY_SITUAUTION_LIVENESS:String = "liveness";
		private static const BEST_EFFORT_PLAY_SITUAUTION_DONE:String = "done";

		CONFIG::LOGGING
		{
			private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.net.httpstreaming.f4f.HTTPStreamF4FIndexHandler");
		}
	}
}
