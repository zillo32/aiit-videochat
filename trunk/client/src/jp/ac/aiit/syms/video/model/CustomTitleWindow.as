package jp.ac.aiit.syms.video.model
{
	import flash.display.DisplayObject;
	
	import mx.containers.TitleWindow;
	import mx.controls.Button;
    public class CustomTitleWindow extends TitleWindow
    {
        public function CustomTitleWindow() {
            super();
            verticalResizable = true;
        }
        private var _extBar:DisplayObject;
        private var _extBar2:DisplayObject;
        // bottom edge of the canvas
		private var _bottomEdge:Button;

        public function set extBar(extBar:DisplayObject):void {
            _extBar = extBar;
        }
        public function get extBar():DisplayObject {
            return _extBar;
        }
        public function set extBar2(extBar2:DisplayObject):void {
            _extBar2 = extBar2;
        }
        public function get extBar2():DisplayObject {
            return _extBar2;
        }
        public function set verticalResizable(value:Boolean):void
		{
/* 			// verticalResizable = true

			// we add the right edge which is a button
			_bottomEdge = new Button();
			// no label
			_bottomEdge.label = "";
			// no tooltip
			_bottomEdge.toolTip = null;
			_bottomEdge.tabEnabled = false;
			_bottomEdge.setStyle("bottom", 0);
			_bottomEdge.setStyle("horizontalCenter",0);
			_bottomEdge.percentWidth = 90;
			_bottomEdge.height = 9;
			// set its style
			// in this style we set the skin to not show anything
			_bottomEdge.styleName = "canvasBottomEdge";
			addChild(_bottomEdge); 
*/
		}
        
        override protected function createChildren():void {
            super.createChildren();
            if (_extBar) {
                titleBar.addChild(_extBar);        
            }
            if (_extBar2) {
                titleBar.addChild(_extBar2);        
            }
        }
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            if (_extBar) {
                _extBar.x = unscaledWidth-43;
                _extBar.y = 3;
                _extBar.width = unscaledWidth - 10;
                _extBar.height = titleBar.height - 4;
            }
            if (_extBar2) {
                _extBar2.x = unscaledWidth-78;
                _extBar2.y = 7;
                _extBar2.width = unscaledWidth - 10;
                _extBar2.height = titleBar.height - 4;
            }
        }
    }
}