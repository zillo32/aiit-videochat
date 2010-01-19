package jp.ac.aiit.syms.room.model
{
	import flash.external.ExternalInterface;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class SocialUserProxy extends Proxy implements IProxy
	{
		/**
		 * Proxyクラス名称の宣言
		 */
		public static const NAME:String = "chatroom.model.SocialUserProxy";
		

		/**
		 * Notificationの定義
		 */
		// Socialユーザオブジェクトの取得通知
		public static const  SOCIAL_USER_REFRESHED:String  = NAME + ".SOCIAL_USER_REFRESHED";


		/**
		 * SocialUserProxy()
		 * コンストラクタ
		 */
		public function SocialUserProxy( data:Object = null )
		{
			super( NAME, data );
		}
		
		
		/**
		 * ユーザ情報の取得
		 */
		public function getUser():User
		{
			var user:User = new User();
 			var externalUser:Object;
			
			externalUser = ExternalInterface.call("getMixiUser" );
 			
			
			return user;
		}
	
	}
}