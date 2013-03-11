Sample Application: CaptioningSample

A. Overview
This sample application demonstrates loading the OSMF captioning plugin and using an external captioning
document to show captions over a video.  Specifically, the sample app loads the OSMF captioning plugin, 
places the URL location of a WC3 Timed Text DFXP file on the metadata of the video resource, and listens 
for the metadata TemporalFacet to be added to the VideoElement.

When the TemporalFacet is added to the VideoElement, an event listener is added for events of type TemporalFacetEvent.
In that event handler, the caption data is included in the event and the sample app renders the caption using the style information
found in the caption object that was passed to the event listener.

B. Installation Instructions (Flex Builder)

1. Unzip/copy the CaptioningSample project into your Flex Builder workspace folder. 
2. In Flex Builder, go to the File menu and select "Import".
3. Browse to your Flex Builder workspace folder.
4. Click "Finish". This will import the project.
5. Build the project.
6. Launch the application from the Run menu.

C. Usage Instructions

Run the app, you should see the captions appear.  Seeking should always show the correct caption at the correct time.

* IMPORTANT NOTE: The sample app loads the captioning plugin statically. Due to Flash Player security, you will not be able to load 
the plugin dynamically unless you run the sample app from a Web server or localhost, i.e., "http://localhost/CaptioningSample.html".
Both the plugin and the player loading the plugin must be run from a Web server or localhost.

