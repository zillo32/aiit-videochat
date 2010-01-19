package jp.ac.aiit.syms.room.model
{
	import flash.net.NetConnection;
	import mx.binding.utils.BindingUtils;
	import mx.core.Application;
	
	
	public class User
	{
		
		public var id:String;
		public var color:String;
		public var nickName:String;
		public var joinedTime:String;
		public var userIconUrl:String;
		public var hasCamera:Boolean;
		public var room:String;
		public var camDenyFlg:Boolean;
		
		//DummyObject
		public function User() {
			var randNum:Number = Math.round( Math.random() * 10000 );
			var randId:Number = 999999999 - randNum;
			this.id = "o" + randId.toString();
			this.color = Application.application.conversation.sendColorPicker.selectedColor;
			this.nickName = "debug" + randNum;
//			this.nickName = "yossy" + randNum;
			this.joinedTime = "";
			this.userIconUrl = "";
			this.hasCamera = false;
			this.room = "";
			this.camDenyFlg = false;
		}
		
		public function getId():String {
			return id;
		}
		
		public function setId(id:String):void {
			this.id = id;
		}
		
		public function getNickName():String {
			return nickName;
		}
		
		public function setNickName(nickName:String):void {
			this.nickName = nickName;
		}
		
		public function getJoinedTime():String {
			return joinedTime;
		}
		
		public function setJoinedTime(joinedTime:String):void {
			this.joinedTime = joinedTime;
		}
		
		public function isHasCamera():Boolean {
			return hasCamera;
		}
		
		public function setHasCamera(hasCamera:Boolean):void {
			this.hasCamera = hasCamera;
		}
		
		public function setUserIconUrl(userIconUrl:String):void {
			this.userIconUrl = userIconUrl;
		}
		
		public function getUserIconUrl():String {
			return this.userIconUrl;
		}
		
		public function setRoom(room:String):void {
			this.room = room;
		}
		
		public function isCamDenyFlg():Boolean {
			return camDenyFlg;
		}
		
		public function setCamDenyFlg(camDenyFlg:Boolean):void {
			this.camDenyFlg = camDenyFlg;
		}

		public function setColor(color:String):void {
			this.color = color;
		}
		public function getColor():String {
			return this.color;
		}
	}
}
