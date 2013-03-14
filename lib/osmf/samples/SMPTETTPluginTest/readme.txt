Sample Application: SMPTETTPluginTest

A. Overview

This sample application demonstrates loading the OSMF SMPTE-TT plugin and using an external 
captioning document to show captions over a video.  Specifically, the sample application contains an 
extension to the spark.components.VideoDisplay control in Flex 4.5.1, 
org.osmf.smpte.tt.SMPTETTVideoDisplay, that loads the SMPTETTPlugin, and allows a developer to 
specify a SMPTETTVideoDisplay.captionsSource property, which is the URL location of a SMPTE-TT or 
WC3 Timed Text TTML file.

When a SMPTETTVideoDisplay.captionsSource file is specified, the SMPTETTPlugin will store the URL 
value and only load the file when the SMPTETTVideoDisplay.showCaptions property is set to true. To 
load the captions, we call SMPTETTVideoDisplay.setUpCaptionsSource() which adds the necessary 
metadata values to the media resource's SMPTETTPluginInfo.SMPTETT_METADATA_NAMESPACE. The metadata 
values we must specify for the captions to load and render are:

1. SMPTETTPluginInfo.SMPTETT_METADATA_KEY_URI, the URL of the caption source document
2. SMPTETTPluginInfo.SMPTETT_METADATA_KEY_SHOWCAPTIONS, a boolean specifying whether or not to 
		display the captions
3. SMPTETTPluginInfo.SMPTETT_METADATA_KEY_MEDIAFACTORY, the MediaFactory instance
4. SMPTETTPluginInfo.SMPTETT_METADATA_KEY_MEDIAPLAYER, the MediaPlayer instance
5. SMPTETTPluginInfo.SMPTETT_METADATA_KEY_MEDIACONTAINER, the MediaContainer instance

The SMPTETTPlugin creates a MediaElement to handle the rendering and layout of caption regions.

B. Requirements

The SMPTETTPlugin requires OSMF 1.6 which targets FlashPlayer 10.2.

A version of the OSMF 1.6 swc file compiled to target FlashPlayer 10 has been included in the libs 
folder of the SMPTETTPlugin project if support for FlashPlayer 10 is required for other applications.

To compile the SMPTETTPlugin to target FlashPlayer 10.0:

1. Import the playerglobal10_3.swc from the libs folder into the SMPTETTPlugin project's 
   library path and set its link type to External.
2. Import the OSMF1_6_FP10.swc from the libs folder into the SMPTETTPlugin project's 
   library path.
2. Remove the referenced Flex SDK from the SMPTETTPlugin project's library path.
3. In the Flex Library Compiler settings panel for the SMPTETTPlugin, select Flex 4.1 as the SDK 
   version so that the compiler will allow 10.0 as a target Flash Player version. 
4. For additional compiler arguments, enter the following:
                -define CONFIG::LOGGING true 
                -define CONFIG::FLASH_10_1 false 
                -define CONFIG::FLASH_10_2 false 
                -define CONFIG::MOCK false 
                -define CONFIG::PLATFORM true

After these changes, the SMPTETTPlugin should be able to compile targeting FlashPlayer 10.0 without 
errors. 

The SMPTETTPluginTest application requires OSMF 1.6 and FlashPlayer 10.2 because it uses the 
spark.components.VideoDisplay control in Flex 4.5.1.

C. Installation Instructions (Flex Builder)

1. Unzip/copy the SMPTETTPlugin project into your Flex Builder workspace folder. 
2. In Flex Builder, go to the File menu and select "Import".
3. Browse to your Flex Builder workspace folder.
4. Click "Finish". This will import the project.
5. Build the project.

6. Unzip/copy the SMPTETTPluginTest project into your Flex Builder workspace folder. 
7. In Flex Builder, go to the File menu and select "Import".
8. Browse to your Flex Builder workspace folder.
9. Click "Finish". This will import the project.
10. Build the project.
11. Launch the application from the Run menu.

D. Usage Instructions

Run the application, select a SMPTE-TT or TTML file from the ComboBox, click the Load Media Resource 
button. The media should start automatically. Click the "CC" button to load the captions. You should 
see the captions appear.  Seeking should always show the correct caption at the correct time.

The SMPTETTPlugin supports many but not all features of the SMPTE-TT and TTML specifications. 

* IMPORTANT NOTE: The sample app loads the SMPTE-TT plugin statically. Due to Flash Player security, you will not be able to load 
the plugin dynamically unless you run the sample app from a Web server or localhost, i.e., "http://localhost/SMPTETTPluginTest.html".
Both the plugin and the player loading the plugin must be run from a Web server or localhost.
