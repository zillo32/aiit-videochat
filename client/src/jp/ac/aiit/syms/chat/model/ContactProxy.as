package jp.ac.aiit.syms.chat.model
{
	import flash.display.*;
	import flash.events.*;
	
	import jp.ac.aiit.syms.ApplicationFacade;
	import jp.ac.aiit.syms.chat.view.*;
	import jp.ac.aiit.syms.room.model.User;
	import jp.ac.aiit.syms.room.model.service.RoomService;
	
	import mx.collections.ArrayCollection;
	import mx.logging.*;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class ContactProxy extends Proxy implements IProxy
	{

		public static const NAME:String = "ContactProxy";
		
		public function ContactProxy( data:Object = null )
		{
            super ( NAME, data );
		}

		public function sendMessenge(roomId:String, msg:String):void {
			roomService.sendPublicMessage(roomId, msg);
		}
		
		
		/**
		 * 参加者一覧情報の取得
		 */
		public function getMemberList():void
		{
			roomService.onShowChanged();
		}
		
		private var roomId:String;		
		private var roomService:RoomService = RoomService.getInstance();
	}
}