package jp.ac.aiit.syms.room.controller
{
	import jp.ac.aiit.syms.room.model.*;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
		
	public class RoomModelPrepCommand extends SimpleCommand
	{
        override public function execute( note:INotification ) :void    
		{
			facade.registerProxy( new ChatRoomProxy() );
//			facade.registerProxy(new SocialUserProxy() );

        }
		
	}
}