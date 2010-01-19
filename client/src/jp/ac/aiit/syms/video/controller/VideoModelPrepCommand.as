package jp.ac.aiit.syms.video.controller
{
	import jp.ac.aiit.syms.video.model.*;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
		
	public class VideoModelPrepCommand extends SimpleCommand
	{
        override public function execute( note:INotification ) :void    
		{
			facade.registerProxy( new VideoProxy() );
        }
		
	}
}