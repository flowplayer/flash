Version history:

3.2.11 (Nov 2013)
------
- Now uses OSMF 2.0
- #70 fixes for live streams
- #70 fixes for buffer start value.
- #136 when we are streaming live and not in dvr mode set the duration to zero in the index handler instead of the metadata callback.

3.2.10
------
- #27 regression caused by #550, only stop the player for live streams. caused issues when stopping between playlist items.

3.2.9
-----
- #515 when seeking on startup set a delay or else the initial time is treated as the clip start time.
- #550 for live streams once unpublished,  stop the player to prevent streamnotfound errors reconnecting.
- #27 regression caused by #550, only stop the player for live streams. caused issues when stopping between playlist items.

3.2.8
-----
- First release!
