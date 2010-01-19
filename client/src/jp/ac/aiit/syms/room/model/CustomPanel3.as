package jp.ac.aiit.syms.room.model
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.Panel;
	import mx.controls.Image;
	import mx.core.Application;

	[Event(name="titleBtnClick", type="flash.events.MouseEvent")]
	[Style(name="titleBtnStyleName", type="String", inherit="no")]
	
	public class CustomPanel3 extends Panel{
	
		private var _arrowImg:Image;
		[Bindable]
 		[Embed(source="asserts/leftArrow.png")]
		public var leftArrowClass:Class;

		[Bindable]
 		[Embed(source="asserts/rightArrow.png")]
		public var rightArrowClass:Class;
		
		public function CustomPanel3(){
			super();
		}
		
		// this method is called during the initialize phase
		// and is used to create the interface
		override protected function createChildren() : void{
		
			super.createChildren();		
			_arrowImg=new Image();
			_arrowImg.source = rightArrowClass;
			_arrowImg.height= 16;
			_arrowImg.width= 16;
			_arrowImg.buttonMode = true;
			_arrowImg.useHandCursor = true;					
			_arrowImg.addEventListener(MouseEvent.CLICK,handleTitleImgClick);			
			rawChildren.addChild(_arrowImg);
		
		}
		
		// this method is used every time there is a change in the DisplayList
		// to move and reorganize the interface
 		override protected function updateDisplayList (unscaledWidth:Number, unscaledHeight:Number):void{
		
			super.updateDisplayList(unscaledWidth, unscaledHeight);			
 			var y:int = borderMetrics.top/2- _arrowImg.height/2 ;
			var x:int = 0;
			_arrowImg.move(x, y);
 		} 

 		private function handleTitleImgClick(event:Event = null):void{
 			var appWidth:Number = Application.application.width;
			if(_arrowImg.source == rightArrowClass) {
				_arrowImg.source = leftArrowClass;
				Application.application.vDivide1.width = appWidth*0.93;
			} else {
				_arrowImg.source = rightArrowClass;
				Application.application.vDivide1.width = appWidth*0.65;
			}
		}
	}

}