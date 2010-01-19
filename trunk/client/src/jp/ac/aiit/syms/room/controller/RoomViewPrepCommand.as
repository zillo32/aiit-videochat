package jp.ac.aiit.syms.room.controller
{
	import jp.ac.aiit.syms.room.view.*;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class RoomViewPrepCommand extends SimpleCommand
	{
		override public function execute( notification:INotification ):void 
		{
			// Mediatorの登録
			var app:Integrated =  notification.getBody() as Integrated;
			facade.registerMediator(new RoomInfoMediator(app.roomInfo));

 		}
		
	}
}