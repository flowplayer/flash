Version history:

3.2.8
-----
- Made it possible to compile in accepted domains. The plugin prevents the player from initializing if the player
  is not embedded in one of these domains.
- #391 add message argument required to send message through to the failure callback.

3.2.3
-----
Fixes
- does not show "cluster plugin not found in configuration" any more: http://code.google.com/p/flowplayer-core/issues/detail?id=208

3.2.2
-----
- Added support for the cluster plugin

3.2.1
---------
- Added parallel connection mechanism on secure RTMP streams

3.1.2-dev
---------
- some small fixes

3.1.1
-----
- compatible with the new ConnectionProvider and URLResolver API

3.1.0
------
- first public release
