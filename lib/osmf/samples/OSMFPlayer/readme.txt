The OSMFPlayer sample defines an application that can be embedded on a web page in order to play back media. It contains a control bar that manages the various supported aspects of the media.

Features:

* SWF preloading progress bar,
* Loading (url parameter can be passed to the SWF, and an Eject button supports manual url entry),
* Play state (play, pause, stop),
* Seeking,
* Volume (increase, decrease)
* Elapsed and remaining play time,
* Multiple Bitrate (toggling between automatic and manual mode),
* Control bar hiding (toggleable, autoHideControlBar parameter can be passed to the SWF),
* Full screen (toggleable),
* Background fill (backgroundColor parameter can be passed to the SWF),
* Debug support (see WebPlayerDebugConsole project for more info),

By leveraging the DefaultMediaFactory class, the player can distill the following media element types from the provided input URL:

* VideoElement, using either:
	- NetLoader (streaming or progressive)
	- DynamicStreamingNetLoader (MBR streaming)
	- HTTPStreamingNetLoader (HTTP streaming)
	- F4MLoader (Flash Media Manifest files)
* SoundElement, using either:
	- SoundLoader (progressive)
	- NetLoader (streaming)
* ImageElement
* SWFElement

Usage:

The project's html-template\index.template.html file shows how the produced SWF can be embedded (using SWFObject), as well as the properties that can be set on the player SWF.

Notes:

OSMFPlayer uses the Standard 07_55 font by Craig Kroeger. Please note that this is *not* a free font. Please visit http://www.miniml.com for more licensing information. 