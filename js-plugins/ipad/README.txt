Version history

3.2.9
-----
- fixed issue #381, cuepoint.time was left undefined

3.2.8
-----
- Fixed play of first clip in a playlist (#227)
- added ipadBaseUrl
- added m3u8 to valid file extensions
- added mp3, m4a and aac to valid file extensions, possibly needs full audio tag support #360

3.2.2
-----
- the ipadUrl can be encoded with encodeURIComponent()
- Fixed black screen on iPhones
- Added full compatibility with the playlist javascript plugin
- Fixed auto play
- Added completeUrl, type and originalUrl and other properties on Clip object
- Fixed onBefore* handling
- Fixed onLoad event
- Fixed events still fired after player is unloaded
- Fixed url construction when common clip has a baseUrl and clip's url is absolute
- Added iPod support
- Fixed lazy play

3.2.1
-----

Initial release. enjoy!