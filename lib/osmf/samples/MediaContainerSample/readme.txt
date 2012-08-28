Sample Application: MediaContainerSample

A. Overview

This sample application demonstrates part of the framework's containers feature, that allows media
elements to be routed. Container objects are of type IMediaContainer.  The MediaContainer class
implements this interface, but derives from Sprite. This constitutes a media element container that
can be staged in Flash. This allows for sending parts of a composition to predefined regions within
a Flash experience.   

B. Installation Instructions (Flex Builder)

1. Unzip/copy the MediaContainerSample project into your Flex Builder workspace folder. 
2. In Flex Builder, go to the File menu and select "Import".
3. Select "General", then "Existing Projects into Workspace", and click "Next".
4. Choose "Select root directory" and "Browse".
5. Browse to your Flex Builder workspace folder.
6. Select the checkbox next to "MediaContainerSample", and click "Finish".  This will import the project.
7. Build the project.
8. Launch the application from the Run menu.

Note that the sample loads assets from the web, so please make sure to be connected to the
internet when trying them out.

C. Usage Instructions

When the sample is running, clicking the top banner will cause it to be moved into another
region (the one below the main content area). Clicking the sky-scraper banner will launch
the IAB site. 