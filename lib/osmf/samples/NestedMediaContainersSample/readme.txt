Sample Application: Nested Regions

A. Overview

This sample application demonstrates part of the framework's gateway feature, that allows media
elements to be routed. Gateway objects are of type IMediaGateway. A specialized interface is
IContainerGateway, that specifies gateways that may contain one or more media element children.
The RegionSprite class implements this interface, but derives from Sprite. This constitutes a
media element container that can be staged in Flash. This allows for sending parts of a
composition to predefined regions within a Flash experience.

RegionSprite instances can have child regions. The child regions of a region are laid out using
the same layout mechanism that is available for parallel viewable elements. This sample shows
how to create a nested region, and how to lay out the child regions relative to their parent.

B. Installation Instructions (Flex Builder)

1. Unzip/copy the NestedRegionsSample project into your Flex Builder workspace folder. 
2. In Flex Builder, go to the File menu and select "Import".
3. Select "General", then "Existing Projects into Workspace", and click "Next".
4. Choose "Select root directory" and "Browse".
5. Browse to your Flex Builder workspace folder.
6. Select the checkbox next to "NestedRegionSample", and click "Finish".  This will import the project.
7. Build the project.
8. Launch the application from the Run menu.

Note that the sample loads assets from the web, so please make sure to be connected to the
internet when trying them out.

C. Usage Instructions

The sample is not interactive. Please note that the semi-transparent blue and green areas denote
the child regions. This region background is specifically set from the sample code (using the
region's backgroundColor and backgroundAlpha properties). 