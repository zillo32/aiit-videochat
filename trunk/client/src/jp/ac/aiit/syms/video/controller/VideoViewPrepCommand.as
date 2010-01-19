package jp.ac.aiit.syms.video.controller
{
	import jp.ac.aiit.syms.room.view.MemberListMediator;
	import jp.ac.aiit.syms.video.view.*;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class VideoViewPrepCommand extends SimpleCommand
	{
		override public function execute( notification:INotification ):void 
		{
			// Mediatorの登録
			var app:Integrated =  notification.getBody() as Integrated;
//			facade.registerMediator(new MemberListMediator(app.memberlist ) );
			facade.registerMediator(new VideoMediator(app.videowindow ) );
 		}
	}
}