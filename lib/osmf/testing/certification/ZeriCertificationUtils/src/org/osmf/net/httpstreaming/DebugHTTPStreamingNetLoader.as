package org.osmf.net.httpstreaming
{
	public class DebugHTTPStreamingNetLoader extends HTTPStreamingNetLoader
	{/*
		override protected function createNetStream(connection:NetConnection, resource:URLResource):NetStream
		{
			var fileHandler:HTTPStreamingFileHandlerBase = new HTTPStreamingF4FFileHandler();
			var indexHandler:HTTPStreamingIndexHandlerBase = new HTTPStreamingF4FIndexHandler(fileHandler);
			var httpNetStream:HTTPNetStream = new HTTPNetStream(connection, indexHandler, fileHandler);
			httpNetStream.manualSwitchMode = true;
			httpNetStream.indexInfo = HTTPStreamingUtils.createF4FIndexInfo(resource);
			return httpNetStream;
		}
		*/
		public function DebugHTTPStreamingNetLoader()
		{
			super();
		}
	}
}