Sample Application: CuePointSample

A. Overview

This sample application demonstrates temporal metadata within the OSMF framework. Its purpose is to demonstrate how the TemporalFacet and TemporalIndentifier classes in the org.osmf.metadata package can be used to inspect, add to, and listen for temporal metadata associated with a media element. The sample uses the new CuePoint class found in org.osmf.elements.

B. Installation Instructions (Flex Builder)

1. Unzip/copy the CuePointSample project into your Flex Builder workspace folder. 
2. In Flex Builder, go to the File menu and select "Import".
3. Browse to your Flex Builder workspace folder.
4. Click "Finish". ÿThis will import the project.
5. Build the project.
6. Launch the application from the Run menu.

C. Usage Instructions

The sample is a Flex application containing a DataGrid in the upper right which shows initially, all the cue points found in the media.  If the user clicks on a navigation cue point in the grid, the media will seek to that cue point.  The TextArea below the media shows the events dispatched by the TemporalFacet class. The "Add a cue point:" area in the lower right allows the user to add an ActionScript cue point at run-time.  The DataGrid can be sorted by the Time column.  If you add an ActionScript cue point and do not see it in the grid, try clicking the Time column and scrolling to the proper place in the grid.
