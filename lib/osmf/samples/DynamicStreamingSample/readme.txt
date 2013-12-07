Sample Application: DynamicStreamingSample

A. Overview

This sample application demonstrates dynamic stream switching within the OSMF framework. Its purpose is to demonstrate how the various classes in the org.osmf.net.dynamicstreaming package can be used to dynamically stream a profile of streams represented by a DynamicStreamingResource object. 

This sample application contains a SMIL parser.  It downloads a sample SMIL file containing a dynamic stream switching profile (this is the same SMIL format used by the default FMS install), and parses it into a DynamicStreamingResource object.

B. Installation Instructions (Flex Builder)

1. Unzip/copy the DynamicStreamingSample project into your Flex Builder workspace folder. 
2. In Flex Builder, go to the File menu and select "Import".
3. Browse to your Flex Builder workspace folder.
4. Click "Finish". ÿThis will import the project.
5. Build the project.
6. Launch the application from the Run menu.

C. Usage Instructions

This sample application contains several test assets, most of which are SMIL files but also contains a few "regular" assets, meaning non-dynamic stream switching assets.  The new dynamic stream switching classes can handle a DynamicStreamingResource object (for dynamic stream switching) or an IURLResource for "regular" streaming or progressive download content.  The sample app plays both and contains sample content for a progressive download file and a streaming file to prove this functionality.

The sample application provides a user interface for manually switching up or down as well as an informational text area control showing the information available to a player.  This information includes:
1. When a switching change has been requested and the reason for the switch request (i.e., "move up since" or "moving down due to insufficient buffer length", etc).
2. When a switching change is "complete", meaning the change is in the buffer and is now visible to the end user.
3. The current streaming profile index and its bitrate.

When the Auto/Manual button is selected, the player goes in and out of auto switching mode.  The player is smart enough to know whether a switch up or down is possible based on the currently rendering index of the switching profile (the contents of the DynamicStreamingResource object) and therefore enables/disables the switch up/down buttons ("+" and "-" respectively) when appropriate.  The auto/manual switching buttons are disabled while a switch is in progress.

It is important to understand the switching sequence from the client side. The process for a switch involves the following sequence:
1. The client code makes a switch change request (based on a switching rule's recommendation or a manual switch request).
2. The client receives a NetStream.Play.Transition info code, which means the server has successfully accepted the switch and is in the process of switching (or a NetStream.Play.Failed if the server is unable to switch).
3. The client receives a NetStream.Play.TransitionComplete via the onPlayStatus callback. This indicates the switch has completed and is visible to the user.

*** Important notes about seeking and switching in the sample application ***
- If you request a manual switch up or down and then seek before the NetStream.Play.Transition message is received, the switch is ignored.
- If you request a manual switch up or down and wait for the NetStream.Play.Transition, then seek, the server will make the switch and return the new stream at that seek location but no NetStream.Play.TransitionComplete message will come due to the buffer flush caused by the seek (the TransitionComplete is a data message in the buffer).
- The OSMF framework does not expose the NetStream.Play.Transition message, this was design decision, so the only way to know it happened is to "tail -f" the flashlog.txt file.  This tracing is due to the DEBUG const set to true in the DynamicNetStream class.


