package jp.ac.aiit.syms
{	
	import jp.ac.aiit.syms.room.controller.*;
	import jp.ac.aiit.syms.startup.controller.*;
	
	import org.puremvc.as3.patterns.facade.Facade;
	
	public class ApplicationFacade extends Facade
	{
		/////////////////////////////////////////////////
		// Notification name constants
		/////////////////////////////////////////////////
		// Chat
		public static const STARTUP:String = "startup";
		public static const SEND_CONVERSATION:String = "send_conversation";
		public static const SEND_MESSEGE_SOUND:String = "send_messege_sound";

		// Video
		public static const SELECTED_VIDEO_DISPLAY: String = "selected_video_display";
		public static const VIDEO_SENDER:String = "video_sender";
		
		// Room
		public static const WALK_IN_THE_ROOM:String = "walk_in_the_room";
		public static const CREATE_NEW_ROOM:String = "create_new_room";
		public static const LEAVE_CURRENT_ROOM_VIDEO:String = "leave_current_room_video";
		public static const LEAVE_CURRENT_ROOM:String = "leave_current_room";
		public static const ROOM_LIST:String = "room_list";
		public static const MEMBER_LIST:String = "current_room";
		public static const RETURN_TO_ROOMLIST:String = "return_to_roomlist";
		public static const GET_LEAVE_ROOM_NOTIFICATION:String = "get_leave_room_notification";
		public static const WALK_IN_ROOM_BUTTON_CLICK:String = "walk_in_room_button_click";
		public static const VIEW_MEMBERS_LIST:String = "view_members_list";	
		public static const USER_JOIN_ROOM_STATUS:String = "user_join_room_status";
		public static const ROOM_LIST_REFRESHED:String = "room_list_refreshed";
		public static const DOUBLE_ROOM_JOIN_CHECK:String = "double_room_join_check";
		public static const PROHIBIT_PREVIOUS_ROOM_LEAVE:String = "prohibit_previous_room_leave";
		public static const NEXT_ROOM_WALK_IN:String = "next_room_walk_in";
		public static const WALK_IN_NEXT_ROOM:String = "walk_in_next_room";
		/**
		 * Singleton ApplicationFacade Factory Method
		 */
		public static function getInstance() : ApplicationFacade {
			if ( instance == null ) instance = new ApplicationFacade();
			return instance as ApplicationFacade;
		}
		
		/**
		 * Register Commands with the Controller 
		 */
		override protected function initializeController( ) : void 	{
			super.initializeController();
			registerCommand( STARTUP,          StartupCommand );
			registerCommand( WALK_IN_THE_ROOM, WalkInTheRoomCommand );
		}
		
		/**
		 * Start the application
		 */
		public function startup( app:Object ):void	 {
			sendNotification( STARTUP, app );
		}
				
	}
}