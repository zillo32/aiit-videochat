package jp.ac.aiit.syms.chat.model
{
	import jp.ac.aiit.syms.room.model.User;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class ContactList
	{
		public var users:ArrayCollection = new ArrayCollection();
		
		public function ContactList(roomId:String, user:User)
		{
			
			// サンプルルーム１とサンプルルーム２の参加者
			var joinedMemberCount:int= 5
			if(roomId == "999999990")
			{
				joinedMemberCount = 8;	
			}
			for(var i :int = 0; i < joinedMemberCount; i++) 
			{
				contact = new Contact();
				contact.userName = "サンプル" + i;
				contact.joinedTime = "";
				contact.videoStatus = "online";
				contact.roomId = roomId;
				this.users.addItem(contact);
			}
			contact = new Contact(user.getNickName(), roomId, "", "");
			this.users.addItem(contact);
		}
		private var contact:Contact;
	}
}