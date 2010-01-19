package jp.ac.aiit.syms.startup.controller
{
	import jp.ac.aiit.syms.chat.controller.*;
	import jp.ac.aiit.syms.room.controller.*;
	import jp.ac.aiit.syms.video.controller.*;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.command.*;

	public class StartupCommand extends MacroCommand
	{
		
		override protected function initializeMacroCommand() :void
        {
			// execute chat prepare commands
            addSubCommand( ChatModelPrepCommand );
            addSubCommand( ChatViewPrepCommand );


			// execute room prepare commands
            addSubCommand( RoomModelPrepCommand );
            addSubCommand( RoomViewPrepCommand );
            
            // execute video prepare commands;
            addSubCommand( VideoModelPrepCommand );
            addSubCommand( VideoViewPrepCommand );
        }
		
	}
}