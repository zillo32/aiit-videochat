package jp.ac.aiit.syms.chat.controller
{
	import jp.ac.aiit.syms.chat.model.*;
	import jp.ac.aiit.syms.room.model.service.HallService;
	import jp.ac.aiit.syms.room.model.service.RoomService;
	import jp.ac.aiit.syms.util.UiHelper;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class ChatModelPrepCommand extends SimpleCommand
	{
        override public function execute( note:INotification ) :void    
		{
			facade.registerProxy(new UiHelper() );
			facade.registerProxy(new HallService() );
			facade.registerProxy(new RoomService() );
			facade.registerProxy( new UserProxy() );
            facade.registerProxy( new ContactProxy() );			
        }
		
	}
}