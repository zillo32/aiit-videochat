package jp.ac.aiit.syms.video.view
{  
    public class CallBack  
    {  
        public function onMetaData(info:Object):void {  
            trace("metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);  
        }  
          
        public function onCuePoint(info:Object):void {  
            trace("cuepoint: time=" + info.time + " name=" + info.name + " type=" + info.type);  
        }  
          
        public function onPlayStatus(info:Object):void {  
            trace("onPlayStatus call");  
        }  
    }  
}