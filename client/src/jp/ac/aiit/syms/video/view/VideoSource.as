		import flash.events.Event;
		import flash.events.TimerEvent;
		import flash.display.Sprite;
		import flash.display.BlendMode;	  
		import flash.utils.Timer;
		
		import jp.ac.aiit.syms.room.model.User;
		import jp.ac.aiit.syms.video.model.SoundTitleBar;
		import jp.ac.aiit.syms.video.view.PeakMeter;
		import jp.ac.aiit.syms.video.view.VideoMediator;
		
		import mx.core.Application;
		import mx.core.IFlexDisplayObject;
		import mx.controls.Button;
		import mx.controls.Image;
		import mx.controls.Alert;
		import mx.events.CloseEvent;
		import mx.managers.PopUpManager;
		import mx.managers.CursorManager;
		import mx.utils.ObjectUtil;
		
		import org.osflash.thunderbolt.Logger;
		import org.puremvc.as3.patterns.facade.Facade;

	    
		public static const CAMERA_INIT:String = "camera_init";
	 	public static const CAMERA_CLOSE:String = "camera_close";
	 	public static const WINDOW_DRAG:String = "window_drag";
	 	public var cam:Camera = Camera.getCamera();
	 	//初期化の時、popup windowの位置
	 	[Bindable]
	 	public var winX:Number;
	  	[Bindable]		
	 	public var winY:Number;
	 
	 	public var dragX:int; // 移動のＸ
	 	public var dragY:int; // 移動のＹ
	 	
	 	public var xlb:int = -1; //x left bounds
	    public var xrb:int = -1; //x right bounds
	    public var ybb:int = -1; //y bottom bounds
	    public var ytb:int = -1; //y top bounds 
	 	
	 	public var initPosition:Boolean = false;
	 	
	 	public var vsliderWindow:PopupVslider;
 	
 		[Bindable]
 		[Embed(source="asserts/volume_unmute.png")]
		public var unMutelass:Class;
 		
 		[Bindable]
 		[Embed(source="asserts/volume_mute.png")]
		public var muteClass:Class;
		 
		public var myMic:Microphone; 
 		public var soundBar:SoundTitleBar;
 		public var peakMeter:PeakMeter;
 		
 		//タイマーの追加
		private var timer:Timer;
 		private var timerCount:int;
 		private var activeLevelCount:int;
 		
 		private var point0:Point = new Point();
 		private var point1:Point = new Point();
 		private var point2:Point = new Point();


		private function init():void {
 			soundBar = extBar as SoundTitleBar;
 			peakMeter = extBar2 as PeakMeter;
 			dispatchEvent(new Event(CAMERA_INIT));
 			this.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
 			var video:* = this.videoContainer.getChildByName('video');
 			if(video != null) {
 				video.width = 160;
 				video.height = 120;
 				
 			}
 			point0.x = 0;
 			point0.y = 0;
 			
 			if(myMic !=null) {
 				createMic();
 			}
 			
 			//タイマーの追加
 			timer = new Timer(1000, 1);
 			timer.addEventListener(TimerEvent.TIMER,onTimer);
 			timerCount = 0;
 			activeLevelCount = 0;
// 			timer.start();

 		}

// サイズ変更マウス状態変更 Start
	
      private const SIZE_DRAGAREA:int = 18;
      private const SIZE_MIN_WIDTH:int = 40;
      private const SIZE_MIN_HEIGHT:int = 30;
	
      private var blDragRightBottom:Boolean = false;
      
      private var iDragPosHeight:int = 0;
      private var iDragPosWidth:int = 0;
      
      
      [Embed(source="/asserts/c_resize.gif")]
      private var custCursorC:Class; 
      
      private function onMouseOver(event:MouseEvent):void
      {
      	if (( this.width - SIZE_DRAGAREA < event.localX ) &&
      		(this.height - SIZE_DRAGAREA < event.localY)) {
      		CursorManager.setCursor(custCursorC, -5, -5);
      	}
      }

      private function onMouseOut(event:MouseEvent):void
      {
        CursorManager.removeAllCursors();
      }

      private function onMouseDown(event:MouseEvent):void
      {      
        // check Right Bottom pos
        if( (this.width - SIZE_DRAGAREA < event.localX) &&
        	(this.height - SIZE_DRAGAREA < event.localY))
        {
          blDragRightBottom = true;
          iDragPosWidth = this.width - event.localX;
          iDragPosHeight = this.height - event.localY;
        }
      }

      

// サイズ変更マウス状態変更 End

 		// window move
        private function moveMe():void {
        	this.dragX = this.x;
        	this.dragY = this.y;
        	
            if(xrb >= 0 && this.x+this.width >= xrb){
            	this.move(this.x-1,this.y);
                this.dragX = this.x-1;
                this.dragY = this.y;
            }
        
            if(xlb >= 0 && this.x <= xlb){
            	this.move(this.x+1,this.y);
                this.dragX = this.x+1;
                this.dragY = this.y;
            }
            
            if(ybb >=0 && this.y+this.height >= ybb){
            	this.move(this.x,this.y-1);
                this.dragX = this.x;
                this.dragY = this.y-1;
            }
        
            if(ytb >=0 && this.y <= ytb){
            	this.move(this.x,this.y+1);
                this.dragX = this.x;
                this.dragY = this.y+1;
            }
            
		dispatchEvent(new Event(VideoWindow.WINDOW_DRAG));			
			 
        } 
 		
		private function titleWindow_close(evt:CloseEvent):void {
			PopUpManager.removePopUp(evt.target as IFlexDisplayObject);
			dispatchEvent(new Event(CAMERA_CLOSE));
        }
        
        // リサイズ可能にするイベントハンドラ
		private function handleMouseDown(event:MouseEvent):void {
			if (Math.abs(this.width - event.localX)<10 && 
				Math.abs(this.height - event.localY)<30) {
				systemManager.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
				systemManager.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			}
		}
		
		private function handleMouseMove(event:MouseEvent):void {
			var w:int = 160;
			var h:int = 120;
			if(!initPosition) {
				w = Math.max(100, Math.min(event.stageX - this.x, 320) );
				h = Math.max(100, Math.min(event.stageY - this.y, 240) );
	
				//↓↓↓↓ ビデオウィンドの縦横を　320:240比例に保つ
				if((w * (30)) > (h * 40)){
					h = (w * 30) /40 ;
				}else if((w * 30) < (h * 40)){
					w = (h * 40) /30 ;
				}else{
				
				}
			}
			//↑↑↑↑↑↑
			// ビデオの位置
			if( this.x + w >= xrb || this.y + h >= ybb) {
				this.move(dragX, dragY);
				initPosition = true;
				timer.start();
			}
			this.width = w;
			this.height = h + 20;

			var video:* = this.videoContainer.getChildByName('video');
			if ( video != null )
			{
				video.width = w;
				video.height = h;
			}
			this.invalidateDisplayList();
      		CursorManager.setCursor(custCursorC, 2, 0);
		}
		private function handleMouseUp(event:MouseEvent):void {
			systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			systemManager.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp)
	        CursorManager.removeAllCursors();
	}
		
		public function createMic():void {
			myMic.addEventListener(ActivityEvent.ACTIVITY, activity);
			myMic.addEventListener(StatusEvent.STATUS, statusHandle);
			myMic.addEventListener(Event.ACTIVATE, activeHandle);
		}
		
		private function activeHandle(event:Event):void {
			
		}
		
		private function statusHandle(event:StatusEvent):void {
			
		}

		private function activity(event:ActivityEvent):void {
			
		}
		
		/**
        * タイマーイベント
        */
/* 		private function onTimer(evt:TimerEvent):void {
			if(timerCount < 3) {
				timerCount++;
			} else {
				timerCount = 0;
				if(activeLevelCount > 3) {
					myMic.gain *=0.8;
					activeLevelCount = 0;
				}
			}
			
			if(ObjectUtil.numericCompare(myMic.activityLevel, Number(20) )== 1) {
				activeLevelCount++;
			}

		} */
		private function onTimer(evt:TimerEvent):void {
			initPosition = false;
		}