package jp.ac.aiit.syms.room.model.service
{
	import flash.net.NetConnection;
	import flash.net.Responder;
	
	import jp.ac.aiit.syms.ApplicationFacade;
	import jp.ac.aiit.syms.room.model.User;
	import jp.ac.aiit.syms.util.UiHelper;
	
	import mx.core.Application;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class RoomService extends Proxy implements IProxy
	{
		public static const NAME:String = "RoomService";
		
		public static var sender:NetConnection;
	
		private static var instance:RoomService;
	
		public function RoomService(data:Object = null ):void
		{
			super ( NAME, data );
		}
		
		public static function getInstance():RoomService
		{
			if (instance == null)
			{
				instance = new RoomService();
			}
			return instance;
		}
 

		public function onShowChanged():void
		{
			
			trace("RoomService::Showing Room");
			// init UI
			UiHelper.getInstance().clearAudiences();
			UiHelper.getInstance().clearRoomMessages();
			// retrieve audience list
			getAudiences();	
			// init stream
			publishedStream();
			// change to memberlist
			roomInfoChange();
			// chat converstion enabled
			UiHelper.getInstance().roomChatStart();
			

		}
		
		private function getAudiences():void
		{
			sender.call("getAudiences", new Responder(onGetAudiencesResult), UiHelper.getInstance().getCurrentRoomId());
		}
		
		private function onGetAudiencesResult(result:Array):void
		{
			UiHelper.getInstance().addAudiences(result);
			var user:User = UiHelper.getInstance().getCurrentUser();
			UiHelper.getInstance().updateAudiences(user);
			UiHelper.getInstance().setCurrentRoomUsers(result);
			updateRooms();
		}
		
		public function leave(roomId:String):void
		{
			sender.call("leaveRoom", new Responder(onLeaveResult), roomId);
		}
		
		private function onLeaveResult(result:Boolean):void
		{
			trace("RoomService::OnLeaveResult:" + result);
			UiHelper.getInstance().clearRoomMessages();
			UiHelper.getInstance().clearCurrentRoom();
			sendNotification(ApplicationFacade.LEAVE_CURRENT_ROOM);
			sendNotification(ApplicationFacade.LEAVE_CURRENT_ROOM_VIDEO);
			if(Application.application.roomInfo.repeatJoinFlg) {
				sendNotification(ApplicationFacade.NEXT_ROOM_WALK_IN);
			}
		}
		
		public function sendPublicMessage(roomId:String, msg:String):void
		{
			var hex:uint;
			var color:String;
			hex = Application.application.conversation.sendColorPicker.selectedColor;
			color = uintToString(hex);
			
			sender.call("sendPublicMessage", new Responder(onSendPublicMessageResult), msg, color);
			Application.application.conversation.editor.enabled = false;
			Application.application.conversation.editor.text = "sending...";
		}
		
		private function uintToString(hex:uint):String { 
			var hexString:* = hex.toString(16).toUpperCase(); 
			var cnt:int = 6 - hexString.length; 
			var zeros:String = ""; 
			for (var i:int = 0; i < cnt; i++) { 
				zeros += "0"; 
		} 
			return "#" + zeros + hexString; 
		} 

		
		private function onSendPublicMessageResult(result:Boolean):void
		{
			Application.application.conversation.editor.text = "";
			Application.application.conversation.editor.enabled = true;
			Application.application.conversation.editor.setFocus();
		}
		

		public function publishedStream():void
		{
			sendNotification(ApplicationFacade.VIDEO_SENDER, sender);
			 			
		}
		
	
		public function updateRooms():void
		{
			var room:String = UiHelper.getInstance().getCurrentRoom();
			var roomId:String = UiHelper.getInstance().getCurrentRoomId();
			var audiences:Array = UiHelper.getInstance().getCurrentRoomUsers();
			UiHelper.getInstance().updateRooms(roomId, audiences.length);
			
			
		}
		
		public function roomInfoChange():void
		{
			sendNotification(ApplicationFacade.MEMBER_LIST);
		}
		
		public function updateMemberList():void
		{
			var room:String = UiHelper.getInstance().getCurrentRoom();
			var roomId:String = UiHelper.getInstance().getCurrentRoomId();
			var user:User = UiHelper.getInstance().getCurrentUser();
			if(user.getNickName().indexOf("debug") < 0) {
				sender.call("publishCamera", 
							new Responder(onResultUpdateMemberList), 
							user.isHasCamera(),user.camDenyFlg,  roomId, user.getNickName());
			}	

		}
		
		public function onResultUpdateMemberList(result:Boolean):void
		{
			trace("onResultUpdateMemberList:"+result);
		}
	}
}