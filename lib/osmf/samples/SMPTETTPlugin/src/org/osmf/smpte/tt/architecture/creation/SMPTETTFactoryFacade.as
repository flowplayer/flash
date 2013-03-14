package org.osmf.smpte.tt.architecture.creation
{
	import org.osmf.smpte.tt.loader.SMPTETTLoader;
	import org.osmf.smpte.tt.media.SMPTETTProxyElement;
	import org.osmf.smpte.tt.media.SMPTETTProxyElementAsync;
	import org.osmf.smpte.tt.parsing.SMPTETTParser;
	import org.osmf.smpte.tt.parsing.SMPTETTParserAsync;

	
	public class SMPTETTFactoryFacade
	{
		private static var _loaderClz:Class = SMPTETTLoader;
		private static var _proxyClz:Class = SMPTETTProxyElementAsync;
		private static var _parserClz:Class = SMPTETTParserAsync;
		
		//private static var _loaderClz:Class = SMPTETTLoader;
		//private static var _proxyClz:Class = SMPTETTProxyElement;
		//private static var _parserClz:Class = SMPTETTParser;
		
		public static function getSMPTETTLoader():SMPTETTLoader
		{
			return new _loaderClz();
		}
		public static function setSMPTETTLoader(v:Class):void
		{
			_loaderClz = v;
			
		}
		
		public static function getSMPTETTProxyElement():SMPTETTProxyElement
		{
			return new _proxyClz()
		}
		public static function setSMPTETTProxyElement(v:Class):void
		{
			_proxyClz = v;
		}
		
		public static function getSMPTETTParser():SMPTETTParser
		{
			return new _parserClz()
		}
		public static function setSMPTETTParser(v:Class):void
		{
			_parserClz = v;
		}
	}
}