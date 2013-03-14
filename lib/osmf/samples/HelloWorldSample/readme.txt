Sample Application: Hello World

A. Overview

This sample application demonstrates the simplest possible application that can be built with
the OSMF (see HelloWorld.as). The sample is gradually extended, to demonstrate additional framework
features:

HelloWorld.as: Uses MediaPlayerSprite to play a video.
HelloWorld2.as: Uses MediaPlayer and MediaContainer instead of MediaPlayerSprite.
HelloWorld3.as: Same as HelloWorld2, but centers the content.
HelloWorld4.as: Uses MediaElement and DisplayObjectTrait, rather than MediaPlayerSprite.
HelloWorld5.as: Uses MediaPlayer and DisplayObjectTrait, rather than MediaContainer.
HelloWorld6.as: Uses LightweightVideoElement instead of VideoElement to minimize player size.
HelloWorld7.as: Plays a video, then shows a SWF, then plays another video.

For more detail on this sample, please refer to:
http://blogs.adobe.com/osmf/2009/09/building_a_helloworld_app_with_osmf.html

B. Installation Instructions (Flex Builder)

1. Unzip/copy the HelloWorld project into your Flex Builder workspace folder. 
2. In Flex Builder, go to the File menu and select "Import".
3. Select "General", then "Existing Projects into Workspace", and click "Next".
4. Choose "Select root directory" and "Browse".
5. Browse to your Flex Builder workspace folder.
6. Select the checkbox next to "HelloWorld", and click "Finish".  This will import the project.
7. Build the project.
8. Launch the application from the Run menu.

Note that the sample loads assets from the web, so please make sure to be connected to the
internet when trying them out.

C. Usage Instructions

To switch from HelloWorld.as to HelloWorld2.as, right-click HelloWorld2.as in the Flex
Navigator panel. Select 'Set as Default Application', and launch the application from the
Run menu.