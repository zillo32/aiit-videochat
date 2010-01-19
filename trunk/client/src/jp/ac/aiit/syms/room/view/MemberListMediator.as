package jp.ac.aiit.syms.room.view
{
	import flash.events.Event;
	
	import jp.ac.aiit.syms.ApplicationFacade;
	import jp.ac.aiit.syms.chat.model.ContactProxy;
	import jp.ac.aiit.syms.room.model.*;
	import jp.ac.aiit.syms.room.model.service.RoomService;
	import jp.ac.aiit.syms.util.UiHelper;
	
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.Application;
	import mx.formatters.DateFormatter;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	/**
	 * 
	 * ChatRoomMediator
	 * 
	 */
	public class MemberListMediator extends Mediator implements IMediator
	{

		//------------------------------------
		// 定数
		//------------------------------------
		public static const NAME:String = "MemberListMediator";
		
		//------------------------------------
		// インスタンス変数
		//------------------------------------
		private var contactProxy:ContactProxy;
		private var uiHelper:UiHelper;
		private var roomService:RoomService;
		/**
		 * 
		 * ChatRoomMediator()
		 * コンストラクタ
		 * 
		 */
		public function MemberListMediator( viewComponent:Object )
		{
			super( NAME, viewComponent );
			
			// 使用するProxyの取得
			contactProxy = facade.retrieveProxy( ContactProxy.NAME ) as ContactProxy;
			roomService = facade.retrieveProxy(RoomService.NAME ) as RoomService;
			uiHelper = facade.retrieveProxy(UiHelper.NAME) as UiHelper;
			
			// イベントハンドラ設定
			panel.addEventListener(MemberList.LEAVE_CURRENT_ROOM, leaveCurrentRoom );
			panel.addEventListener(MemberList.SELECT_VIDEO_DISPLAY, onVideoDisplay );
			panel.addEventListener(MemberList.WALK_IN_ROOM_BUTTON_CLICK, onWalkInTheRoom);
			// ラベル用フォーマット関数設定
			panel.hasCameraid.labelFunction = hasCameraLabel;
			panel.joinedTimeid.labelFunction = joinedTimeLabel;
			
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
			return [ 
						ApplicationFacade.PROHIBIT_PREVIOUS_ROOM_LEAVE
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
				case ApplicationFacade.PROHIBIT_PREVIOUS_ROOM_LEAVE:
					var object:Object = notification.getBody();
					var userName:String = object["userName"] as String;
					var roomId:String = object["roomId"] as String;
					var curRoomName:String = uiHelper.getCurrentRoom();
					var curRoomId:String = uiHelper.getCurrentRoomId();
					var curUserNAme:String = uiHelper.getCurrentUser().nickName;
					if(curRoomId == roomId 
							&& userName == curUserNAme) {
								leaveCurrentRoom(null);
							}
					break;
			}
		}
		
		/**
		 * 
		 * panel()
		 * ビューコンポーネントの取得
		 *  
		 */
		private function get panel():MemberList  {
			return viewComponent as MemberList;
		}
		
	

		// --[ Event Handler ] -------------------------------------------------
		/**
		 * onVideoDisplay()
		 * ビデオを表示ボタン押下時イベント処理
		 */
		private function onVideoDisplay( evt:Event ):void
		{
			// 選択されたユーザーオブジェクトを投げる
			sendNotification( ApplicationFacade.SELECTED_VIDEO_DISPLAY, 
							  panel.memberDatagrid.selectedItem );
		}
		
		/**
		 * leaveCurrentRoom()
		 * 退室ボタン押下時イベント処理
		 */
		private function leaveCurrentRoom(evt:Event ):void
		{
			var roomName:String = uiHelper.getCurrentRoom();
			var roomId:String = uiHelper.getCurrentRoomId();
			roomService.leave(roomId);
		}


		// --[ Label Formatter ] -------------------------------------------------
		/**
		 * hasCameraLabel()
		 * カメラ状態UI表示用フォーマット
		 */
		private function hasCameraLabel( member:Object, column:DataGridColumn ):String
		{
//			return member.hasCamera ? 'あり' : 'なし';
			return member.hasCamera ? 'cameraClass0' : 'cameraClass1';
		}
		
		/**
		 * joinedTimeLabel()
		 * 入室時間UI表示用フォーマット
		 */
		private function joinedTimeLabel( member:Object, column:DataGridColumn ):String
		{
			var formatter:DateFormatter = new DateFormatter();
			formatter.formatString = "M/D JJ:NN:SS"
			return formatter.format( member.joinedTime );
		}
		
		private function onWalkInTheRoom(event:Event = null):void
		{
			// 選択された部屋オブジェクトを投げる
			if(Application.application.roomInfo.roomlist.chatRoomGrid.selectedItem) {
				// community
				sendNotification( ApplicationFacade.WALK_IN_ROOM_BUTTON_CLICK, 
								  Application.application.roomInfo.roomlist.chatRoomGrid.selectedItem.roomId );
			} else if(Application.application.roomInfo.roomlist.chatRoomGrid_mymix.selectedItem) {
				// mymix
				sendNotification( ApplicationFacade.WALK_IN_ROOM_BUTTON_CLICK, 
								  Application.application.roomInfo.roomlist.chatRoomGrid_mymix.selectedItem.roomId );
			} else if(Application.application.roomInfo.roomlist.chatRoomGrid_open.selectedItem) {
				// openroom
				sendNotification( ApplicationFacade.WALK_IN_ROOM_BUTTON_CLICK, 
								  Application.application.roomInfo.roomlist.chatRoomGrid_open.selectedItem.roomId );
			}

		}

	}
}

