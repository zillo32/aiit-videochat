package jp.ac.aiit.syms.room.view
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	
	import jp.ac.aiit.syms.ApplicationFacade;
	import jp.ac.aiit.syms.chat.model.ContactProxy;
	import jp.ac.aiit.syms.chat.model.UserProxy;
	import jp.ac.aiit.syms.room.model.*;
	import jp.ac.aiit.syms.room.model.service.HallService;
	import jp.ac.aiit.syms.room.model.service.RoomService;
	import jp.ac.aiit.syms.util.UiHelper;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.events.CloseEvent;
	import mx.events.DataGridEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	/**
	 * 
	 * ChatRoomMediator
	 * 
	 */
	public class RoomListMediator extends Mediator implements IMediator
	{

		//------------------------------------
		// 定数
		//------------------------------------
		public static const NAME:String = "chatroom.view.ChatRoomMediator";
		
		//------------------------------------
		// インスタンス変数
		//------------------------------------
		private var chatroomProxy:ChatRoomProxy;
		private var userProxy:UserProxy;
		private var contactProxy:ContactProxy;
		private var roomService:RoomService;
		private var uiHelper:UiHelper;
		private var hallService:HallService;
		
		//新しい部屋名称（強制再入室の部屋名）
		private var walkinNewRoom:String;
		/**
		 * 
		 * ChatRoomMediator()
		 * コンストラクタ
		 * 
		 */
		public function RoomListMediator( viewComponent:Object )
		{
			super( NAME, viewComponent );
			
			chatroomProxy = facade.retrieveProxy( ChatRoomProxy.NAME ) as ChatRoomProxy;
			userProxy = facade.retrieveProxy(UserProxy.NAME) as UserProxy;
			contactProxy = facade.retrieveProxy(ContactProxy.NAME) as ContactProxy;
			roomService = facade.retrieveProxy(RoomService.NAME) as RoomService;
			uiHelper = facade.retrieveProxy(UiHelper.NAME) as UiHelper;
			hallService = facade.retrieveProxy(HallService.NAME) as HallService;

// カスタムソートは弊害が出たのでとりあえず削除			
//			setCustomSort();

			setDataProvider( chatroomProxy.getChatRoomList("1") );
			setMyMixDataProvider( chatroomProxy.getChatRoomList("2") );
			setOpenDataProvider( chatroomProxy.getChatRoomList("3") );
			applyCustomSort();
			panel.addEventListener(ApplicationFacade.WALK_IN_ROOM_BUTTON_CLICK, checkUserRepeatJoinRoom);
			connectToRed5Server();
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
				ChatRoomProxy.ROOM_LIST_REFRESHED,
				ApplicationFacade.CREATE_NEW_ROOM,
				ApplicationFacade.USER_JOIN_ROOM_STATUS,
				ApplicationFacade.ROOM_LIST_REFRESHED,
				ApplicationFacade.DOUBLE_ROOM_JOIN_CHECK,
				ApplicationFacade.NEXT_ROOM_WALK_IN,
				ApplicationFacade.WALK_IN_NEXT_ROOM,
				ApplicationFacade.WALK_IN_ROOM_BUTTON_CLICK
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
				case ChatRoomProxy.ROOM_LIST_REFRESHED:
					this.setDataProvider( this.chatroomProxy.getChatRoomList("1") );
					this.setMyMixDataProvider(this.chatroomProxy.getChatRoomList("2"));
					this.setOpenDataProvider(this.chatroomProxy.getChatRoomList("3"));
					break;
				case ApplicationFacade.CREATE_NEW_ROOM:
					// 参加者一覧情報の取り出し
					contactProxy.getMemberList();
					break;
				case ApplicationFacade.USER_JOIN_ROOM_STATUS:
					// 二重だログインした時チェック
					var userName:String = uiHelper.getCurrentUser().nickName;
					if(!chatroomProxy.checkRepeatJoinRoom(userName)) {
						onWalkInTheRoom(null);
					} else {
						Alert.show( '同一ユーザ既に入室しました、二重ログインできません。', '部屋一覧' );
						Application.application.roomInfo.repeatJoinFlg = true;
						//  退室ボタンと入室ボタンを切り替える
						Application.application.roomInfo.memberlist.customPanel2.btnChange("repeatWalkIn");
					}
					break;
				case ApplicationFacade.DOUBLE_ROOM_JOIN_CHECK:
					// ２個ウィンドウを開きのチェック
					var uName:String = uiHelper.getCurrentUser().nickName;
					var actFlg:String = notification.getBody() as String;
					if(!chatroomProxy.checkDoubleRoomJoin(uName, actFlg)) {
						onWalkInTheRoom(null);
					} else {
						//強制入室かどうかの判断
						reEnterRoomMethod();
					}
					break;
					
				 case ApplicationFacade.ROOM_LIST_REFRESHED:
				 		var status:Object = notification.getBody() as Object;
				 		if(status["room"] == uiHelper.getCurrentRoomId()) {
				 			var soundTrans: SoundTransform  = new SoundTransform(1, 0);
					 		if(status["flag"] == "join") {
					 			var joinRoomSound:Sound = new panel.joinRommSoundClass as Sound;
					 			if ( uiHelper.getPlaySoundStatus() )
					 			{
					 				joinRoomSound.play(0, 0, soundTrans);
					 			}
					 		} else {
					 			var leaveRoomSound:Sound = new panel.leaveRommSoundClass as Sound;
					 			if ( uiHelper.getPlaySoundStatus() )
					 			{
						 			leaveRoomSound.play(0, 0, soundTrans);
						 		}
					 		}
				 		}
				 	break;
				 
				 case ApplicationFacade.NEXT_ROOM_WALK_IN:
				 		var name:String = uiHelper.getCurrentUser().nickName;
						chatroomProxy.walkinNextRoom(name);
				 	break;	
				 case ApplicationFacade.WALK_IN_NEXT_ROOM:
				 		var curName:String = uiHelper.getCurrentUser().nickName;
				 		var walkinName:String = notification.getBody() as String;
				 		var nextRoom:String = uiHelper.getNextRoom();
				 		if(nextRoom != null && curName == walkinName) {
				 			onWalkInTheRoom(null);
				 			uiHelper.setNextRoom(null);
				 		}
				 	break;	
				 case ApplicationFacade.WALK_IN_ROOM_BUTTON_CLICK:
				 	checkUserRepeatJoinRoom();
				 	break;			
			}
		}
		
		/**
		 * 
		 * panel()
		 * ビューコンポーネントの取得
		 *  
		 */
		private function get panel():RoomList  {
			return viewComponent as RoomList;
		}
		
		/**
		 * 
		 * setDataProvider()
		 * 部屋一覧を更新する
		 * 
		 */
		private function setDataProvider( provider:ArrayCollection ):void
		{
			panel.chatRoomGrid.dataProvider = provider;
		}
		
		private function setMyMixDataProvider(provider:ArrayCollection) :void
		{
			panel.chatRoomGrid_mymix.dataProvider = provider;
		}
		
		private function setOpenDataProvider(provider:ArrayCollection):void
		{
			panel.chatRoomGrid_open.dataProvider = provider;
		}
		
		/**
		 * オープンルームが一番上に来る怪しいソート関数
		 */
		private function setCustomSort():void
		{
			panel.joinedMemberCount.sortCompareFunction = function(obj1:Object, obj2:Object):int {
				if(obj1.roomId == "999999999" ){
					return 1;
				}
				if( obj1.joinedMemberCount < obj2.joinedMemberCount ){
					return -1;
				}
				else if(obj1.joinedMemberCount > obj2.joinedMemberCount){
					return 1;
				}
				return 0;
			}
		}

		private function applyCustomSort():void
		{
			panel.joinedMemberCount.sortDescending = true;
			panel.joinedMyMixiMemberCount.sortDescending = true;
			panel.joinedOpenMemberCount.sortDescending = true;
			panel.chatRoomGrid.dispatchEvent(new DataGridEvent(DataGridEvent.HEADER_RELEASE, false,true,3,null,0,null,null,0));
			panel.chatRoomGrid_mymix.dispatchEvent(new DataGridEvent(DataGridEvent.HEADER_RELEASE, false,true,3,null,0,null,null,0));
			panel.chatRoomGrid_open.dispatchEvent(new DataGridEvent(DataGridEvent.HEADER_RELEASE, false,true,3,null,0,null,null,0));
		}
		
		
		// --[ Event Handler ] -------------------------------------------------
		/**
		 * onWalkInTheRoom()
		 * 入室ボタン押下時イベント処理
		 */
		private function onWalkInTheRoom(event:Event = null):void
		{
			var obj:Object = new Object();
			obj["roomId"] = "";
			obj["roomName"] = "";
			if (panel.chatRoomGrid.selectedItem != null)
			{
				// 退室ボタンと入室ボタンを切り替える
				Application.application.roomInfo.memberlist.customPanel2.btnChange("walkin");
				
				Application.application.room = panel.chatRoomGrid.selectedItem.roomName;
				Application.application.roomId = panel.chatRoomGrid.selectedItem.roomId;
				// 選択された部屋オブジェクトを投げる
				obj["roomId"] = panel.chatRoomGrid.selectedItem.roomId;
				obj["roomName"] = panel.chatRoomGrid.selectedItem.roomName;
				sendNotification( ApplicationFacade.WALK_IN_THE_ROOM, 
								  obj );
			}
			else if (panel.chatRoomGrid_mymix.selectedItem != null)
			{
				// 退室ボタンと入室ボタンを切り替える
				Application.application.roomInfo.memberlist.customPanel2.btnChange("walkin");
				
				Application.application.room = panel.chatRoomGrid_mymix.selectedItem.roomName;
				Application.application.roomId = panel.chatRoomGrid_mymix.selectedItem.roomId;
				// 選択された部屋オブジェクトを投げる
				obj["roomId"] = panel.chatRoomGrid_mymix.selectedItem.roomId;
				obj["roomName"] = panel.chatRoomGrid_mymix.selectedItem.roomName;
				sendNotification( ApplicationFacade.WALK_IN_THE_ROOM, 
								  obj );
			}
			else if (panel.chatRoomGrid_open.selectedItem != null)
			{
				// 退室ボタンと入室ボタンを切り替える
				Application.application.roomInfo.memberlist.customPanel2.btnChange("walkin");
				
				Application.application.room = panel.chatRoomGrid_open.selectedItem.roomName;
				Application.application.roomId = panel.chatRoomGrid_open.selectedItem.roomId;
				obj["roomId"] = panel.chatRoomGrid_open.selectedItem.roomId;
				obj["roomName"] = panel.chatRoomGrid_open.selectedItem.roomName;
				// 選択された部屋オブジェクトを投げる
				sendNotification( ApplicationFacade.WALK_IN_THE_ROOM, 
								  obj );
			}
			else
			{
				Alert.show( '部屋が選択されていません', '部屋一覧' );
			}
		}
		
		private function connectToRed5Server():void {
			// 部屋の初期化
			userProxy.logIn();
			
		}
		
		private function checkUserRepeatJoinRoom(event:Event = null):void {
//			chatroomProxy.getCurrentAudiences(panel.chatRoomGrid.selectedItem.roomId);
			if (panel.chatRoomGrid.selectedItem) {
				chatroomProxy.checkJoinOtherRoom(uiHelper.getCurrentUser().nickName, 
								panel.chatRoomGrid.selectedItem.roomId);
			}
			else if (panel.chatRoomGrid_mymix.selectedItem) {
				chatroomProxy.checkJoinOtherRoom(uiHelper.getCurrentUser().nickName, 
								panel.chatRoomGrid_mymix.selectedItem.roomId);
			}
			else if (panel.chatRoomGrid_open.selectedItem) {
				chatroomProxy.checkJoinOtherRoom(uiHelper.getCurrentUser().nickName, 
								panel.chatRoomGrid_open.selectedItem.roomId);
			}
			else {
				Alert.show( '部屋が選択されていません', '部屋一覧' );
			}
		}
		
		//新しいウィンドウを開く場合、入室したユーザが退室かどうか
		private function reEnterRoomMethod():void {
			var roomId:String = "";
			if(panel.chatRoomGrid.selectedItem != null
				&& panel.chatRoomGrid.selectedItem != -1)
			{
				roomId = panel.chatRoomGrid.selectedItem.roomId;
			} 
			else if(panel.chatRoomGrid_mymix.selectedItem != null
				&& panel.chatRoomGrid_mymix.selectedItem != -1)
			{
				roomId = panel.chatRoomGrid_mymix.selectedItem.roomId;
			}
			else if(panel.chatRoomGrid_open.selectedItem != null
				&& panel.chatRoomGrid_open.selectedItem != -1)
			{
				roomId = panel.chatRoomGrid_open.selectedItem.roomId;
			}
			
			uiHelper.setNextRoom(roomId);
			Alert.show("複数ブラウザから同一部屋への入室出来ない為ため、入室したところ強制退室してから入室出来ます、強制退室より入室しますか？","部屋一覧", 
								Alert.YES|Alert.NO, 
								null, 
								alertHandler);
			Application.application.roomInfo.repeatJoinFlg = true;
			//  退室ボタンと入室ボタンを切り替える
			Application.application.roomInfo.memberlist.customPanel2.btnChange("repeatWalkIn");

		}
		private function alertHandler(event:CloseEvent):void {
			if(event.detail == Alert.YES) {
				//先入室したユーザが退室の処理を行う
				var uName:String = uiHelper.getCurrentUser().nickName;
				var roomId:String = uiHelper.getNextRoom();
				chatroomProxy.leavePreRoom(uName, roomId); //強制退室
				chatroomProxy.walkinNextRoom(uName);    //入室
			}
			if(event.detail == Alert.NO) {
				uiHelper.setNextRoom(null);
				Application.application.roomInfo.repeatJoinFlg = true;
				//  退室ボタンと入室ボタンを切り替える
				Application.application.roomInfo.memberlist.customPanel2.btnChange("repeatWalkIn");
			}
		}
	}
}

