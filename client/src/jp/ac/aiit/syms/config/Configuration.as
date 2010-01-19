package jp.ac.aiit.syms.config
{
	import flash.external.ExternalInterface;
	
	import org.osflash.thunderbolt.Logger;
	
	public class Configuration
	{
		
		private static const REMOTE_DEVELOPMENT_URI:String = "rtmp://PATH_TO_YOUR_HOST/Red5VideoChat/hall";  // 開発版
		private static const REMOTE_PRODUCTION_URI:String = "rtmp://PATH_TO_YOUR_HOST/Red5VideoChat/hall";   // 公開版

		private static const REMOTE_SMILES_URL:String =  "http://PATH_TO_YOUR_HOST/img/";
		private static const REMOTE_MIXI_SMILES_URL:String = "http://PATH_TO_YOUR_HOST/mixiicons/";

		private static const MIXI_FRIENDS_URL:String = "http://mixi.jp/show_friend.pl";
		private static const MIXI_COMMUNITY_URL:String = "http://mixi.jp/view_community.pl";
		

		public static function getRemoteURI():String
		{
			Logger.info('start:getRemoteURI()...');

			// アプリケーション環境情報をJavaScript関数から取得
			var appenv:String = ExternalInterface.call( "getApplicationEnvironment" );
			var result:String = REMOTE_DEVELOPMENT_URI;
//			var result:String = REMOTE_PRODUCTION_URI;

//			Logger.info('start:getRemoteURI()...');
			
			switch ( appenv ) {
				case 'development':
					result = REMOTE_DEVELOPMENT_URI;
//					Logger.info('env:development...');
					break;
				case 'openbeta':
					result = REMOTE_PRODUCTION_URI;
//					Logger.info('env:openbeta...');
					break;
			}
			
//			Logger.info('end:getRemoteURI()...');
			return result; 
		}
		
		public static function getRemoteSmilesURI(strKbn:String):String
		{
			if(strKbn == "mixi") {
				return REMOTE_MIXI_SMILES_URL;
			} 
			return REMOTE_SMILES_URL;
		}
		
		public static function getMixiFriendsURL():String
		{
			return MIXI_FRIENDS_URL;
		}

		public static function getCommunityURL():String
		{
			return MIXI_COMMUNITY_URL;
		}

		public function Configuration()
		{
		}

	}
}