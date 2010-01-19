package jp.ac.aiit.syms.video.model
{
	import flash.net.NetStream;
	
	import jp.ac.aiit.syms.video.view.PopupVslider;
	import jp.ac.aiit.syms.video.view.VideoWindow;
	
	public class VideoUser 
	{
		public var videoName:String;
		public var publishStream:NetStream;
		public var receiveStream:NetStream;
		public var videoWindow:VideoWindow;
		/*
		windowClose = 0: window is opened
		windwoClose = 1: window is closed
		*/
		public var windowClose:String;
		public var winX:Number;
		public var winY:Number;
		
		//音量値 （デフォルト値：　-1）
		public var soundVal:Number = -1;
		// 音量window
		public var soundWindow:PopupVslider;

		 /**
  		 * 音量窓口のclose/open
  		 * close: soundWindowClose = 1
  		 * open: soundWindowClose = 0;
  		 */
		public var soundWindowClose:String = "";
				
		public function VideoUser() {

		}

		public function getSoundWindow():PopupVslider {
			return this.soundWindow;
		}
		public function setSoundWindow(soundWindow:PopupVslider):void {
			this.soundWindow = soundWindow;
		}
		
		public function getSoundVal():Number {
			return soundVal;
		}
		public function setSoundVal(soundVal:Number):void {
			this.soundVal = soundVal;
		}
		
		public function getPublishStream():NetStream {
			return publishStream;
		}
		
		public function setPublishStream(publishStream:NetStream):void {
			this.publishStream = publishStream;
		}
		
		public function getVideoName():String {
			return videoName;
		}
		
		public function setVideoName(videoName:String):void {
			this.videoName = videoName;
		}
		
		public function getReceiveStream():NetStream {
			return receiveStream;
		}
		
		public function setReceiveStream(receiveStream:NetStream):void {
			this.receiveStream = receiveStream;
		}
		
		public function getVideoWindow():VideoWindow {
			return this.videoWindow;
		}
		
		public function setVideoWindwo(videoWindow:VideoWindow):void {
			this.videoWindow = videoWindow;
		}
		
		public function setWindowClose(windowClose:String):void {
			this.windowClose = windowClose;
		}
		
		public function getWindowClose():String {
			return this.windowClose;
		}
		
		public function getWinX():Number {
			return this.winX;
		}
		
		public function setWinX(winX:Number):void {
			this.winX = winX;
		}
		
		public function getWinY():Number {
			return this.winY;
		}
		
		public function setWinY(winY:Number):void {
			this.winY = winY;
		}
		
		public function setSoundWindowClose(soundWindowClose:String):void {
			this.soundWindowClose = soundWindowClose;
		}
		
		public function getSoundWindowClose():String {
			return this.soundWindowClose;
		}
	}
}