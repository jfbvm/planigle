package org.planigle.planigle.control
{
	import com.adobe.cairngorm.control.FrontController;
	import org.planigle.planigle.events.*;
	import org.planigle.planigle.commands.*;
	
	public class ReleasesController extends FrontController
	{
		public function ReleasesController()
		{
			this.initialize();	
		}
		
		public function initialize():void
		{
			// Map event to command.
			this.addCommand(ReleaseChangedEvent.RELEASE_CHANGED, GetReleasesCommand);	
		}
	}
}