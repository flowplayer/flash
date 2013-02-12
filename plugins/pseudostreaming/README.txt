Version history:

3.2.12
------
- #31 fix to dispatch start events properly when loading new items.

3.2.10
-----
- #568 fix for bitrate switching in paused mode, pause the stream only during seeking while paused. now dispatched seek events while paused.
- #602 don't seek to frame when start is set.
- #630 move seek event dispatching to buffer full or else the time hasn't been updated yet.
- #630 when the event is null we're in silent seek during controlbar dragging, only seek when not silent.

3.2.8
-----
Fixes:
- #385 added dispatching of switch begin and completion events.
- #339, possible fixes for switching and seeking failures due to datastore. does not reload, just a direct seek.
- #321. previous seek time gets cleared on replay seek before time gets updated. Store previous end seek time until playback begins to provide correct replay times.
- #385 regression issue caused by #365, added old switching code back in, and tested seeking and switching work correctly.
- #385 when scrubbing to the edge of the buffer seeking sometimes failed, need to reset the seek time to continue playback.
- #363 pause stream after metadata due to refactoring of autobuffering for rtmp streams.
- #363 silent seek and force to seek to a keyframe or else video frame will not display initially when paused.
- #363 cleanup for autobuffering after a server seek to pause properly.
- #404 refactoring switchStream to suit changes with http streams and the use of the play2 method for resetting the stream.
- #403 when seeking to outside the allowed keyframes, stop is called, require to trigger buffer full to complete correctly.
- #409 version check for byte range seeking was not working with Flash 11
- #409 preventing seeking during silent seeking as is unstable with byte range seeking.
- #409 cleanup reuse http client.
- #486 implement pauseToFrame to unmute audio when autoBuffering.
- #565 append the url params to the generated start param.


3.2.7
-----
- The plugin now comes with two versions, the byte-range enabled version is now in a different SWF to reduce the size
of the standard version that does not have the byte range request powered seeking support.
- The queryString config option value by default is now "?start=${start}". Contains the ? character there again, so
  that it can be changed by users.

Fixes:
- #214 , need to reset the datastore on completion or else time won't reset when seeking mp4 clips
- #314, inconsistent seeking behavior between in-buffer seeks and server seeks
- #315, server seek to position zero was failing

3.2.6
-----
Fixes:
- Pseudostreaming was causing cuepoints to be skipped. As a results subtitles shown using the captions plugin were skipped too.

3.2.5
-----
Fixes:
- fixed to work properly when switching bitrate using the bwcheck plugin

3.2.4
-----
Fixes:
- does not append the query string into the initial request when start=0

3.2.3
-----
- seeking using HTTP byte range requests
Fixes:
- fixed to append the query string using the '&' character if the configured clip URL already has a '?' character in it

3.2.2
-----
- fixed duration after seek

3.2.1
-----
- fixed duration after seek

3.2.0
-----
- changes related to bandwidth detection compatibility

3.1.3
-----
- compatible with the new ConnectionProvider and URLResolver API

3.1.3
-----
- fixed to work with bwcheck, so that random seeking works when bitrate is switched in the middle of a clip
- fixed issue when autoPlay is false, autoBuffering is true and video without metadatas
- fixed PlayOverlayButton state

3.1.2
-----
- fixed out-of-sync scrubbing: http://flowplayer.org/forum/8/17706

3.1.1
-----
- random seeking did not work when looping through the same video for the 2nd time
- the time indicator stayed at value 00:00
- random seeking after stop did not work

3.1.0
-----
- integrated h.264 streaming support, contributed by Arjen Wagenaar, CodeShop B.V.

3.0.3
-----
- now uses the queryString also in the initial request, the start param has value zero in it

3.0.2
-----
- compatible with flowplayer 3.0.3 provider API

3.0.1
-----
- dispatches the LOAD event when initialized (needed for flowplayer 3.0.2 compatibility)

3.0.0
-----
- 3.0.0-final release

beta3
----
- Fixed the typo in the configuration variable queryString
- compatible with core RC4

beta1
-----
- First public beta release
