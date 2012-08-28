/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 *  The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 *  (the "License"); you may not use this file except in
 *  compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 **********************************************************/

package org.osmf.player.errors
{
	import org.flexunit.asserts.*;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;

	public class TestErrorTranslator
	{		
		[Test]
		public function testErrorTranslator():void
		{
			var e:Error;
			
			e = ErrorTranslator.translate(null);
			assertEquals(e.message, ErrorTranslator.UNKNOWN_ERROR);
			
			e = ErrorTranslator.translate(new Error("message"));
			assertEquals(e.message, "message");
			
			// Generic errors:
			
			e = ErrorTranslator.translate(new MediaError(MediaErrorCodes.ARGUMENT_ERROR));
			assertEquals(e.message, ErrorTranslator.GENERIC_ERROR);
			e = ErrorTranslator.translate(new MediaError(MediaErrorCodes.SOUND_PLAY_FAILED));
			assertEquals(e.message, ErrorTranslator.GENERIC_ERROR);
			e = ErrorTranslator.translate(new MediaError(MediaErrorCodes.NETSTREAM_PLAY_FAILED));
			assertEquals(e.message, ErrorTranslator.GENERIC_ERROR);
			e = ErrorTranslator.translate(new MediaError(MediaErrorCodes.NETSTREAM_NO_SUPPORTED_TRACK_FOUND));
			assertEquals(e.message, ErrorTranslator.GENERIC_ERROR);
			e = ErrorTranslator.translate(new MediaError(MediaErrorCodes.DRM_SYSTEM_UPDATE_ERROR));
			assertEquals(e.message, ErrorTranslator.GENERIC_ERROR);
			
			// Networks errors:
			
			e = ErrorTranslator.translate(new MediaError(MediaErrorCodes.IO_ERROR));
			assertEquals(e.message, ErrorTranslator.NETWORK_ERROR);
			e = ErrorTranslator.translate(new MediaError(MediaErrorCodes.SECURITY_ERROR));
			assertEquals(e.message, ErrorTranslator.NETWORK_ERROR);
			e = ErrorTranslator.translate(new MediaError(MediaErrorCodes.ASYNC_ERROR));
			assertEquals(e.message, ErrorTranslator.NETWORK_ERROR);
			e = ErrorTranslator.translate(new MediaError(MediaErrorCodes.HTTP_GET_FAILED));
			assertEquals(e.message, ErrorTranslator.NETWORK_ERROR);
			e = ErrorTranslator.translate(new MediaError(MediaErrorCodes.NETCONNECTION_REJECTED));
			assertEquals(e.message, ErrorTranslator.NETWORK_ERROR);
			e = ErrorTranslator.translate(new MediaError(MediaErrorCodes.NETCONNECTION_APPLICATION_INVALID));
			assertEquals(e.message, ErrorTranslator.NETWORK_ERROR);
			e = ErrorTranslator.translate(new MediaError(MediaErrorCodes.NETCONNECTION_TIMEOUT));
			assertEquals(e.message, ErrorTranslator.NETWORK_ERROR);
			e = ErrorTranslator.translate(new MediaError(MediaErrorCodes.NETCONNECTION_FAILED));
			assertEquals(e.message, ErrorTranslator.NETWORK_ERROR);
			e = ErrorTranslator.translate(new MediaError(MediaErrorCodes.DVRCAST_SUBSCRIBE_FAILED));
			assertEquals(e.message, ErrorTranslator.NETWORK_ERROR);
			e = ErrorTranslator.translate(new MediaError(MediaErrorCodes.DVRCAST_STREAM_INFO_RETRIEVAL_FAILED));
			assertEquals(e.message, ErrorTranslator.NETWORK_ERROR);
			
			// Not found errors:
			
			e = ErrorTranslator.translate(new MediaError(MediaErrorCodes.URL_SCHEME_INVALID));
			assertEquals(e.message, ErrorTranslator.NOT_FOUND_ERROR);
			e = ErrorTranslator.translate(new MediaError(MediaErrorCodes.MEDIA_LOAD_FAILED));
			assertEquals(e.message, ErrorTranslator.NOT_FOUND_ERROR);
			e = ErrorTranslator.translate(new MediaError(MediaErrorCodes.NETSTREAM_STREAM_NOT_FOUND));
			assertEquals(e.message, ErrorTranslator.NOT_FOUND_ERROR);
			e = ErrorTranslator.translate(new MediaError(MediaErrorCodes.NETSTREAM_FILE_STRUCTURE_INVALID));
			assertEquals(e.message, ErrorTranslator.NOT_FOUND_ERROR);
			e = ErrorTranslator.translate(new MediaError(MediaErrorCodes.DVRCAST_CONTENT_OFFLINE));
			assertEquals(e.message, ErrorTranslator.NOT_FOUND_ERROR);
			
			// Plugin failure errors:
			
			e = ErrorTranslator.translate(new MediaError(MediaErrorCodes.PLUGIN_IMPLEMENTATION_INVALID));
			assertEquals(e.message, ErrorTranslator.PLUGIN_FAILURE_ERROR);
		}
	}
}