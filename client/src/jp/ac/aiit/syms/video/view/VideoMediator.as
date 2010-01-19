package jp.ac.aiit.syms.video.view
{
	import flash.events.*;
	import flash.geom.Point;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.SharedObject;
	import flash.utils.Timer;
	
	import jp.ac.aiit.syms.ApplicationFacade;
	import jp.ac.aiit.syms.chat.model.UserProxy;
	import jp.ac.aiit.syms.room.model.User;
	import jp.ac.aiit.syms.room.model.service.HallService;
	import jp.ac.aiit.syms.room.model.service.RoomService;
	import jp.ac.aiit.syms.util.UiHelper;
	import jp.ac.aiit.syms.video.model.*;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Image;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class VideoMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "VideoMediator";
		
		private var roomService:RoomService;
		private var hallService:HallService;
		private var uiHelper:UiHelper;
		
		// 固定の値 X　ｙ
		private var dx:int = 10;
		private var dy:int = 20;
		
		// 最大のX.Y
		private var maxX:int = Application.application.videowindow.width + 20;
		private var maxY:int = Application.application.videowindow.height
            					+ Application.application.conversation.height
            					- Application.application.conversation.conversionControlBar.height + 30 + 4;   
		
		public function VideoMediator(viewComponent:Object)
		{
			super(NAME, viewComponent);
			
			userProxy = UserProxy(facade.retrieveProxy(UserProxy.NAME ));
			videoProxy = VideoProxy(facade.retrieveProxy(VideoProxy.NAME));
			
			roomService = RoomService(facade.retrieveProxy(RoomService.NAME));
			hallService = HallService(facade.retrieveProxy(HallService.NAME));
			
			uiHelper = UiHelper(facade.retrieveProxy(UiHelper.NAME));
			
			panel.addEventListener(VideoWindowContainer.CHANGE_VIDEO_CONTAINER_SIZE, changeVideoWindowMoveHandle);
			
			
		
		}
		
		override public function listNotificationInterests():Array
		{
			return [ ApplicationFacade.SELECTED_VIDEO_DISPLAY,
					  ApplicationFacade.VIDEO_SENDER,
					  ApplicationFacade.LEAVE_CURRENT_ROOM_VIDEO,
					  ApplicationFacade.GET_LEAVE_ROOM_NOTIFICATION
					];
		}
		
		/**
		 * 
		 * handleNotification()
		 * Notification発生時の振る舞いを定義する
		 * 
		 */
		override public function handleNotification( notification:INotification ):void
		{
			trace("handleNotification()");
			switch ( notification.getName() )
			{
				case ApplicationFacade.VIDEO_SENDER:
					popUpVideoWindow();
					sender = notification.getBody() as NetConnection;
					videoWindow.addEventListener(VideoWindow.CAMERA_INIT, cameraSender);
					videoWindow.addEventListener(VideoWindow.CAMERA_CLOSE, cameraWindowClose);
					videoWindow.addEventListener(VideoWindow.WINDOW_DRAG, windowDragHandler);
					break;
				case ApplicationFacade.SELECTED_VIDEO_DISPLAY:
					var obj:Object = notification.getBody();
					user = new User();
					user.setId(String(obj.id));
					user.setNickName(String(obj.nickName));
					user.setJoinedTime(String (obj.joinedTime));
					user.setUserIconUrl(String (obj.userIconUrl));
					user.setHasCamera(Boolean (obj.hasCamera));
					user.setRoom(String (obj.room));
					user.setCamDenyFlg(Boolean(obj.camDenyFlg));
					if(Boolean(obj.hasCamera) && videoProxy.isDisplayvideoUser(user.getNickName()) == "1")
					{

						popUpVideoWindow(user.getNickName());
						videoWindow.addEventListener(VideoWindow.CAMERA_INIT, selectedCameraPublishAndReceive);
						videoWindow.addEventListener(VideoWindow.CAMERA_CLOSE, cameraWindowClose);
						videoWindow.addEventListener(VideoWindow.WINDOW_DRAG, windowDragHandler);
					}
					else if(videoProxy.isDisplayvideoUser(user.getNickName()) == "0")
					{
						var vUser:VideoUser = videoProxy.getSelectedVideoUser(user.getNickName());
						PopUpManager.bringToFront(vUser.videoWindow);
					}
					break;	
				case ApplicationFacade.LEAVE_CURRENT_ROOM_VIDEO:
					closePopUpSelfUserVideoWindow();
					break;
				case ApplicationFacade.GET_LEAVE_ROOM_NOTIFICATION:
					var vName:String = notification.getBody() as String;
					closeUpVideoWindow(vName, "one");	
					closeAllPopUpWindow(vName);
			}
		}
		
		private function setMicActivityLevelToSharedObject(nc:NetConnection):void
		{
			createRemoteSharedObject(nc);
			this.soTimer = new Timer( 200, 0 ); // send microphone activity level (200 millisecond interval)
			this.soTimer.addEventListener( TimerEvent.TIMER, this.onMicActivity );
			this.soTimer.start();
		}
		
		private function onMicActivity(e:TimerEvent):void
		{
			var currentLevel:int = this.mic.activityLevel / 10;
			if(this.panel.selfVideoWindow.peakMeter != null) {
				this.panel.selfVideoWindow.peakMeter.peakmeter.value = currentLevel;
			} else {
				trace("peakMeter is null");
			}
			this.so.setProperty( uiHelper.getCurrentUser().nickName , currentLevel );

		}
		
		private function createRemoteSharedObject(nc:NetConnection):void
		{
			if ( this.so == null )
			{
				var soName:String = 'micActivityLevelSharedObject';
				this.so = SharedObject.getRemote( soName, nc.uri, false );
				this.so.fps = 5;
				this.so.connect(nc);
				
				this.addEventOnSync( this.onSyncSharedObject );

			}
		}
				
		public function addEventOnSync(f:Function):void
		{
			this.so.addEventListener(SyncEvent.SYNC, f);
		}

		private function onSyncSharedObject(e:SyncEvent):void
		{
			var objectList:Array = e.changeList;
//	Logger.info( "onSyncSharedObject : objectList.length : " +  objectList.length );
			for ( var i:int = 0; i < objectList.length; i++ )
			{
				
				for(var index:String in videoProxy.videoUserList) {
				var vUser:VideoUser = videoProxy.videoUserList[index] as VideoUser;

//	Logger.info( "onSyncSharedObject : objectList[" + i + "].name : " +  objectList[i].name );
//	Logger.info( "onSyncSharedObject : vUser.getVideoName() : " + vUser.getVideoName() );
//	Logger.info( "onSyncSharedObject : ObjectUtil.toString( e.target.data ) : " +  ObjectUtil.toString( e.target.data ) );

					if( objectList[i].name == vUser.getVideoName() )
					{
						vUser.videoWindow.peakMeter.peakmeter.value = e.target.data[vUser.getVideoName()];
					}
				}

			}
		}
		

		private function changeVideoWindowMoveHandle(event:Event):void {
			for(var index:String in videoProxy.videoUserList) {
				var vWindow:VideoWindow = videoProxy.videoUserList[index].videoWindow as VideoWindow;
//            	vWindow.xrb = maxX;
            	vWindow.xrb = Application.application.videowindow.width + 20 + 4;
            	vWindow.ybb = maxY
			}
		}
		
		private function popUpVideoWindow(userName:String = ""): void {
			var vUser:User = uiHelper.getCurrentUser();
			videoWindow = new VideoWindow();
			if(userName != "") {
				videoWindow.title = userName;

			} else {
				videoWindow.title = vUser.getNickName();
				panel.selfVideoWindow = videoWindow;
				
			}
			//初期化の位置
			var count:int = videoProxy.videoUserList.length;
			
			if(Math.abs(videoProxy.winX + videoWindow.width - maxX) < Math.abs(dx)
				&& Math.abs(videoProxy.winY + videoWindow.height - maxY) < dy) {
				videoProxy.winY = 20;
				dx = -10;
			} else if(videoProxy.winY + videoWindow.height >= maxY 
						|| Math.abs(videoProxy.winY + videoWindow.height - maxY) < dy ) {
				videoProxy.winY = 20;
				videoProxy.winX = 20;				
				dx = 10;
			} else if(Math.abs(videoProxy.winX + videoWindow.width - maxX) < Math.abs(dx)) {
				dx = -10;
			}
			videoProxy.winX = videoWindow.winX = videoProxy.winX + dx;
			videoProxy.winY = videoWindow.winY = videoProxy.winY + dy;

		    videoWindow.xlb = 20;
            videoWindow.xrb = maxX;
            videoWindow.ytb = 20 + 25;
            videoWindow.ybb = maxY
			
			PopUpManager.addPopUp(videoWindow, panel, false);
			videoWindow.setFocus();
			
			//create or update video users
			createVideoUser(videoWindow.title, null, null, videoWindow, "0");
			
		}
		
		// self video windwo closed
		private function closePopUpSelfUserVideoWindow():void {
			PopUpManager.removePopUp(panel.selfVideoWindow);
		}
		
		// self leave current room close all video window
		private function closeAllPopUpWindow(videoName:String=""):void {
			var myName:String = uiHelper.getCurrentUser().nickName;
			if(videoName == "" || (myName == videoName) ) {
				var vUsers:ArrayCollection = videoProxy.videoUserList;
				for(var index:String in vUsers) {
					var vName:String = vUsers[index].videoName;
					closeUpVideoWindow(vName, "all");
					
				}
				videoProxy.removeVideoUser(null, "all");
			}
			
		}
		
		private function createVideoUser(vName:String = "", pStream:NetStream = null, 
											rStream:NetStream = null, vWindow:VideoWindow = null, 
											windowClose:String=""):void {
			
			var videoUser:VideoUser = null;
			// ビデオウェドを閉じる時、取得した音をスピーカーから流さないようにする
			if(windowClose == "1") {
				videoUser = videoProxy.getSelectedVideoUser(vName);
				//サウンドトランスフォーム
				var trans:SoundTransform = new SoundTransform();
				trans.volume = 0.0; //ボリューム
				videoUser.videoWindow.myMic.soundTransform = trans; //サウンドトランスフォームをセット
				if (videoUser.receiveStream != null) {
					videoUser.receiveStream.close();
				}
			} else {
				videoUser = new VideoUser();
				videoUser.videoName = vName;
				videoUser.videoWindow = vWindow;

				videoUser.publishStream = pStream;
				videoUser.receiveStream = rStream;

			} 
			videoUser.windowClose = windowClose;
			videoProxy.addVideoUser(videoUser);
		}
		
		/**
		 * 
		 * panel()
		 * ビューコンポーネントの取得
		 *  
		 */
		private function get panel():VideoWindowContainer  {
			return viewComponent as VideoWindowContainer;
		}
		
       
         private function cameraSender(event:Event = null): void {
				room = uiHelper.getCurrentRoom();
				roomId = uiHelper.getCurrentRoomId();
				var me:User = uiHelper.getCurrentUser();
				cam = videoWindow.cam;
				mic = Microphone.getMicrophone();

				var userName :String = me.getNickName();
				var hasCamera:Boolean = me.hasCamera;
				var denyFlg:Boolean = me.camDenyFlg;
				var soundVal:Number = -1;
				if(denyFlg)
				{
					closePopUpSelfUserVideoWindow();
				}
				else
				{
					if (cam != null || mic != null)
					{
	
	 					publishStream = new NetStream(sender);
						if (cam != null)
						{
							cam.addEventListener(StatusEvent.STATUS, statusHandler);
							hasCamera = true;						
							cam.setMode(320, 240, 30);
	        				cam.setQuality(0,90);
							publishStream.attachCamera(cam);
	
							var video:Video = new Video(320, 240);
							video.name = 'video';
							video.attachCamera(cam);
							videoWindow.videoContainer.addChild(video);
							
						}
						else
						{
							closePopUpSelfUserVideoWindow();
						}			
						if (mic != null)
						{
							mic.setUseEchoSuppression(true);
							mic.setLoopBack(true);
							mic.gain = 20;
							soundVal = mic.gain;
							mic.rate = 44;
							videoWindow.myMic = mic;
							publishStream.attachAudio(mic);
						}
						publishStream.publish(userName, "live");
					} 
				}
				updateCurrentCameraStatus(hasCamera, false);
				
				//update current video user
				createVideoUser(userName, publishStream, null, null, "0");
				//音量windowの初期化
				initPopupSoundVsliderWindow(videoWindow, userName, soundVal);
				
				// 20091003 yoshida add
				setMicActivityLevelToSharedObject(sender);

        }
        
        private function statusHandler(event:StatusEvent):void {
        	switch(event.code)
        	{
        		case "Camera.Muted":
        			trace("User clicked Deny.");
        			// close self popup windwo
        			closePopUpSelfUserVideoWindow();
        			updateCurrentCameraStatus(false, true);
        			break;
        		case "Camera.Unmuted":
        			trace("User clicked Accepted.");
        			break;	
        	}
        }
  		/**
  		 * 音量窓口の初期化
  		 */
        private function initPopupSoundVsliderWindow(vWindow:VideoWindow, uName:String, sVal:Number):void {
        	var vUser:VideoUser = videoProxy.getSelectedVideoUser(uName);
        	var sWindow:PopupVslider = new PopupVslider();
        	vUser.soundWindow = sWindow;
        	vUser.soundVal = sVal;
        	sWindow.addEventListener(PopupVslider.SOUND_SLIDER, soundVolumeChangeHandle);
        	vUser.videoWindow.soundBar.iconSound.addEventListener(MouseEvent.CLICK, changeSoundImgHandle);
        	vUser.videoWindow.addEventListener(MouseEvent.MOUSE_OVER, soundSliderCloseHandle);
        	videoProxy.updateVideoUser(vUser);
        }
          /**
  		 * 音量ボリュームの変更
  		 */ 
        private function soundVolumeChangeHandle(evt:Event):void {
        	var popVSliderWindow:PopupVslider = evt.currentTarget as PopupVslider;
        	var vWindow:VideoWindow = popVSliderWindow.videoParent;
        	var uName:String = vWindow.title;
        	var vUser:VideoUser = videoProxy.getSelectedVideoUser(uName);
        	var curVolume:Number = popVSliderWindow.slider.value; 
        	vUser.soundVal = curVolume;

			// [2009/09/10 yoshida] サウンドコントロールが制御できるよう修正
			if (vUser.receiveStream != null){
        		vUser.receiveStream.soundTransform = new SoundTransform( curVolume / 100 );
			}
//        	Logger.info("vUser.receiveStream.soundTransform.volume : " + vUser.receiveStream.soundTransform.volume);
//        	Logger.info("vUser.videoName : " + vUser.videoName);
//        	Logger.info("vUser.soundVal : " + vUser.soundVal);

        	//音量アイコンの変更
        	 if(curVolume == 0) {
              	vWindow.soundBar.iconSound.source = vWindow.muteClass;
              } else {
              	vWindow.soundBar.iconSound.source = vWindow.unMutelass;
              }
        	videoProxy.updateVideoUser(vUser);
        }
        
         /**
  		 * 音量VSliderのPOPUP
  		 */
        private function changeSoundImgHandle(evt:MouseEvent):void {
        	var sImg:Image = evt.currentTarget as Image;
        	var sBar:SoundTitleBar = sImg.parent as SoundTitleBar;
        	var uiComponent:UIComponent = sBar.parent as UIComponent;
        	var vWindow:VideoWindow = uiComponent.parent as VideoWindow;
        	var vName:String = vWindow.title;
        	popupVsliderWindow(vName); 
        }
        
         /**
  		 * 音量窓口のpopup
  		 */
        private function popupVsliderWindow(vName:String):void {
 			var vUser:VideoUser = videoProxy.getSelectedVideoUser(vName);
 			//音量窓口を閉じる時
 			if(vUser.soundWindowClose != "0") {
	 			var vSliderWindow:PopupVslider = vUser.soundWindow;
	 			var vWindow:VideoWindow = vUser.videoWindow;
	 			var soundVol:Number = vUser.soundVal;
	 			var point2:Point = new Point();
	 			var point0:Point = new Point();
	 			PopUpManager.addPopUp(vSliderWindow, vWindow, false);
	        	point2 = vWindow.soundBar.iconSound.localToGlobal(point0);
	        	vSliderWindow.sliderX = point2.x - 5;
	        	vSliderWindow.sliderY = point2.y + 22;
	        	vSliderWindow.videoParent = vWindow;
	        	vSliderWindow.curVolume = soundVol;
	        	vUser.setSoundWindowClose("0"); // 音量窓口open
    		}
        }
         
         /**
  		 * 音量窓口のclose
  		 */
        private function soundSliderCloseHandle(evt:MouseEvent):void {
        	if(evt.currentTarget as VideoWindow) {
        		var vWindow:VideoWindow = evt.currentTarget as VideoWindow;
        		var vName:String = vWindow.title;
        		var vUser:VideoUser = videoProxy.getSelectedVideoUser(vName);
        		if(vUser.soundWindowClose != "1" ) {
        			PopUpManager.removePopUp(vUser.soundWindow);
        			vUser.setSoundWindowClose("1"); // 音量窓口close
        			videoProxy.updateVideoUser(vUser);  
        		}
        		
        	}
        }
        
  		private function updateCurrentCameraStatus(hasCamera:Boolean, denyFlg:Boolean):void
  		{
  			var me:User = uiHelper.getCurrentUser();
  			me.setHasCamera(hasCamera);
  			if(denyFlg) {
  				me.camDenyFlg = true;
  			}
  			uiHelper.setCurrentUser(me);
  			roomService.updateMemberList();
  		}
  		
        private function selectedCameraPublishAndReceive(event:Event = null):void {
        	var userName:String = user.getNickName();
			
			sender = RoomService.sender;
			receiveStream = new NetStream(sender);
	      	receiveStream.client = new CallBack();

			var video:Video = new Video(320, 240);
			video.attachNetStream(receiveStream);
			video.name = 'video';
			videoWindow.videoContainer.addChild(video);

			videoWindow.myMic = Microphone.getMicrophone();//Microphoneクラスセット
			videoWindow.myMic.gain = 50; //ゲイン
			videoWindow.myMic.rate = 44;
			videoWindow.myMic.setUseEchoSuppression( true ); //エコーの抑制
			videoWindow.myMic.setLoopBack(true);
			videoWindow.myMic.setSilenceLevel( 0, 3000 ); //サイレンスの閾値
			//自分の音をスピーカーから流されないようにする
			if(uiHelper.getCurrentUser().nickName == userName) {
				//サウンドトランスフォーム
				var trans:SoundTransform = new SoundTransform();
				trans.volume = 0.0; //ボリューム
				videoWindow.myMic.soundTransform = trans; //サウンドトランスフォームをセット
			}

			// 20090915 yoshida 音声が途切れなくなるようバッファを増やしてみる
			receiveStream.bufferTime = 0.1;
			receiveStream.play(userName);
			
			//update video user
			createVideoUser(userName, null, receiveStream, null, "0");
			//音量windowの初期化
			var vUser:VideoUser = videoProxy.getSelectedVideoUser(userName);
			var sound:Number = 50;
			if(vUser.soundVal != -1) {
				sound = vUser.soundVal; //videoWindow 再開
			}
			//音量アイコンの変更
			videoWindow.soundBar.iconSound.source = videoWindow.unMutelass;
			initPopupSoundVsliderWindow(videoWindow, userName, sound);
        }
        
        
        // close the video user window, user is leave the room too
        private function closeUpVideoWindow(videoName:String, doFlg:String):void {
        	var vUser:VideoUser = videoProxy.getSelectedVideoUser(videoName);
        	
        	PopUpManager.removePopUp(vUser.videoWindow);

			if (vUser.publishStream != null) {
					vUser.publishStream.close();
			}
			if (vUser.receiveStream != null) {
				vUser.receiveStream.close();
			}
			if(doFlg == "one") {
				videoProxy.removeVideoUser(vUser, "one");
			}
        	
        }
        
        // close the video user window, user is not leave the room
        private function cameraWindowClose(event:Event= null):void {
        	videoWindow = event.currentTarget as VideoWindow;
        	var vUser:String = videoWindow.title;
			createVideoUser(vUser, null, null, videoWindow, "1");

        }
        
        private function windowDragHandler(event:Event = null):void {
 			videoWindow = event.currentTarget as VideoWindow;
 			videoProxy.winX = videoWindow.dragX;
 			videoProxy.winY = videoWindow.dragY;
          }
       
        private var userProxy:UserProxy;
        private var videoProxy:VideoProxy;
        private var videoWindow:VideoWindow;
        private var sender:NetConnection; 
        private var room:String;
        private var roomId:String;
        private var user:User;
        private var receiveStream:NetStream;
        private var publishStream:NetStream;
        private var cam:Camera;
        private var mic:Microphone;
        private var so:SharedObject;
        private var soTimer:Timer;
 	}
}