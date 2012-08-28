3.2.9
-----
- http://code.google.com/p/flowplayer-core/issues/detail?id=486
- #595 dispatches a clip stream not found error event for missing f4m feeds. For configured live streams, use a connection attempt until the max retries has reached or the stream becomes available.

3.2.8
-----

- First release!
- #489 create base url from the clip complete url, issue causing multiple forward slashes.
- #493 add option to include application instance for rtmp base urls.