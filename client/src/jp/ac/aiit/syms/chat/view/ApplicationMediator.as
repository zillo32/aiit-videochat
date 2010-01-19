package jp.ac.aiit.syms.chat.view
{
	import jp.ac.aiit.syms.ApplicationFacade;
	import jp.ac.aiit.syms.chat.model.*;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class ApplicationMediator extends Mediator implements IMediator
	{

        public static const NAME:String = "ApplicationMediator";

		private var contactProxy:ContactProxy;
		private var userProxy:UserProxy;
       
        public function ApplicationMediator( viewComponent:Object ) 
        {
            super( NAME, viewComponent );


            facade.registerMediator(new ConversationMediator(app.conversation));
            
            contactProxy = ContactProxy( facade.retrieveProxy( ContactProxy.NAME ) );
            userProxy = UserProxy(facade.retrieveProxy(UserProxy.NAME));

        }

        override public function listNotificationInterests():Array 
        {
            
            return [	
					];
        }

        override public function handleNotification( note:INotification ):void 
        {
           
        }

        protected function get app():Integrated
		{
            return viewComponent as Integrated
        }

	}
}