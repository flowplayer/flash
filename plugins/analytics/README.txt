Version history:

3.2.9
-----
- Reinstating the trackingObj config to configure the bridge mode. Default value is "window.pageTracker".
- Debug view support was removed.

3.2.8
-----
- Bridge mode now removed from code also
- Added new configuration variable "clipTypes" that defaults to [ "video", "audio" ]. To track also images use value [ "video", "audio", "image" ].

3.2.2
-----
- Now tracks the total time users spend viewing the videos. Total time gets accumulated if the user seeks backwards and repeatedly views parts of the video.
- improved error handling
- fixed a problem with playlists
- The Bridge mode is no longer supported

3.2.1
-----
- improved error handling
Fixes:
- fixed problem with playlists http://flowplayer.org/forum/8/42864#post-47165

3.2.0
-----
Fixes:
- did not send messages to Analytics: http://flowplayer.org/forum/5/28992#post-35001
- debug mode is now false by default

3.1.5
-----
- Initial public release
