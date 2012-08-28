Version history:

3.2.10
------
- #547 Live dynamic stream switching not working on Internap CDN
- #563 fixes for resolving bitrates with the bitrateselect and menu plugin.

3.2.9
-----
- #500 fix for netstream metrics, do not set to the clip properties as it causes errors with event callbacks, small refactoring of NetStreamSwitchManager to reflect osmf1.6.
- #547 don't set the start property for dynamic switching unless set, causes problems for live streams, issue is also caused inside the OSMF switch manager.



3.2.8
-----
- Refactored HD button feature to bitrateselect plugin.
- Refactored bwcheck with common bitrate selection and switching #292
- Make generated bitrate list work with dynamic stream switching functions.
- Provide integration with bitrateselect plugin.
- fix for #347 create custom playstatus handler or else it breaks dynamic events
- #347 overriding osmf switching rules to be able to configure options.
- Added ability to obtain netstreammetrics from the clip required for the qosmonitor plugin.
- #347 Fixed issue with returning onPlayStatus correctly in custom osmf netclient.
- #347 use netstreamswitchmanager instead to obtain index instead of metrics which returns -1 at times.
- fixes for #352 for wowza streams with secure names that return the real name from the server, return the item from the metrics index instead.
- #352 made required modifications to netstreamswitchmanager to provide correct index to the metrics class for secure streams.
- #352 made configurable options in netstreamswitchmanager for all timer and rule settings for quality of service monitoring to be customisable.
- #352 set the clear failed count interval to the clip duration in milliseconds times a prescision value
- Issue #355, disabled targeted Flash 10.1 in rtmp bwcheck to provide support for 10.0, required to be on for httpstreaming support
- Fixes for# #67 removed depreciated code for httpstreaming.
- #369 set clip start time for adding to play2 arguments during dynamic stream switching.
- #408 changed some default qos settings to work better with wowza.
- #417 disable setting the index with a screen size rule and manual switch with dynamic also enabled as it resets the index and causes issues obtaining the previous item.
- #417 if screen size rule is disabled do not do screen size checks for the index.

3.2.6
-----
- Refactored HD button feature to be only available with a combination of two bitrates. hd and normal properties not required.
- HD button should now be toggled to HD when a hd clip is set as default or when a HD clip is chosen after server detection.
- Fullscreen switching does not happen now when a hd mode is set.
- Now works with dynamic: true when not configured as a URL resolver. Makes it possible to use it together with secure
  streaming plugin.
Fixes:
- Fixed up issues with server detection with cloudfront fms 3.5 servers. Will return zero bytes requiring re-detection multiple times.
- Fixed up detection and switching on fullscreen toggling.
- Added initial support for dynamic stream switching for httpstreaming provider.
- Fixed #259, redirect bwcheck connections to hddn nodes.


3.2.4
-----
- Now works without configuring netConnectionUrl for the plugin, in this case the netConnectionUrl value is taken from the clip. Also works when it's resolved by the SMIL plugin etc.
- Fix for using bwcheck with the playlist JS plugin

3.2.3
-----
- new config
- new event onStreamSwitchBegin

3.2.2
-----
Fixes:
- fixing bwcheck with FMS, was unable to re-detect during playback

3.2.1
-----
Fixes:
- this plugin did not work properly with playlists, in fact it was only possible to use it with one configured clip
- stream selection now works properly if the bitrates array does not contain video width values
- stream selection works better if the configured bitrates all exceed available BW: In this case the default bitrate is
  selected and if the default is not configured the smallest bitrate is used

3.2.0
-----
- New configuration model
- Considers the screen size when selecting streams
- Switches when entering and exiting fullscreen
- Support for specifying bitrates in RSS files

3.1.3
-----
- issues fixed in FMS dynamic stream switching

3.1.2
-----
- compatible with 3.2 ConnectionProvider and URLResolver API
- Now the remembered bitrate is only cached for 24 hours by default. You can control the cache expiry using a new
  config option 'cacheExpiry' where the expiry period is given in seconds.
- With 'rememberBitrate' enabled now stores the detected bandwidth and the mapping to the bitrate happens every time
  the remembered bandwidth is used.

3.1.1
-----
- New external method dynamic(enabled) to toggle dynamic bitrate adaptation
- setBitrate() external method now disabled dynamic bitrate adaptation. Otherwise the manually set value would be immediately
  overridden by the dynamically adapted bitrate.
- Added new urlExtension, determines the 3rd token in the urlPattern
- Possibility to attach labels to bitrates. These are used with the urlPattern and urlExtension to generate the resolved file names.
- Gives an error message if neither 'netConnectionUrl' nor the 'hosts' array is not defined in config
- Now by default checks the bandwidth for every clip, where the plugin is not explicitly defined as urlResolver.
  New config option 'checkOnBegin' to turn of this default behavior
- Does not use the no-cache request header pragma any more
Fixes:
- autoPlay: false now honored when using "auto checking" i.e. when checkOnBegin is not explicitly set to false
- Fixed dynamic switching, it was interpreting the 'bitrates' array in reversed order
- Bandwidth is only detected once per clip. Because it was detected multiple times repeated plays did not work because
  repeated URL resolving mangled the URL

3.1.0
-----
- first public release

