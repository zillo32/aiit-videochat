package jp.ac.aiit.syms.room.model
{
	import flash.external.ExternalInterface;
	
	import jp.ac.aiit.syms.room.model.service.HallService;
	import jp.ac.aiit.syms.util.UiHelper;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class ChatRoomProxy extends Proxy implements IProxy
	{
	
		/**
		 * Proxyクラス名称の宣言
		 */
		public static const NAME:String = "chatroom.model.ChatRoomProxy";
		

		/**
		 * Notificationの定義
		 */
		// 部屋一覧の更新
		public static const ROOM_LIST_REFRESHED:String = NAME + ".ROOM_LIST_REFRESHED";
	
	
		/**
		 * インスタンス変数
		 */
		// 部屋の一覧
		private var roomlist:ArrayCollection;
		private var hallService:HallService = HallService.getInstance(); 
		private var uiHelper:UiHelper;
		/**
		 * ChatRoomProxy()
		 * コンストラクタ
		 */
		public function ChatRoomProxy( data:Object = null )
		{
			super( NAME, data );
			uiHelper = UiHelper(facade.retrieveProxy(UiHelper.NAME));
		}
		
		/**
		 * getChatRoomList()
		 * 部屋一覧の取得
		 */
		public function getChatRoomList(roomType:String):ArrayCollection
		{
			var chatroomlist:ChatRoomList = new ChatRoomList();
			if(roomType == "1") {
				var commList:Array = ExternalInterface.call( "getCommunityList" );
	  			if( commList != null ){
				
					for(var i:int=0; i < commList.length; i++){ 
	
	 					var chatroom:ChatRoom = new ChatRoom;
						chatroom.roomId = commList[i].roomId;
						chatroom.roomName = commList[i].roomName;
						chatroom.roomIconUrl = commList[i].roomIcon;
						chatroom.roomType = "1"; // コミュニティ情報
						chatroomlist.rooms.addItem( chatroom );
					}
				}  
				this.roomlist = chatroomlist.rooms;
			} else {
				var roomlist:ArrayCollection = chatroomlist.ChatRoomList2(roomType);
				this.roomlist = roomlist;
			}			

			return this.roomlist;
		}
		
	
		/**
		 * joinTheRoom()
		 * 部屋一覧の更新
		 */
		public function joinTheRoom( user:User, roomName:String, roomId:String ):void
		{
			hallService.createRoom(roomName, roomId);
				
		}
		
		public function getCurrentChatRoom():ChatRoom
		{
			var room:String = uiHelper.getCurrentRoom();
			var roomId:String = uiHelper.getCurrentRoomId();
			var rooms:ArrayCollection = uiHelper.getRooms();
			var chatroom:ChatRoom = new ChatRoom;
			for(var i:int =0; i< rooms.length; i++)
			{
				if(rooms[i].roomId == roomId) {

					chatroom.roomId = rooms[i].roomId;
					chatroom.roomIconUrl = rooms[i].roomIconUrl;
					chatroom.roomName = rooms[i].roomName;
					chatroom.joinedMemberCount = rooms[i].joinedMemberCount;
					break;
				}
				
			}
			return chatroom;
		}
		
		public function getAudiences(roomId:String):void
		{
			
			hallService.getCurrentRoomAudiences(roomId);
		}
		
		// ユーザが二重だログインした時チェック
		public function getCurrentAudiences(roomId:String):void
		{
			hallService.getAudiences(roomId);
		}
		
		public function leavePreRoom(userName:String, roomId:String):void
		{
			hallService.leavePreviousRoom(userName, roomId);
		}
		
		public function walkinNextRoom(userName:String):void
		{
			hallService.walkinNexRoom(userName);
		}
		
		public function checkRepeatJoinRoom(userName:String):Boolean
		{
			var joinFlg:Boolean = false;
			var audiences:Array = uiHelper.getCurrentRoomUsers();
			for(var index:String in audiences)
			{
				if(audiences[index].nickName == userName)
				{
					joinFlg = true;
					break;
				}
			}
		
			return joinFlg;
		}
		
		public function checkDoubleRoomJoin(userName:String, actFlg:String):Boolean
		{	var joinFlg:Boolean = false;
			if(actFlg == "1"){
				joinFlg = true;
			}
			return joinFlg;
		}
		
		// ウィンドウを２個開きのチェック
		public function checkJoinOtherRoom(userName:String, roomId:String):void
		{
			hallService.checkDoubleJoinRoom(userName, roomId);
		} 
	}
}