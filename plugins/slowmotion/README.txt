Version history:

3.2.9
-----

- #494 fixes for general fastplay stability with FMS servers. Returns to normal play on InvalidArg errors return from the server.
When going too close to the buffer slow down the stepping for the buffer to catch up when in fast forward mode. Refactoring of controls to provide slowmotion and fastworward on demand
to allow it top stop due to issues with inability to return to normal playback, and possible crashes.
- #621 regression issue with the controls revert back to the original functionality of 3 clicks to return back to the normal playback state.

3.2.1
-----
- Added FMS trick modes
- Added new serverType config option, defaults to 'fms'. For wowza set this to 'wowza'.
- The slowmotion buttons are now initially disabled and they become functional only after playback has started.

3.2.0
-----
- First public release
