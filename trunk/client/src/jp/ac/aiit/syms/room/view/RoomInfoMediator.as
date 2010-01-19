package jp.ac.aiit.syms.room.view
{
	import flash.events.Event;
	
	import jp.ac.aiit.syms.ApplicationFacade;
	import jp.ac.aiit.syms.room.model.*;
	import jp.ac.aiit.syms.room.model.service.HallService;
	import jp.ac.aiit.syms.room.model.service.RoomService;
	import jp.ac.aiit.syms.util.UiHelper;
	
	import mx.controls.Alert;
	import mx.core.Application;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	/**
	 * 
	 * ChatRoomMediator
	 * 
	 */
	public class RoomInfoMediator extends Mediator implements IMediator
	{

		//------------------------------------
		// 定数
		//------------------------------------
		public static const NAME:String = "RoomInfoMediator";
		public static const MEMBER_LIST : Number =	1;
		public static const ROOM_LIST : Number =	0;
		
		//------------------------------------
		// インスタンス変数
		//------------------------------------
		
		private var roomService:RoomService;
		private var chatRoomProxy:ChatRoomProxy;
		private var uiHelper:UiHelper;
		private var hallService:HallService;
		/**
		 * 
		 * ChatRoomMediator()
		 * コンストラクタ
		 * 
		 */
		public function RoomInfoMediator( viewComponent:Object )
		{
			super( NAME, viewComponent );
			facade.registerMediator( new RoomListMediator( panel.roomlist ) );
			facade.registerMediator(new MemberListMediator(panel.memberlist));
			
			roomService = RoomService(facade.retrieveProxy(RoomService.NAME));
			chatRoomProxy = ChatRoomProxy(facade.retrieveProxy(ChatRoomProxy.NAME));
			uiHelper = facade.retrieveProxy(UiHelper.NAME) as UiHelper;	
			hallService = facade.retrieveProxy(HallService.NAME) as HallService;
			
			panel.addEventListener(RoomInfo.RETURN_TO_ROOMLIST, returnToRoomList);
			panel.addEventListener(RoomInfo.VIEW_MEMBERLIST, viewMemberListHandler);		
			
			sendNotification(ApplicationFacade.ROOM_LIST);

		}
		
		
		
		// --[ Notification Handler ] -------------------------------------------------
		/**
		 * 
		 * listNotificationInterests()
		 * このMediatorが受け取るNotificationを宣言する
		 * 
		 */
		override public function listNotificationInterests():Array
		{
//			trace("passing: RoomListMediator.listNotificationInterests()");
			return [
					ApplicationFacade.ROOM_LIST,
					ApplicationFacade.MEMBER_LIST,
					ApplicationFacade.LEAVE_CURRENT_ROOM,
					ApplicationFacade.VIEW_MEMBERS_LIST
			];
		}

		/**
		 * 
		 * handleNotification()
		 * Notification発生時の振る舞いを定義する
		 * 
		 */
		override public function handleNotification( notification:INotification ):void
		{
			trace("handleNotification()");
			switch ( notification.getName() )
			{
				case ApplicationFacade.ROOM_LIST:
					panel.roomInfo.selectedIndex = ROOM_LIST;
					panel.joinedRoomFlg = false;
					break;
				case ApplicationFacade.MEMBER_LIST:
					panel.roomInfo.selectedIndex = MEMBER_LIST;
					panel.joinedRoomFlg = true;
					var curRoom:ChatRoom = chatRoomProxy.getCurrentChatRoom();
					panel.memberlist.label = curRoom.roomName + ":" + "参加者";
					break;
				case ApplicationFacade.LEAVE_CURRENT_ROOM:
					panel.roomInfo.selectedIndex = ROOM_LIST;
					panel.joinedRoomFlg = false;
					panel.memberlist.label = "参加者一覧";
					break;	
				case ApplicationFacade.VIEW_MEMBERS_LIST:
					panel.roomInfo.selectedIndex = MEMBER_LIST;
					panel.joinedRoomFlg = false;
					var currentRoom:ChatRoom = chatRoomProxy.getCurrentChatRoom();
					panel.memberlist.label = currentRoom.roomName + ":" + "参加者";
					break;	
			}		
		}
		
		/**
		 * 
		 * panel()
		 * ビューコンポーネントの取得
		 *  
		 */
		private function get panel():RoomInfo  {
			return viewComponent as RoomInfo;
		}
		
		private function returnToRoomList(event:Event = null) :void {
			var roomName:String = uiHelper.getCurrentRoom();
			var roomId:String = uiHelper.getCurrentRoomId();
			roomService.leave(roomId);
			
		}
		
		private function viewMemberListHandler(event:Event = null):void
		{
			// 選択された部屋の参加者を覘き
			var roomId:String = "";
			var roomName:String = "";
			if (panel.roomlist.chatRoomGrid.selectedItem)
			{
				Application.application.room = panel.roomlist.chatRoomGrid.selectedItem.roomName;
				roomId = panel.roomlist.chatRoomGrid.selectedItem.roomId;
				roomName = panel.roomlist.chatRoomGrid.selectedItem.roomName;
				uiHelper.setCurrentRoom(roomName);
				uiHelper.setCurrentRoomId(roomId);
				chatRoomProxy.getAudiences(roomId);
			} 
			else if (panel.roomlist.chatRoomGrid_mymix.selectedItem)
			{
				Application.application.room = panel.roomlist.chatRoomGrid_mymix.selectedItem.roomName;
				roomId = panel.roomlist.chatRoomGrid_mymix.selectedItem.roomId;
				roomName = panel.roomlist.chatRoomGrid_mymix.selectedItem.roomName;
				uiHelper.setCurrentRoomId(roomId);
				uiHelper.setCurrentRoom(roomName);
				chatRoomProxy.getAudiences(roomId);
			}
			else if (panel.roomlist.chatRoomGrid_open.selectedItem)
			{
				Application.application.room = panel.roomlist.chatRoomGrid_open.selectedItem.roomName;
				roomId = panel.roomlist.chatRoomGrid_open.selectedItem.roomId;
				roomName = panel.roomlist.chatRoomGrid_open.selectedItem.roomName;
				uiHelper.setCurrentRoomId(roomId);
				uiHelper.setCurrentRoom(roomName);
				chatRoomProxy.getAudiences(roomId);
			} 
			else
			{
				Alert.show( '部屋が選択されていません', '部屋一覧' );
			}
		}	
		
	}
}

