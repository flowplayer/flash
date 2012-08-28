Sample Application: AkamaiPluginSample

A. Overview

This sample application demonstrates loading OSMF plugins and can also display,
and play a playlist from a Media RSS feed.

The Akamai plugin handles secure streaming for both live and on-demand content over the Akamai network.  
There is a sample stream containing an auth token in the sample.  Auth tokens can be passed as query strings
on the URL, or seperately as resource metadata using the auth token text input in the sample.

The MAST plugin loads a MAST document, parses it, and loads it's payload (a VAST document containing a sample ad pre-roll).
You will see an ad pre-roll before each video when this plugin is loaded.  In the "loadMedia" function, you can see
the URL of the MAST document being set as metadata on the media element's resource.

The SMIL plugin loads a SMIL document, parses it, and creates MediaElement(s) based on the contents of the SMIL.
This includes a serial composition of videos and RTMP dynamic streaming.

B. Installation Instructions (Flex Builder)

1. Unzip/copy the AkamaiPluginSample project into your Flex Builder workspace folder. 
2. In Flex Builder, go to the File menu and select "Import".
3. Browse to your Flex Builder workspace folder.
4. Click "Finish". This will import the project.
5. Build the project.
6. Launch the application from the Run menu.*

C. Usage Instructions

Select a plugin to load, and/or select a peice of media from the combo box.
There are two sample RSS feeds, if you select these, the OSMF Syndication library
will be used to parse and generate an object model used by the sample app. You can
add a pre-roll for each item in the playlist by loading the MAST plugin before selecting
an RSS feed.

 