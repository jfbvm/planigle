package org.planigle.planigle.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	
	import org.planigle.planigle.business.TasksDelegate;
	import org.planigle.planigle.model.Story;
	
	public class CreateTaskCommand implements ICommand, IResponder
	{
		private var story:Story;
		private var params:Object;
		private var notifySuccess:Function;
		private var notifyFailure:Function;
		
		public function CreateTaskCommand(aStory:Story, someParams:Object, aSuccessFunction:Function, aFailureFunction:Function)
		{
			story = aStory;
			params = someParams;
			notifySuccess = aSuccessFunction;
			notifyFailure = aFailureFunction;
		}
		
		// Required for the ICommand interface.  Event must be of type Cairngorm event.
		public function execute(event:CairngormEvent):void
		{
			new TasksDelegate( this ).createTask(story, params);
		}
		
		// Handle successful server request.
		public function result( event:Object ):void
		{
			var result:XML = XML(event.result);
			if (result.error.length() > 0)
			{
				if (notifyFailure != null)
					notifyFailure(result.error);
			}
			else
			{
				story.createTaskCompleted(result);
				if (notifySuccess != null)
					notifySuccess();
			}
		}
		
		// Handle case where error occurs.
		public function fault( event:Object ):void
		{
			Alert.show(event.fault.faultString);
		}
	}
}