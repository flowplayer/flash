This project is part of the OSMFPlayer project. It defines an AIR application that listens to the OSMFPlayer emitting debugging messages.

Usage

* Compile the application, and run it outside of Flex Builder.
* Compile the OSMFPlayer application, and run it. On media loading and playing back, debug messages will appear on the debug console.
* Anything that matches the regular extension that is being entered in the message filter box gets filtered out of the listing. So for example, when "\org.osmf.layout" is set, no layout renderer messages should show. To also suppress, say DVRCast messages, the filter could read:"\org.osmf.(layout|net.dvr)", for example.

The enclosed testCertificate's password is "Test".

OSMFPlayer debug console support can be disabled by changing the OSMFPlayer project's compiler arguments to "-define CONFIG::DEBUG false".