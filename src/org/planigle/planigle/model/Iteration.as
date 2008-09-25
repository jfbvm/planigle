package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	
	import org.planigle.planigle.commands.DeleteIterationCommand;
	import org.planigle.planigle.commands.UpdateIterationCommand;
	import org.planigle.planigle.model.ReleaseFactory;
	import org.planigle.planigle.model.Release;
	import org.planigle.planigle.model.StoryFactory;
	import org.planigle.planigle.model.Story;

	[RemoteClass(alias='Iteration')]
	[Bindable]
	public class Iteration
	{
		private const MILLIS_IN_WEEK:int = 7*24*60*60*1000;
		public var id:String;
		public var projectId: int;
		public var name:String;
		public var start:Date;
		public var length:int;
	
		// Populate myself from XML.
		public function populate(xml:XML):void
		{
			id = xml.id.toString() == "" ? null: xml.id;
			projectId = xml.child("project-id").toString() == "" ? null : xml.child("project-id");
			name = xml.name;
			start = DateUtils.stringToDate(xml.start);			
			length = xml.length;
			finish = finish;
		}
		
		// Update me.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function update(params:Object, successFunction:Function, failureFunction:Function):void
		{
			new UpdateIterationCommand(this, params, successFunction, failureFunction).execute(null);
		}
		
		// I have been successfully updated.  Change myself to reflect the changes.
		public function updateCompleted(xml:XML):void
		{
			populate(xml);
		}
		
		// Delete me.  Success function if successfully deleted.  FailureFunction will be called if failed
		// (will be passed an XMLList with errors).
		public function destroy(successFunction:Function, failureFunction:Function):void
		{
			new DeleteIterationCommand(this, successFunction, failureFunction).execute(null);
		}
		
		// I have been successfully deleted.  Remove myself to reflect the changes.
		public function destroyCompleted():void
		{
			// Create copy to ensure any views get notified of changes.
			var iterations:ArrayCollection = new ArrayCollection();
			for each (var iteration:Iteration in IterationFactory.getInstance().iterations)
			{
				if (iteration != this)
					iterations.addItem(iteration);
			}
			IterationFactory.getInstance().updateIterations(iterations);
		}
		
		// Answer my end date
		public function get finish():Date
		{
			return new Date(start.time + length * MILLIS_IN_WEEK);
		}
		
		// Set my end date.  Used to send changed event.
		public function set finish(date:Date):void
		{
		}
		
		// Answer true if my dates include today.
		public function isCurrent():Boolean
		{
			var today:Date = new Date();
			return today.time > start.time && today.time < start.time + length * MILLIS_IN_WEEK;
		}
		
		// Answer the next iteration after this one.  If I am the backlog, return myself.
		public function next():Iteration
		{
			var iterations:ArrayCollection = IterationFactory.getInstance().iterationSelector;
			var i:int = iterations.getItemIndex( this );
			if (i < iterations.length - 1)
				return Iteration(iterations.getItemAt( i + 1 ));
			else
				return this;
		}

		// Increment my name (or return an empty string if I cannot do so).
		public function incrementName():String
		{
			var splits:Array = name.split(" ");
			if (int(splits[splits.length-1]) > 0)
				{ // Increment last component of name if an integer.
				splits[splits.length-1] = (int(splits[splits.length-1])+1).toString();
				return splits.join(" ");
				}
			else
	 			return '';
		}

		// Answer true if I am in a release (true if any part of me overlaps).
		public function isIn(release:Release):Boolean
		{
			return start <= release.finish && finish >= release.start;
		}

		// Answer true if I am active on a given date (true if any part of me overlaps).
		public function isActiveOn(date:Date):Boolean
		{
			return start <= date && finish >= date;
		}

		// Answer the releases that could be worked on during me.
		public function releases():ArrayCollection
		{
			if (!id)
				return ReleaseFactory.getInstance().releaseSelector;
			else
			{
				var releases:ArrayCollection = new ArrayCollection();
				for each (var release:Release in ReleaseFactory.getInstance().releaseSelector)
				{
					if (!release.id || isIn(release))
						releases.addItem(release);
				}
				return releases;
			}
		}

		// Answer my default release.
		public function defaultRelease():Release
		{
			var releases:ArrayCollection = releases();
			return Release((!id || releases.length < 2) ? releases.getItemAt(releases.length - 1) : releases.getItemAt(releases.length - 2));
		}

		// Answer the stories in me.
		public function stories():ArrayCollection
		{
			var stories:ArrayCollection = new ArrayCollection();
			for each(var story:Story in StoryFactory.getInstance().stories)
			{
				if (story.iterationId == id)
					stories.addItem(story);
			}
			return stories;
		}

		// Answer the stories that have been accepted in me.
		public function acceptedStories():ArrayCollection
		{
			var stories:ArrayCollection = new ArrayCollection();
			for each(var story:Story in StoryFactory.getInstance().stories)
			{
				if (story.iterationId == id && story.statusCode == Story.ACCEPTED)
					stories.addItem(story);
			}
			return stories;
		}
	}
}