package jp.ac.aiit.syms.util
{
	import mx.controls.Alert;
	import jp.ac.aiit.syms.room.model.User;
	
	public class CallBack extends Object
	{
		// hall call back
		
		/**
		 *  setID
		 */
		public function setId( id:Number ):*
		{
			trace("setId: id=" + id );
			if( isNaN( id ) ) return;
			return "Okay";
		}
		
		public function previousRoomOnLeave(userName:String, roomId:String):void {
			UiHelper.getInstance().previousRoomLeaveCommand(userName, roomId);
		}
		
		public function nextRoomOnJoin(userName:String):void {
			UiHelper.getInstance().walkInNextRoom(userName);
		}
		
		public function hallOnJoin(audience:Object):void
		{
			trace("HallCallBack::Hall_OnJoin:" + audience.nickName);
		}
		
		public function hallOnLeave(audience:Object):void
		{
			trace("HallCallBack::Hall_OnLeave:" + audience.nickName);
		}
		
		public function hallOnRoomCreated(room:Object):void
		{
			trace("HallCallBack::Hall_OnRoomCreated:" + room.roomName);
			UiHelper.getInstance().addRooms(new Array(room));
		}
		
		public function hallOnRoomDestroyed(room:Object):void
		{
			trace("HallCallBack::HallOnRoomDestroyed:" + room.roomName);
		}
		
		public function hallOnRoomUpdated(room:Object, status:String):void
		{
			trace("HallCallBack::Hall_OnRoomUpdated:" + room.roomName);
			UiHelper.getInstance().updateRoom(room, status);
//			UiHelper.getInstance().updateCurrentRoom(room);
		}
		
		// room call back
		
		public function roomOnJoin(room:Object, audience:Object):void
		{
			trace("RoomCallback::Room_OnJoin:" + "room-" + room.roomName + ",audience-" + audience.nickName);
			UiHelper.getInstance().notifyJoinMessage(audience.nickName, room);
			UiHelper.getInstance().addAudiences(new Array(audience));
		}

		public function roomOnLeave(room:Object, audience:Object):void
		{
			trace("RoomCallback::Room_OnLeave:" + "room-" + room.roomName + ",audience-" + audience.nickName);
			UiHelper.getInstance().notifyLeaveMessage(audience.nickName, room);
			UiHelper.getInstance().removeAudiences(audience, room);
		}
		
		public function roomReceivePublicMessage(room:Object, audience:Object, msg:String):void
		{
			trace("RoomCallback::Room_ReceivePublicMessage:" + "room-" + room.roomName + ",audience-" + audience.nickName + ",message-" + msg);
			UiHelper.getInstance().addMessage(audience.nickName, msg);
		}
		
		public function updateMemberlist(audience:Object):void
		{
			trace("RoomCallback::Room_UpdateMemberlist:" + "audience-" + audience.nickName);
			UiHelper.getInstance().updateAudiences(audience);
		}
		
		// 部屋一覧　更新
		public function refreshRoomsList(rooms:Array):void
		{
			trace("RefreshRoom::RoomList_Refresh");
			UiHelper.getInstance().addRooms(rooms);
		}
		
		// 部屋一覧　削除
		public function delRoomsList(rooms:Array):void
		{
			trace("DelRoom::RoomList_Del");
			UiHelper.getInstance().delRooms(rooms);
		}
	}
}