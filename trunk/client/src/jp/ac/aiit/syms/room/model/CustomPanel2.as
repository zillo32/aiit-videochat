package jp.ac.aiit.syms.room.model
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import jp.ac.aiit.syms.room.view.MemberList;
	import jp.ac.aiit.syms.room.view.RoomList;
	
	import mx.containers.Panel;
	import mx.controls.Button;
	import mx.core.Application;

	[Event(name="titleBtnClick", type="flash.events.MouseEvent")]
	[Style(name="titleBtnStyleName", type="String", inherit="no")]
	
	public class CustomPanel2 extends Panel{
	
		public var _titleBtn:Button;
		public var _titleBtn2:Button;
		
		public function CustomPanel2(){
			super();
		}
		
		// this method is called during the initialize phase
		// and is used to create the interface
		override protected function createChildren() : void{
		
			super.createChildren();		

			_titleBtn = new Button();
			_titleBtn.height= 20;
			_titleBtn.width= 50;
			_titleBtn.addEventListener(MouseEvent.CLICK,handleTitleBtnClick2);			
			_titleBtn.label = "退室";

			_titleBtn2 = new Button();
			_titleBtn2.height= 20;
			_titleBtn2.width= 50;	
			_titleBtn2.addEventListener(MouseEvent.CLICK,handleTitleBtnClick3);	
			_titleBtn2.label = "入室";
			
			if(!Application.application.roomInfo.joinedRoomFlg) {

				rawChildren.addChild(_titleBtn2);
			} else {

				rawChildren.addChild(_titleBtn);
			}
					
		}
		
		// this method is used every time there is a change in the DisplayList
		// to move and reorganize the interface
 		override protected function updateDisplayList (unscaledWidth:Number, unscaledHeight:Number):void{
		
			super.updateDisplayList(unscaledWidth, unscaledHeight);			
 			var y:int = borderMetrics.top/2- _titleBtn.height/2 ;
			var x:int = this.width - _titleBtn.width - borderMetrics.right;
			_titleBtn.move(x, y);
			
			var y2:int = borderMetrics.top/2- _titleBtn2.height/2 ;
			var x2:int = this.width - _titleBtn.width - borderMetrics.right ;
			_titleBtn2.move(x2, y2);
			
 		} 

 		 private function handleTitleBtnClick2(event:Event = null):void{
			trace("退室");
			Application.application.roomInfo.memberlist.dispatchEvent(new Event(MemberList.LEAVE_CURRENT_ROOM));
			
			_titleBtn.removeEventListener(MouseEvent.CLICK,handleTitleBtnClick2);
		 	rawChildren.removeChild(_titleBtn);
		 	
			_titleBtn2.addEventListener(MouseEvent.CLICK,handleTitleBtnClick3);	
		 	rawChildren.addChild(_titleBtn2);
		}
		 private function handleTitleBtnClick3(event:Event = null):void {
		 	trace("入室");
		 	Application.application.roomInfo.roomlist.dispatchEvent(new Event(RoomList.WALK_IN_ROOM_BUTTON_CLICK));
		 	
		 	_titleBtn2.removeEventListener(MouseEvent.CLICK,handleTitleBtnClick3);
		 	rawChildren.removeChild(_titleBtn2);
		 	
		 	_titleBtn.addEventListener(MouseEvent.CLICK,handleTitleBtnClick2);	
		 	rawChildren.addChild(_titleBtn);
		 }
		 
		 public function btnChange(changeBtn:String):void {
		 	if(changeBtn=="walkin") {
		 		_titleBtn2.removeEventListener(MouseEvent.CLICK,handleTitleBtnClick3);
		 		if(rawChildren.contains(_titleBtn2)) {
		 			rawChildren.removeChild(_titleBtn2);
		 		}
		 		_titleBtn.addEventListener(MouseEvent.CLICK,handleTitleBtnClick2);	
		 		rawChildren.addChild(_titleBtn);
		 	} else {
		 		if(rawChildren.contains(_titleBtn)) {
		 			_titleBtn.removeEventListener(MouseEvent.CLICK,handleTitleBtnClick2);
		 			rawChildren.removeChild(_titleBtn);
		 			_titleBtn2.addEventListener(MouseEvent.CLICK,handleTitleBtnClick3);	
		 			rawChildren.addChild(_titleBtn2);
		 		}
		 	}
		 }
	}

}