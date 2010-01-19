package jp.ac.aiit.syms.room.controller
{
	import jp.ac.aiit.syms.chat.model.UserProxy;
	import jp.ac.aiit.syms.room.model.*;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class WalkInTheRoomCommand extends SimpleCommand implements ICommand
	{
		override public function execute( note:INotification ):void
		{
			
			// 部屋の取り出し
			var room:Object = note.getBody();
			var roomName:String = room["roomName"];
			var roomId:String = room["roomId"];
			
			// ユーザの取り出し
//			var userproxy:SocialUserProxy = facade.retrieveProxy( SocialUserProxy.NAME ) as SocialUserProxy;
//			var user:User = userproxy.getUser();
			
			//DummyObject
			var userProxy:UserProxy = facade.retrieveProxy(UserProxy.NAME ) as UserProxy;
			var user :User = userProxy.me;

			// 入室
			var roomproxy:ChatRoomProxy = facade.retrieveProxy( ChatRoomProxy.NAME ) as ChatRoomProxy;
			roomproxy.joinTheRoom( user, roomName, roomId ); 
			
		}

	}

}
