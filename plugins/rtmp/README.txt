Version history:

3.2.11
------
- fixes to stepping functions.
- added new configuration variable 'inBufferSeek' that can be used to disable "Smart Seek" that became available
  in Adobe FMS 3.5.3. Use this if you are running a RTMP server that does not support this in buffer seeking (smart seek).
- #614 test if there is no more playlist items left to dispatch finish on buffer empty events where the stream appears to hang.

3.2.9
-----
- #534 don't round seek times for frame accurate seeking.
- #545 for mp3 streams, we need to call the file with an id3 prefix on the server to obtain the metadata.
- #551 when using subscribing live streams with bitrates set, subscribe to all streams to allow for switching.
- #567 fixes with typo in autobuffering / pause to frame feature.
- #594 when pausing to a frame, set a 100ms timeout to pause instead of a seek which was causing some streams to hang.
- #593 if this clip has a stream group, prevent onbegin from dispatching during playback.

3.2.8
-----
- FMS smart seeking (in buffer seeking): http://blogs.adobe.com/actionscriptdocs/2010/06/flash_media_server_stream_reco.html
  There is a new clip property backBufferLength, that can be used to control the buffer size for backward seeking and rewind.
- p2p multicast support, added property p2pGroupSpec
- Added stream switching event handlers to be used with the switchStream api method.
Fixes:
- Fixes for #247, native switching on transition failures requires live stream check.
- Issue #327, onStart was not dispatched for mp3 streams
- Issue #338 don't set clip currentTime when dynamic stream switching.
- Issue #355, setup targeted options for Flash 10.1 to provide support for 10.0
- Issue #351, connectionArgs are not passed to RTMPT connections
- #363 when pausing on startup some clips require seekableOnBegin enabled or else the scrubbar is disabled.
- #363 overridable pause to frame for different seek functionality on rtmp streams, requires to seek to 0.1 to constistantly start on a frame.
- #406 don't run version checks here anymore to work with Flash 11
- #403 when seeking to the duration the buffer will flush and needs to end correctly
- #424 regression with #403, force an end seek buffer to allow some playback and prevent hanging when seeking to the duration. buffer flush causes issues with playlists.
- #430 on intermittent client connection failures, attempt a reconnect, or wait until connection is active again for rtmp connections.
- #430 if there is a client connection failure reconnect to the specified time for rtmp streams after metadata.
- #430 Do not attempt to re-connect in the plugin, this may be done in the connection providers and doing so resets the connection providers.
- #439 just check for an rtmp complete url when parsing complete urls to allow other complete urls used for re-streaming to pass through.
- #486 unmute when auto buffering and pausing to a frame.
- #494 generate the complete url only if a base url is set. regression caused by #412.

3.2.3
-----
Fixes:
- Unnecessarily displays the "play again" button with live streams: http://flowplayer.org/forum/8/46963

3.2.2
-----
Fixes:
- Now reaches the end of the video when the server sends a NetStream.Play.Stop.
- Now reaches the end of the video when the server sends a little bit less stream than expected, using start:
- Fix for rtmpt connection arguments passing: http://flowplayer.org/forum/8/45714#post-45714
- Moved parallel connection mechanism to core.

3.2.1
-----
Fixes:
- Does not report connection errors unnecessarily any more

3.2.0
-----
- changes related to bandwidth detection compatibility

3.1.4
-----
Fixes:
- Now resets the bufferStart value to zero when replaying a clip. Because it failed to reset it the buffer bar and
  progress bar were not drawn correctly when replaying.
- Now supports rtmpe/rtmpte parallel connecting attempts

3.1.3
-----
- Supports connection redirects as described here: http://www.wowzamedia.com/forums/showthread.php?t=6206#2
- New configuration option 'connectionArgs' that accepts an array of arguments to be passed to NetConnection.connect().
  This is needed for example with the Internap CDN.
- Now correctly recognizes fully qualified RTMP clip urls (no need to specify netConnectionUrl separately)

3.1.2
-----
- compatible with the new ConnectionProvider and URLResolver API
- Starts RTMP and RTMPT connection attempts in parallel. The one who succeeds first will be used and the other one is discarded.
  The approach is described here: http://kb2.adobe.com/cps/185/tn_18537.html#http_improv
- New configuration option proxyType. Default value is "best". See http://livedocs.adobe.com/flash/9.0/ActionScriptLangRefV3/flash/net/NetConnection.html#proxyType

3.1.1
-----
- Possibility to query stream durations from the server. New config option 'durationFunc' for this.

3.1.0
------
- Subscribing connection establishment for Akamai and Limelight. Enabled by setting subscribe: true in the plugin config.
- Added objectEncoding config option, needed to connect to FMS2

3.0.2
-----
- the progress bar now moves to the latest seek position
- bufferbar now shows how much data has been buffered ahead of the current playhead position
- compatible with flowplayer 3.0.3 provider API
- made it possible to specify a full rtmp URL in clip's url. In this case the netConnectionUrl variable is not needed in the provider config.

3.0.1
-----
- dispatches the LOAD event when initialized (needed for flowplayer 3.0.2 compatibility)

3.0.0
---
- 3.0.0 final

beta3
-----
- compatibility with core rc4

beta1
-----
- First public beta release
