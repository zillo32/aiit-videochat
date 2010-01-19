package jp.ac.aiit.syms.preload
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	import mx.events.*;
	import mx.preloaders.DownloadProgressBar;

	public class CustomPreloader extends DownloadProgressBar {

        public var wcs:WelcomeScreen;
    
        public function CustomPreloader() 
        {
            super(); 
            wcs = new WelcomeScreen();
            this.addChild(wcs)                   
        }
    
        override public function set preloader( preloader:Sprite ):void 
        {         	      
            preloader.addEventListener( ProgressEvent.PROGRESS , SWFDownloadProgress );    
            preloader.addEventListener( Event.COMPLETE , SWFDownloadComplete );
            preloader.addEventListener( FlexEvent.INIT_PROGRESS , FlexInitProgress );
            preloader.addEventListener( FlexEvent.INIT_COMPLETE , FlexInitComplete );
        }
    
        private function SWFDownloadProgress( event:ProgressEvent ):void {}
    
        private function SWFDownloadComplete( event:Event ):void {}
    
        private function FlexInitProgress( event:Event ):void {}
    
        private function FlexInitComplete( event:Event ):void 
        {      
        	wcs.ready = true;  	
            dispatchEvent( new Event( Event.COMPLETE ) );
        }
        
 	}

}