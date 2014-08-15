Sample Library: Loggers

A. Overview

This library demonstrates how the OSMF's logging feature can be hooked up with the logging
feature from Flex.

The framework's logging feature is described in detail at its specification page:
http://opensource.adobe.com/wiki/display/osmf/Logging+Framework+Specification

B. Usage Instructions

On building an application with OSMF and Flex, this library can be used to route OSMF
logging messages to Flex, like so:

private var logger:Logger;
private var loggerFactory:FlexLogWrapper;

...

loggerFactory = new FlexLogWrapper();
Log.loggerFactory = new FlexLoggerWrapper(loggerFactory);

logger = Log.getLogger("[ClassName]");
logger.debug("initLogging finished");

...