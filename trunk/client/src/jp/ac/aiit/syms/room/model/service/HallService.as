package jp.ac.aiit.syms.room.model.service
{
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	
	import jp.ac.aiit.syms.ApplicationFacade;
	import jp.ac.aiit.syms.config.Configuration;
	import jp.ac.aiit.syms.room.model.User;
	import jp.ac.aiit.syms.util.CallBack;
	import jp.ac.aiit.syms.util.UiHelper;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class HallService extends Proxy implements IProxy
	{
		public static const NAME:String = "HallService";
		
		private var strCon:String = Configuration.getRemoteURI();
		public var con:NetConnection;
		private var user:User;
	
		private static var instance:HallService;
		
		
		public function HallService(data:Object = null ):void
		{
			super ( NAME, data );
			con = new NetConnection();
			con.addEventListener(NetStatusEvent.NET_STATUS, onStatus);
			con.client = new CallBack();
		}

		public static function getInstance():HallService
		{
			if (instance == null)
			{
				instance = new HallService();
			}
			return instance;
		}
 

		public function onShowChanged():void
		{
			trace("HallService::Showing Hall");
			// init UI
//			UiHelper.GetInstance().ClearRooms();
			// make connection
			if (con.connected)
			{
				// return from room interface
				getRooms();
			}
			else
			{
				// enter from login interface
				makeConnection();

			}
		}		
		
		public function makeConnection():void
		{
			if (!con.connected)
			{
				trace("HallService::MakeConnection");
				user = UiHelper.getInstance().getCurrentUser();
				con.connect(strCon, 
							user.getNickName(), user.getUserIconUrl(), user.id);
			}
		}
		
		public function closeConnection():void
		{
			if (con.connected)
			{
				trace("HallService::CloseConnection");
				con.close();
			}
		}
		
		public function createRoom(name:String, roomId:String):void
		{
//			UiHelper.getInstance().setCurrentRoom(name);
			UiHelper.getInstance().setCurrentRoomId(roomId);
			con.call("createAndJoinRoom", new Responder(onCreateRoomResult), roomId);
		}
		
		public function getAudiences(roomId:String):void
		{
			con.call("getAudiences", new Responder(onGetAudiencesResult), roomId);
		}
		
		private function onGetAudiencesResult(result:Array):void
		{
			UiHelper.getInstance().setCurrentRoomUsers(result);
			sendNotification(ApplicationFacade.USER_JOIN_ROOM_STATUS);
		}

		public function checkDoubleJoinRoom(userName:String, roomId:String):void
		{
			con.call("checkUserRoomsInfo", new Responder(onCheckUsersInfoResult), userName, roomId);
		}

		private function onCheckUsersInfoResult(result:String):void
		{
			sendNotification(ApplicationFacade.DOUBLE_ROOM_JOIN_CHECK, result);
		}

		public function getCurrentRoomAudiences(roomId:String):void {
			con.call("getAudiences", new Responder(onGetCurrentRoomAudiences), roomId);
		}
		
		private function onGetCurrentRoomAudiences(result:Array):void {
			UiHelper.getInstance().viewAudiences(result);
			sendNotification(ApplicationFacade.VIEW_MEMBERS_LIST);
		}
		
		private function onCreateRoomResult(ok:Boolean):void
		{
			trace("HallService::OnCreateRoomResult:" + ok);
			if (ok)
			{
				RoomService.sender = con;
				sendNotification(ApplicationFacade.CREATE_NEW_ROOM);
				// smile icon load
				loadAllSmileIcons();
			}
		}
		
		public function getRooms():void
		{
			con.call("getRooms", new Responder(onGetRoomsResult));
		}
		
		public function setInitRooms():void
		{
			var initRooms:ArrayCollection = UiHelper.getInstance().getInitRooms();
			
			con.call("initCreateRooms", new Responder(onSetRoomsResult), initRooms);
		}
		
		public function onSetRoomsResult(result:Boolean):void
		{
			if(result) {
				getRooms();
			}
			
		}
		
//		public function createRooms():void
//		{
//			con.call("createRooms", new Responder(onCreateRoomsResult), UiHelper.getInstance().getRooms());
//		}
		
		private function onGetRoomsResult(rooms:Array):void
		{
			trace("HallService::OnGetRoomsResult:" + rooms.length);
			UiHelper.getInstance().addRooms(rooms);
		}
		
//		private function onCreateRoomsResult (result:Boolean):void 
//		{
//			trace("HallService::OnCreateRoomsResult:" + result);	
//		}
		
		public function leavePreviousRoom(userName:String, roomId:String):void
		{
			con.call("leavePreRoom", new Responder(onLeaveResult), userName, roomId);
		}
		
		public function walkinNexRoom(userName:String):void
		{
			con.call("walkinNextRoom", new Responder(onWalkInNextRoom), userName);
		}
		
		private function onWalkInNextRoom(result:Boolean):void
		{
			trace("HallService::onWalkInNextRoom:" + result);
		}	
		
		private function onLeaveResult(result:Boolean):void
		{
			trace("HallService::OnLeaveResult:" + result);
		}
		
		private function loadAllSmileIcons():void {

			con.call("get_all_contents", new Responder(getAllSmilesIcons) , "1");
		} 
		
  		private function getAllSmilesIcons(result:Object):void {
	
			var outRes:Array = result as Array;
			
			//顔文字のコード（PC）
			UiHelper.getInstance().codArray = outRes["PMODE"];
			//顔文字の画像
			UiHelper.getInstance().urlArray = outRes["IMG"];
			//顔文字の説明
			UiHelper.getInstance().remarkArray = outRes["REMARK"];
		} 
		
		
		private function onStatus(status:NetStatusEvent):void
		{
			switch(status.info.code)
			{
				case "NetConnection.Connect.Success":
					trace("HallService::NetConnection.Connect.Success")
					// 部屋初期化
					setInitRooms();
					break;
				case "NetConnection.Connect.Closed":
					trace("HallService::NetConnection.Connect.Closed")
					break;
				case"NetConnection.Connect.Failed":
					trace("HallService::NetConnection.Connect.Failed")
					break;
				case"NetConnection.Connect.AppShutdown":
					trace("HallService::NetConnection.Connect.AppShutdown")
					break;
				case"NetConnection.Call.Failed":
					trace("HallService::NetConnection.Call.Failed")
					break;
				case"NetConnection.Connect.InvalidApp":
					trace("HallService::NetConnection.Connect.InvalidApp")
					break;
				case"NetConnection.Connect.Rejected":
					trace("HallService::NetConnection.Connect.Rejected")
					break;
			}
		}
	}
}