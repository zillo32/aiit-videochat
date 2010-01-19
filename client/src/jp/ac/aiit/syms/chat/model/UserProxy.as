package jp.ac.aiit.syms.chat.model
{
	import flash.external.ExternalInterface;
	
	import jp.ac.aiit.syms.room.model.User;
	import jp.ac.aiit.syms.room.model.service.HallService;
	import jp.ac.aiit.syms.util.UiHelper;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class UserProxy extends Proxy implements IProxy
	{
		
		public static const NAME:String = "UserProxy";
		public var me:User;
		
		public function UserProxy ( data:Object = null ) 
        {
            super ( NAME, data );
			uiHelper = facade.retrieveProxy(UiHelper.NAME ) as UiHelper;
            //dummyObject
//            me = new User();

			var socialUser:Object = ExternalInterface.call("getSocialUser" );

			var user:User = new User();
 			if( socialUser != null ){
				user.setId ("m" + socialUser.userId);
				user.setNickName(socialUser.userName);
				user.setUserIconUrl(socialUser.userIcon);
			} 

/* [Firebug Console Debug] 
			Logger.info( user.userId + ' - ' + user.nickName + ' - ' + user.userIconUrl ); 
*/
            me = user;
            uiHelper.setCurrentUser(me);
			
			//マイミクリスト情報の設定
			var friendsList:Array = ExternalInterface.call("getFriendList");
			if(friendsList == null) {
				friendsList = new Array();
			}

			uiHelper.setFriendsList(friendsList);
        }
	
		public function logIn():void {
 			
 			hallService.onShowChanged();
 			
 		}
 		
		private var hallService:HallService = HallService.getInstance();
		private var uiHelper:UiHelper;

  	}
}