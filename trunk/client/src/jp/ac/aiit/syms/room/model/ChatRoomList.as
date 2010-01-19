package jp.ac.aiit.syms.room.model
{
	
	import jp.ac.aiit.syms.util.UiHelper;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class ChatRoomList
	{
		public var rooms:ArrayCollection = new ArrayCollection();
		
		public function ChatRoomList()
		{
		}

		public function ChatRoomList2(roomType:String):ArrayCollection
		{
			if(roomType == "2") 
			{
				// 個人部屋追加
				var privateRoom:ChatRoom = new ChatRoom();
				privateRoom.roomId = UiHelper.getInstance().getCurrentUser().id;
				privateRoom.roomName = UiHelper.getInstance().getCurrentUser().nickName;
				privateRoom.roomIconUrl = UiHelper.getInstance().getCurrentUser().userIconUrl;
				privateRoom.joinedMemberCount = 0;
				privateRoom.roomType = "2";  // マイミク情報
				
				this.rooms.addItem( privateRoom );

			} 
			else if(roomType == "3") 
			{
				// 産業技術大学院大学
				var room4:ChatRoom = new ChatRoom();
				room4.roomId = "o999999993";
				room4.roomName = "★AIIT（OPEN）★";
				room4.roomIconUrl = "";
				room4.joinedMemberCount = 0;
				room4.roomType = "3"; //open情報
				
				this.rooms.addItem( room4 );

				// サンプルルーム１
				var room1:ChatRoom = new ChatRoom();
				room1.roomId = "o999999990";
				room1.roomName = "★OPEN ROOM★";
				room1.roomIconUrl = "";
				room1.joinedMemberCount = 0;
				room1.roomType = "3"; //open情報
				
				this.rooms.addItem( room1 );
				
				// サンプルルーム２
				var room2:ChatRoom = new ChatRoom();
				room2.roomId = "o999999991";
				room2.roomName = "★居酒屋（OPEN）★";
				room2.roomIconUrl = "";
				room2.joinedMemberCount = 0;
				room2.roomType = "3"; //open情報
				
				this.rooms.addItem( room2 );

				// サンブルルーム３
				var room3:ChatRoom = new ChatRoom();
				room3.roomId = "o999999992";
				room3.roomName = "★TEST ROOM（OPEN）★";
				room3.roomIconUrl = "";
				room3.joinedMemberCount = 0;
				room3.roomType = "3"; //open情報
				
				this.rooms.addItem( room3 );
				

				// DUMMYs
/*
				for (var i:int = 1000; i < 6000; i++)
				{
					var r:ChatRoom = new ChatRoom();
					r.roomId = "dummy" + i.toString();
					r.roomName = "★dummy" + i.toString();
					r.roomIconUrl = "";
					r.joinedMemberCount = 0;
					r.roomType = "3"; //open情報
					
					this.rooms.addItem( r );
				} 
*/
			}
			return this.rooms;
		}
	}
}

