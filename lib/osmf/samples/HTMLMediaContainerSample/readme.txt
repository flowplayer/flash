Sample Application: HTMLMediaContainer

A. Overview

This sample application demonstrates part of the framework's container feature, that allows media
elements to be contained.

The HTMLMediaContainer class implements the IMediaContainer interface. On initializing, the object
reaches out to the HTML document that is hosting the Flash application using Flash's external
interface feature. A JavaScript API gets added to the HTML element that allows elements in
JavaScript to be recognized as media elements by the Flash application.  

This sample demonstrates the playback of a video in Flash, in parallel with a series of banner
image that get loaded and displayed from HTML. The composition as a whole is managed from
Flash (see HTMLMediaContainerSample.as), whereas the usage of the JavaScript API can be found in the
HTML code (see html-template/index.template.html).

B. Installation Instructions (Flex Builder)

1. Unzip/copy the HTMLMediaContainerSample project into your Flex Builder workspace folder. 
2. In Flex Builder, go to the File menu and select "Import".
3. Select "General", then "Existing Projects into Workspace", and click "Next".
4. Choose "Select root directory" and "Browse".
5. Browse to your Flex Builder workspace folder.
6. Select the checkbox next to "HTMLMediaContainerSample", and click "Finish".  This will import the project.
7. Build the project.
8. Launch the application from the Run menu.

Note that the sample loads assets from the web, so please make sure to be connected to the
internet when trying them out.

C. Usage Instructions

On running the sample, clicking the banner that shows above the video content will result in
the composition as a whole being paused. Clicking the banner once more will resume playback.