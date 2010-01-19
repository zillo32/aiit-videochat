package jp.ac.aiit.syms.util
{
	import jp.ac.aiit.syms.ApplicationFacade;
	import jp.ac.aiit.syms.room.model.User;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Image;
	import mx.core.Application;
	import mx.formatters.DateFormatter;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class UiHelper extends Proxy implements IProxy
	{

		public static const NAME:String = "UiHelper";

		// instance
		private static var instance:UiHelper;

		//顔文字のコード（PC）
		public  var codArray:Array = new Array();
		//顔文字の画像
		public  var urlArray:Array = new Array();
		//顔文字の説明
		public  var remarkArray:Array = new Array();
		
		public static function getInstance():UiHelper
		{
			if (instance == null)
			{
				instance = new UiHelper();
			}
			return instance;
		}

		public function UiHelper(data:Object = null)
		{
			super ( NAME, data );
		}
		
		public function previousRoomLeaveCommand(userName:String, roomId:String):void {
			var object:Object = new Object();
			object["userName"] = userName;
			object["roomId"] = roomId;
			sendNotification(ApplicationFacade.PROHIBIT_PREVIOUS_ROOM_LEAVE,object); 
		}
		
		public function walkInNextRoom(userName:String):void {
			sendNotification(ApplicationFacade.WALK_IN_NEXT_ROOM,userName);
		}
		
		public function setCurrentRoomUsers(users:Array):void
		{
			Application.application.users = users;	
		}
		
		// マイミクリスト情報をセット
		public function setFriendsList(friends:Array):void
		{
			Application.application.friendsList = friends;
		}
		
		//マイミクリスト情報をゲット
		public function getFriendsList():Array
		{
			return Application.application.friendsList;
		}
		
		// マイミクリスト中に、該当ユーザ存在するかどうかの判断
		public function isFriends(userName:String):Boolean
		{
			var isFriendsFlg:Boolean = false;
			var friends:Array = getFriendsList();
			for(var i:int = 0; i < friends.length; i++)
			{
				if(userName == friends[i].userName)
				{
					isFriendsFlg = true;
					break;
				}
			}
			return isFriendsFlg;

		}
		
		public function setVideoDisplayUsers(userName:String):void
		{
			var userNames:Array = Application.application.userNames;
			if(userNames == null)
			{
				userNames = new Array();
			}
			for(var i:String in userNames)
			{
				if(userNames[i] == userName)
				{
					return;
				}
			}
			userNames.push(userName);
		}
		
		public function getInitRooms():ArrayCollection 
		{
			var rooms:ArrayCollection = new ArrayCollection();
			var roomList:ArrayCollection = Application.application.roomInfo.roomlist.chatRoomGrid.dataProvider;
			var mymixrooms:ArrayCollection = Application.application.roomInfo.roomlist.chatRoomGrid_mymix.dataProvider;
			var openrooms:ArrayCollection = Application.application.roomInfo.roomlist.chatRoomGrid_open.dataProvider;
			
			for(var k:String in roomList)
			{
				rooms.addItem(roomList[k]);
			}
			
			for(var i:String in mymixrooms)
			{
				rooms.addItem(mymixrooms[i]);
			}
			for(var j:String in openrooms)
			{
				rooms.addItem(openrooms[j]);
			}
			
			return rooms;
		}
		

		
		public function getCurrentRoomUsers():Array
		{
			if(Application.application.users == null) {
				Application.application.users = new Array();
			}
			return Application.application.users;
		}
		
		// current user		
		public function getCurrentUser():User
		{
			return Application.application.me;
		}
		
		public function setCurrentUser(user:User):void
		{
			Application.application.me = user;
		}
		
		public function setNextRoom(roomName:String):void
		{
			Application.application.walkinNewRoom = roomName;
		}
			public function getNextRoom():String
		{
			return Application.application.walkinNewRoom;
		}
		
		public function updateAudiences(audience:Object):void
		{
			var source:ArrayCollection = Application.application.roomInfo.memberlist.memberDatagrid.dataProvider;

			for(var index:String in source)
			{
				if(source[index].nickName == audience.nickName) 
				{
					source.setItemAt(audience, int(index));

				}
			}

		}
		

		public function getSelectedUser(name:String):User
		{
			var users:ArrayCollection = Application.application.users;
			for(var index:String in users) 
			{
				if(users[index] == name)
				{
					return users[index];
				}
			}
			return null;
		}
	
		// current room
		public function getCurrentRoom():String
		{
			return Application.application.room;
		}
		
		public function getCurrentRoomId():String
		{
			return Application.application.roomId;
		}
		
		public function setCurrentRoom(room:String):void
		{
			Application.application.room = room;
		}
	
		public function setCurrentRoomId(roomId:String):void
		{
			Application.application.roomId = roomId;
		}
	
		// hall interface
		public function clearRooms():void
		{
			if (Application.application.roomlist != null &&
				Application.application.roomlist.chatRoomGrid.dataProvider != null)
			{
				Application.application.roomlist.chatRoomGrid.dataProvider.removeAll();
			}
				if (Application.application.roomlist != null &&
				Application.application.roomlist.chatRoomGrid_mymix.dataProvider != null)
			{
				Application.application.roomlist.chatRoomGrid_mymix.dataProvider.removeAll();
			}
			if (Application.application.roomlist != null &&
				Application.application.roomlist.chatRoomGrid_open.dataProvider != null)
			{
				Application.application.roomlist.chatRoomGrid_open.dataProvider.removeAll();
			}
		}
		
		
		public function addRooms(rooms:Array):void
		{
			var source:ArrayCollection = Application.application.roomInfo.roomlist.chatRoomGrid.dataProvider;
			var source_mymix:ArrayCollection = Application.application.roomInfo.roomlist.chatRoomGrid_mymix.dataProvider;
			var source_open:ArrayCollection = Application.application.roomInfo.roomlist.chatRoomGrid_open.dataProvider;
			if (source == null)
			{
				source = new ArrayCollection();
				Application.application.roomInfo.roomlist.chatRoomGrid.dataProvider = source;
			}
			if (source_mymix == null)
			{
				source_mymix = new ArrayCollection();
				Application.application.roomInfo.roomlist.chatRoomGrid_mymix.dataProvider = source_mymix;
			}
			if (source_open == null)
			{
				source_open = new ArrayCollection();
				Application.application.roomInfo.roomlist.chatRoomGrid_open.dataProvider = source_open;
			}

			//部屋一覧の追加
			for (var index:String in rooms)
			{	var isExist:Boolean = false;
				var roomType:String = rooms[index].roomType;
				switch(roomType)
				{
					case "1":
						for(var i:String in source) {
							if(source[i].roomId == rooms[index].roomId && rooms[index].roomType == "1")
					 		{
								source[i].joinedMemberCount = rooms[index].joinedMemberCount;
								isExist = true;
					 		}
						}

						break;
					case "2":
						for(var j:String in source_mymix) {
							if(source_mymix[j].roomId == rooms[index].roomId && rooms[index].roomType == "2")
					 		{
								source_mymix[j].joinedMemberCount = rooms[index].joinedMemberCount;
								isExist = true;
					 		}
						}
						break;
					case "3":
						for(var k:String in source_open) {
					 		if(source_open[k].roomId == rooms[index].roomId && rooms[index].roomType == "3")
					 		{
								source_open[k].joinedMemberCount = rooms[index].joinedMemberCount;
					 		}

						}
						break;	
				}
				
 				if(!isExist)
				{
				 	if(rooms[index].roomName != "") {
				 		//監視者が全部の部屋を見る
				 		if(rooms[index].roomType == "2" && getCurrentUser().getNickName().indexOf("debug")>= 0){
				 			if(rooms[index].joinedMemberCount > 0) {
				 				source_mymix.addItem(rooms[index]);
				 			}
				 		} else if(rooms[index].roomType == "1" && getCurrentUser().getNickName().indexOf("debug")>= 0) {
				 			if(rooms[index].joinedMemberCount > 0) {
				 				source.addItem(rooms[index]);
				 			}
				 		} else {
					 		// マイミクリスト
					 		if(rooms[index].roomType == "2" 
					 			&& isFriends(rooms[index].roomName)) {
					 			source_mymix.addItem(rooms[index]);
					 		}
				 		} 
				 	}
				}  

			}

		}
		
		public function delRooms(rooms:Array):void {
			//存在必要ないの部屋を削除
			var source:ArrayCollection = Application.application.roomInfo.roomlist.chatRoomGrid_mymix.dataProvider;
			var delIndex:int = 0;
			var isDelete:Boolean = false;
			
			for(var s:String in source) {
				for(var r:String in rooms) {
					if(rooms[r].roomId == source[s].roomId) {
						isDelete = true;
						break;
					} 
				}
				if(isDelete) {
					delIndex = int(s);
					break;
				}
			}
			if(isDelete) {
				source.removeItemAt(delIndex);
			}
		}
		
		public function updateRoom(room:Object, flag:String):void
		{
			var source:ArrayCollection = Application.application.roomInfo.roomlist.chatRoomGrid.dataProvider;
			var source_mymix:ArrayCollection = Application.application.roomInfo.roomlist.chatRoomGrid_mymix.dataProvider;
			var source_open:ArrayCollection = Application.application.roomInfo.roomlist.chatRoomGrid_open.dataProvider;
			var isExist:Boolean = false;
			var pos:String = "0";
			var roomType:String = room.roomType;
			switch (roomType)
			{
				case "1":
					for (var index:String in source)
					{
						if (source[index].roomId == room.roomId)
						{
							room.roomName = source[index].roomName;
							room.roomIconUrl = source[index].roomIconUrl;
							source.setItemAt(room, int(index));
							isExist = true;
							pos = index;
							break;
						}
					}
					break;
				case "2":
					for (var index2:String in source_mymix)
					{
						if (source_mymix[index2].roomId == room.roomId)
						{
							room.roomName = source_mymix[index2].roomName;
							room.roomIconUrl = source_mymix[index2].roomIconUrl;
							source_mymix.setItemAt(room, int(index2));
							isExist = true;
							pos = index;
							break;
						}
					}
					break;
				case "3":
					for (var index3:String in source_open)
					{
						if (source_open[index3].roomId == room.roomId)
						{
							room.roomName = source_open[index3].roomName;
							room.roomIconUrl = source_open[index3].roomIconUrl;
							source_open.setItemAt(room, int(index3));
							break;
						}
					}
					break;	
			}
			
 				if(getCurrentUser().getNickName().indexOf("debug") >= 0) {
	 				if(!isExist)
					{
				 		//監視者が全部の部屋を見る
				 		if(room.roomType == "2"){
				 				source_mymix.addItem(room);
				 		} else if(room.roomType == "1") {
				 				source.addItem(room);
				 		}
					} else {
						if(room.roomType =="2" && room.joinedMemberCount == "0") {
							source_mymix.removeItemAt(int(pos));
						} else if(room.roomType =="1" && room.joinedMemberCount == "0") {
							source.removeItemAt(int(pos));
						}
					}
	 			}
			
			var status:Object = new Object();
			status["room"] = room.roomId;
			status["flag"] = flag;
			sendNotification(ApplicationFacade.ROOM_LIST_REFRESHED, status);
		}
		
		public function updateRooms(roomId:String, usersCount:int):void
		{
			var source:ArrayCollection = Application.application.roomInfo.roomlist.chatRoomGrid.dataProvider;
			var source_mymix:ArrayCollection = Application.application.roomInfo.roomlist.chatRoomGrid_mymix.dataProvider;
			var source_open:ArrayCollection = Application.application.roomInfo.roomlist.chatRoomGrid_open.dataProvider;

			for (var index:String in source)
			{
				if (source[index].roomId == roomId)
				{
					source[index].joinedMemberCount = usersCount;
					break;
				}
			}
			for (var index2:String in source_mymix)
			{
				if (source_mymix[index2].roomId == roomId)
				{
					source_mymix[index2].joinedMemberCount = usersCount;
					break;
				}
			}
			for (var index3:String in source_open)
			{
				if (source_open[index3].roomId == roomId)
				{
					source_open[index3].joinedMemberCount = usersCount;
					break;
				}
			}
		}
		
		public function getRooms():ArrayCollection
		{
			var result:ArrayCollection = new ArrayCollection();
			var source:ArrayCollection = Application.application.roomInfo.roomlist.chatRoomGrid.dataProvider;
			var mymixsource:ArrayCollection = Application.application.roomInfo.roomlist.chatRoomGrid_mymix.dataProvider;
			var opensource:ArrayCollection = Application.application.roomInfo.roomlist.chatRoomGrid_open.dataProvider;
			if(source == null)
			{
				source = new ArrayCollection();
			}
			if(mymixsource == null)
			{
				mymixsource = new ArrayCollection();
			}
			if(opensource == null)
			{
				opensource = new ArrayCollection();
			}
			for(var i:String in source)
			{
				result.addItem(source[i]);
			}
			
			for(var j:String in mymixsource)
			{
				result.addItem(mymixsource[j]);
			}
			
			for(var k:String in opensource)
			{
				result.addItem(opensource[k]);
			}
		
			return result;	
		}
		
		// room interface
		public function clearAudiences():void
		{
			if (Application.application.roomInfo.memberlist.memberDatagrid != null &&
				Application.application.roomInfo.memberlist.memberDatagrid.dataProvider != null)
			{
				Application.application.roomInfo.memberlist.memberDatagrid.dataProvider.removeAll();
			}
		}
		
		public function addAudiences(audiences:Array):void
		{
			if (Application.application.roomInfo.memberlist.memberDatagrid == null)
			{
				// ingonore when the audiences gride haven't been initialized.
				return;
			}
			var source:ArrayCollection = Application.application.roomInfo.memberlist.memberDatagrid.dataProvider;
			if (source == null)
			{
				source = new ArrayCollection();
				Application.application.roomInfo.memberlist.memberDatagrid.dataProvider = source;
			}
			for (var index:String in audiences)
			{	var haveFlg:Boolean = false;
				for(var i:String in source)
				{
					if(source[i].nickName == audiences[index].nickName)
					{
						haveFlg = true;
						source.setItemAt(audiences[index], new int(i));
					}
				}
				if(!haveFlg && (audiences[index].nickName).indexOf("debug") < 0) {
					source.addItem(audiences[index]);
				}
			}
		}
		
		public function viewAudiences(audiences:Array):void
		{
			if (Application.application.roomInfo.memberlist.memberDatagrid == null)
			{
				// ingonore when the audiences gride haven't been initialized.
				return;
			}
			var source:ArrayCollection = Application.application.roomInfo.memberlist.memberDatagrid.dataProvider;
			if(source != null)
			{
				source.removeAll();
			} 
			else
			{
				source = new ArrayCollection();
				Application.application.roomInfo.memberlist.memberDatagrid.dataProvider = source;
			}
			for (var index:String in audiences)
			{	
				source.addItem(audiences[index]);
			}
		}
		
		public function removeAudiences(audience:Object, room:Object):void
		{
			var source:ArrayCollection = Application.application.roomInfo.memberlist.memberDatagrid.dataProvider;
			var roomId:String = getCurrentRoomId();
			for (var index:String in source)
			{
				if (source[index].nickName == audience.nickName 
					&& room.roomId == roomId )
				{
					source.removeItemAt(int(index));
					break;
				}
			}
			sendNotification(ApplicationFacade.GET_LEAVE_ROOM_NOTIFICATION, audience.nickName);
		}
		
		
		public function clearRoomMessages():void
		{
			Application.application.conversation.historyDisplay.text = "";
			Application.application.conversation.editor.text = "";
			Application.application.conversation.editor.editable = false;
			Application.application.conversation.iconImage.visible = false;

			clearConversationImageChild();
		}
		
		public function clearCurrentRoom():void
		{
			Application.application.room = "";
		}
		
		public function clearCurrentRoomId():void
		{
			Application.application.roomId = "";
		}
		public function roomChatStart():void
		{
			Application.application.conversation.editor.editable = true;
			Application.application.conversation.iconImage.visible = true;
		} 
		
		public function addMessage(from:String, msg:String):void
		{
			var dateformatter:DateFormatter = new DateFormatter();
			dateformatter.formatString = 'JJ:NN:SS';
 			var displayMsg:String = msg;
//          var displayMsg:String = dateformatter.format( new Date() ) + ' (' + from + ") " + msg;
//			displayMsg = escapeHtmlEntity( displayMsg );

			if(codArray != null && urlArray != null) 
			{
				Application.application.conversation.smileyHandler(codArray, urlArray, displayMsg);
			}
			else 
			{
				Application.application.conversation.historyDisplay.text += displayMsg;
			}
		
			sendNotification(ApplicationFacade.SEND_MESSEGE_SOUND);	
		}
		
		private function escapeHtmlEntity(msg:String):String
		{

			
			if( msg.match( new RegExp( '[&<>"\']' ) ) )
			{
				return msg.replace( new RegExp( '&' , 'g'), '&amp;' )
				           .replace( new RegExp( '<' , 'g'), '&lt;' )
				           .replace( new RegExp( '>' , 'g'), '&gt;' )
				           .replace( new RegExp( '"' , 'g'), '&quot;' )
				           .replace( new RegExp( '\'', 'g'), '&apos;' );
			}
			else
			{
				return msg;
			}
		}
		
		public function notifyJoinMessage(audienceName:String, room:Object):void
		{
//	Logger.info("PASSING:: notifyJoinMessage()");
//	Logger.info(getCurrentRoomId());
//	Logger.info(room.roomId);
			
			if (getCurrentRoomId() == room.roomId && audienceName.indexOf("debug") < 0)
			{
				var notifyMessage:String = audienceName + " さんが入室しました。";
	
				var oldText:String = Application.application.conversation.historyDisplay.htmlText;
				
				var dateformatter:DateFormatter = new DateFormatter();
				dateformatter.formatString = 'JJ:NN';
	 			var displayMsg:String = '<font color="#aaaaaa">'
	 									+ dateformatter.format( new Date() ) 
	 									+ ' ' + notifyMessage + "</font>";

//				Application.application.conversation.historyDisplay.height += 20;
				Application.application.conversation.historyDisplay.htmlText = oldText + displayMsg + "\n";

//	Logger.info(displayMsg);
	
//				Application.application.conversation.historyDisplay.validateNow();
				Application.application.conversation.chatCanvas.validateNow();

				Application.application.conversation.historyDisplay.callLater( scrollConversationPosition );
			}
		}

		public function notifyLeaveMessage(audienceName:String, room:Object):void
		{
//	Logger.info("PASSING:: notifyLeaveMessage()");
//	Logger.info(getCurrentRoomId());
//	Logger.info(room.roomId);
			
			if (getCurrentRoomId() == room.roomId)
			{
				var notifyMessage:String = audienceName + " さんが退室しました。";
	
				var oldText:String = Application.application.conversation.historyDisplay.htmlText;
				
				var dateformatter:DateFormatter = new DateFormatter();
				dateformatter.formatString = 'JJ:NN';
	 			var displayMsg:String = '<font color="#aaaaaa">'
	 									+ dateformatter.format( new Date() ) 
	 									+ ' ' + notifyMessage + "</font>";

//				Application.application.conversation.historyDisplay.height += 20;
				Application.application.conversation.historyDisplay.htmlText = oldText + displayMsg + "\n";

//	Logger.info(displayMsg);

//				Application.application.conversation.historyDisplay.validateNow();
				Application.application.conversation.chatCanvas.validateNow();
	
				Application.application.conversation.historyDisplay.callLater( scrollConversationPosition );
			}
		}
		
		public function scrollConversationPosition():void {
			
			Application.application.conversation.historyDisplay.verticalScrollPosition = 
				Application.application.conversation.historyDisplay.maxVerticalScrollPosition;
			
			Application.application.conversation.chatCanvas.verticalScrollPosition = 
				Application.application.conversation.chatCanvas.maxVerticalScrollPosition;
			
		}	

		public function clearConversationImageChild():void
		{
			var arr:Array = Application.application.conversation.chatCanvas.getChildren();
			for(var i:int = arr.length; i >= 0; i--)
			{
				if(arr[i] is Image)
				{
					Application.application.conversation.chatCanvas.removeChildAt(i);
				}
			}
		}
		
		public function getPlaySoundStatus():Boolean
		{
			return Application.application.conversation.chkEnableSoundOnRecieveMessage.selected;
		}
		
		
	}
}