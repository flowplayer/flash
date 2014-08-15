Sample Application: Example Player

A. Overview

This sample application demonstrates the playback of various MediaElements within the OSMF framework.
Its purpose is to demonstrate how the MediaElement class can be used to implement a wide variety of
media scenarios, from simple cases (e.g. video, audio, image, SWF), to complex cases (e.g. dynamic
streaming video, embedded chromeless SWF player, sequence of videos, proxy elements).  It also shows
some error cases (e.g. streaming video with an invalid URL). 

B. Installation Instructions (Flex Builder)

1. Unzip/copy the ExamplePlayer project into your Flex Builder workspace folder. 
2. In Flex Builder, go to the File menu and select "Import".
3. Select "General", then "Existing Projects into Workspace", and click "Next".
4. Choose "Select root directory" and "Browse".
5. Browse to your Flex Builder workspace folder.
6. Select the checkbox next to "ExamplePlayer", and click "Finish".  This will import the project.
7. Build the project.
8. Launch the application from the Run menu.

If you're compiling this example with the Flex 4.0 SDK, you need to specify that they use the Halo
theme rather than the default Spark theme. The easiest way to do this is to edit the flex-config.xml
file in your SDK's "frameworks" folder and replace the existing <theme> content with the following:

<!-- List of CSS or SWC files to apply as a theme. -->
<theme>
   <filename>themes/Halo/halo.swc</filename>
   <filename>themes/Spark/spark.css</filename>
</theme>

The changes will take effect the next time you restart Flash Builder. 

Note that some of the examples (such as the Chromeless SWF examples) require that the Example Player be
launched from the network rather than the file system.  Here's how to do so.

1. Build the project.
2. Copy the ExamplePlayer.swf file from the bin (or bin-debug) folder to your web server.
3. In Flex Builder, go to the Run menu and select "Run Configurations" (or "Debug Configurations").
4. Create a new configuration for the ExamplePlayer project.
5. Under "URL or path to launch", uncheck the "Use defaults" checkbox.
6. In the "Run" (or "Debug") text box, enter the URL of the ExamplePlayer.swf file on your web server.
7. Click the "Run" (or "Debug") button.  

C. Usage Instructions

On the left hand side is a list of examples.  Each example represents a MediaElement that will be loaded
into a MediaPlayer for playback.  When you click on an example in the list, a description of the example
will appear in the upper right, and a control panel which allows interaction will appear in the lower
right.

The code for each example is in org.osmf.examples.AllExamples.as.
