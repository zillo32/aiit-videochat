package jp.ac.aiit.syms.room.model
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import jp.ac.aiit.syms.room.view.RoomList;
	
	import mx.containers.Panel;
	import mx.controls.Button;
	import mx.core.Application;

	[Event(name="titleBtnClick", type="flash.events.MouseEvent")]
	[Style(name="titleBtnStyleName", type="String", inherit="no")]
	
	public class CustomPanel extends Panel{
	
		private var _titleBtn:Button;
		
		public function CustomPanel(){
			super();
		}
		
		// this method is called during the initialize phase
		// and is used to create the interface
		override protected function createChildren() : void{
		
			super.createChildren();		
			_titleBtn=new Button();
			_titleBtn.height= 20;
			_titleBtn.width= 120;					
			_titleBtn.addEventListener(MouseEvent.CLICK,handleTitleBtnClick);			
			_titleBtn.label = "選択した部屋に入室";
			rawChildren.addChild(_titleBtn);
		
		}
		
		// this method is used every time there is a change in the DisplayList
		// to move and reorganize the interface
 		override protected function updateDisplayList (unscaledWidth:Number, unscaledHeight:Number):void{
		
			super.updateDisplayList(unscaledWidth, unscaledHeight);			
 			var y:int = borderMetrics.top/2- _titleBtn.height/2 ;
			var x:int = this.width - _titleBtn.width - borderMetrics.right;
			_titleBtn.move(x, y);
 		} 

 		private function handleTitleBtnClick(event:Event = null):void{
			trace("選択した部屋に入室");
//			Application.application.roomInfo.memberlist.customPanel2.btnChange("walkin");
			Application.application.roomInfo.roomlist.dispatchEvent(new Event(RoomList.WALK_IN_ROOM_BUTTON_CLICK));
		}
	}

}