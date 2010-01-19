package jp.ac.aiit.syms.chat.controller
{
	import jp.ac.aiit.syms.chat.view.*;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class ChatViewPrepCommand extends SimpleCommand
	{
		override public function execute( note:INotification ):void 
		{
			 // Register the ApplicationMediator
             facade.registerMediator( new ApplicationMediator( note.getBody() ) ); 
 		}
		
	}
}