package jp.ac.aiit.syms.chat.view
{
	import flash.events.*;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	
	import jp.ac.aiit.syms.ApplicationFacade;
	import jp.ac.aiit.syms.chat.model.ContactProxy;
	import jp.ac.aiit.syms.chat.model.UserProxy;
	import jp.ac.aiit.syms.util.UiHelper;
	
	import mx.core.Application;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class ConversationMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "ConversationMediator";

		private var contactProxy:ContactProxy;
		private var userProxy:UserProxy;
		private var uiHelper:UiHelper;

		
		public function ConversationMediator(viewComponent:Object)
		{
			super(NAME, viewComponent);
			
			contactProxy = ContactProxy( facade.retrieveProxy( ContactProxy.NAME ) );
			userProxy = UserProxy(facade.retrieveProxy(UserProxy.NAME));
			uiHelper = facade.retrieveProxy(UiHelper.NAME) as UiHelper;
			
			conversationWin.addEventListener(ApplicationFacade.SEND_CONVERSATION, sendMessage);
			conversationWin.editor.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
		}
		
		override public function getMediatorName():String
		{
			return ConversationMediator.NAME;
		}
		
		public function get conversationWin() : ConversationWindow {
			
			return viewComponent as ConversationWindow;
		}

		override public function listNotificationInterests():Array
		{
			return [
						ApplicationFacade.SEND_MESSEGE_SOUND
					];
		}
		
		override public function handleNotification(note:INotification):void
		{	switch(note.getName())
			{
				case ApplicationFacade.SEND_MESSEGE_SOUND:
					var sendMsgSound:Sound = new conversationWin.sendMsgSoundClass as Sound;
					var soundTrans: SoundTransform  = new SoundTransform(1);
		 			if ( uiHelper.getPlaySoundStatus() )
		 			{
						sendMsgSound.play(0,0,soundTrans);
					}
					break;	
			}
		}
		
		private function sendMessage(event:Event = null):void {
// 			var name:String = userProxy.me.nickName;	
			var msg:String = conversationWin.editor.text;
			var roomId:String = Application.application.room;
			
//			Logger.info( 'ConversationMediator sendMessage - ' + msg );
			if( roomId && msg.length > 0 && conversationWin.editor.enabled )
			{
				contactProxy.sendMessenge(roomId, msg);
			} 
						
		}

		private function keyHandler(event:KeyboardEvent):void {
			if (event.keyCode == 13) {
				sendMessage();
			}
		}
 

	}
}