package jp.ac.aiit.syms.video.model
{
	import jp.ac.aiit.syms.video.view.*;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	
	public class VideoProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "VideoProxy";
		public var videoUserList:ArrayCollection;
		
		//windowのX,Yの座標
		public var winX:Number = 40;
		public var winY:Number = 60;
		
		public function VideoProxy(data:Object = null)
		{
			super ( NAME, data );
			videoUserList = new ArrayCollection();
		}
		
		public function addVideoUser(videoUser:VideoUser):void
		{
			var isAdd:Boolean = true;
			for(var index:String in videoUserList)
			{

				if(videoUserList[index].videoName == videoUser.getVideoName())
				{
					updateVideoUser(videoUser);
					isAdd = false;
				}
			}
			if(isAdd)
			{
				videoUserList.addItem(videoUser);
			}
		}
		
		public function removeVideoUser(videoUser:VideoUser, doFlg:String):void
		{
			if(doFlg == "one") {
				for(var index:String in videoUserList)
				{
					if(videoUserList[index].videoName == videoUser.getVideoName())
					{
						videoUserList.removeItemAt(new int(index));
						break;
					}
				}	
			} else {
				videoUserList.removeAll();
			}
			
		}
		
		public function getSelectedVideoUser(videoName:String):VideoUser
		{
			var videoUser:VideoUser = new VideoUser();
			
			for(var index:String in videoUserList)
			{
				if(videoUserList[index].videoName == videoName)
				{
					videoUser = videoUserList[index];		
				}
			}
			return videoUser;
		}
		
		public function updateVideoUser(videoUser:VideoUser):void
		{
			for(var index:String in videoUserList)
			{
				if(videoUserList[index].videoName == videoUser.getVideoName())
				{
					if(videoUser.getPublishStream() != null)
					{
						videoUserList[index].publishStream = videoUser.getPublishStream();
					}
					
					if(videoUser.getReceiveStream() != null)
					{
						videoUserList[index].receiveStream = videoUser.getReceiveStream();
					}
					
					if(videoUser.getVideoWindow() != null)
					{
						videoUserList[index].videoWindow = videoUser.getVideoWindow();
					}
					
					if(videoUser.getWindowClose() != "")
					{
						videoUserList[index].windowClose = videoUser.getWindowClose();
					}
					
					//音量値
					if(videoUser.getSoundVal() != -1)
					{
						videoUserList[index].soundVal = videoUser.getSoundVal();
					}
					
					//音量window
					if(videoUser.getSoundWindow() != null)
					{
						videoUserList[index].soundWindow = videoUser.getSoundWindow();
					}
					//音量windowのopen / close
					if(videoUser.getSoundWindowClose() != "")
					{
						videoUserList[index].soundWindowClose = videoUser.getSoundWindowClose();
					}
				}
			}
		}
		
		public function isDisplayvideoUser(videoName:String):String
		{
			var isClose:String = "1"; // is not display
			
			for(var index:String in videoUserList)
			{
				if(videoUserList[index].videoName == videoName)
				{
					if(videoUserList[index].windowClose == 0)
					{
						isClose = "0"; // is display
 					}
					break;				
				}
			}
			return isClose;
		}
 	
	}
}