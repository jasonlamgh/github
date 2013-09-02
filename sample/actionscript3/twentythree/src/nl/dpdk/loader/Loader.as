/*
Copyright (c) 2009 De Pannekoek en De Kale B.V.,  www.dpdk.nl

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 */
package nl.dpdk.loader {
	import flash.events.EventDispatcher;

	import nl.dpdk.collections.iteration.IIterator;
	import nl.dpdk.collections.lists.LinkedList;
	import nl.dpdk.commands.tasks.TaskEvent;
	import nl.dpdk.loader.events.LoaderEvent;
	import nl.dpdk.loader.events.LoaderItemEvent;
	import nl.dpdk.loader.events.LoaderItemProgressEvent;
	import nl.dpdk.loader.events.LoaderProgressEvent;
	import nl.dpdk.loader.specifications.LoadTaskByURLSpecification;
	import nl.dpdk.loader.tasks.LoadTask;
	import nl.dpdk.utils.StringUtils;

	/**
	 * TODO: Class comment with intended use (@usage section).
	 * Most common use cases first, briefly mention edge cases and refer to specific explanation in specific classes.
	 * 
	 * @author Thomas Brekelmans
	 */
	final public class Loader extends EventDispatcher 
	{
		
		
		private var priority:uint;
		private var isPaused:Boolean;
		
		private var tasks:LinkedList;
		
		//TODO, this can be refactored. the reference is not necessary as the currently loading task is the first task in the queue
		private var currentLoadTask:LoadTask;
		
		private var contentSize:uint;
		private var bytesLoaded : uint;
		private var filesAdded : uint;
		private var filesLoaded : uint;

		/**
		 * @param priority Use any of the constants in Priorities here, the default it Priorities.NORMAL.
		 * @param contentSize The total size of all the content that will be added to the loader, in bytes.
		 */
		public function Loader(priority:uint = 3, contentSize:uint = 0)
		{
			this.priority = priority;
			this.contentSize = contentSize;
			initialize();
		}
		
		private function initialize():void
		{
		    tasks = new LinkedList();
		    bytesLoaded = 0;
			filesAdded = 0;
			filesLoaded = 0;
		}
		
		/**
		 * @param data Arbitrary data that will be returned in LoaderItemEvent. Usefull for mapping data (id's) to a loaded asset.
		 * @param dataType This is usually resolved automatically but can be forced here to cope with unknown extensions that aren't mapped. 
		 * (Usually it's better to map them but for incidental uses a custom override can be used as well.) 
		 * Make sure to use a constant from DataTypes here, otherwise the appropriate task cannot be found.
		 * 
		 * @see LoaderItemEvent
		 * @see LoaderManager
		 * @see DataTypes
		 */
		public function add(url:String, data:* = null, dataType:uint = 0):void 
		{
			if (StringUtils.trim(url) != url)
			{
				throw new Error("The given url contains spaces and is therefor invalid. url: " + url);
			}
			tasks.add(LoaderManager.getInstance().createLoadTask(url, data, dataType)); 
			++filesAdded;
		}
		
		public function contains(url:String):Boolean
        {
			return tasks.selectBy( new LoadTaskByURLSpecification(url) ).isEmpty() == false;
		}
		
		/**
		 * Marks all the tasks in this loader as elligable for loading.
		 * This might start the next waiting task if this loader has the highest priority 
		 * in relation to the other loaders in existence. 
		 * Starting the next task might happen immediatly if there aren't any other loaders active. If there are
		 * other loaders this loaders next task is executed when all other loaders with higher priority are finished.
		 * So, don't depend on the timing of this call to be instantaneous and don't make any assumptions about
		 * it in your code other than that this loader is now again elligable for loading its next task.
		 * 
		 * If however you want to be sure this loaders tasks are executed as soon as the currently loading task 
		 * is completed, reprioritize this loader via setPriority().
		 * 
		 * @see #setPriority()
		 * @see LoaderPriorities
		 */
		public function execute():void 
		{
			isPaused = false;
			if(this.size() == 0){
				dispatchEvent(new LoaderEvent(LoaderEvent.DONE));
			}else{
				LoaderManager.getInstance().registerLoader(this);
			}
		}
		
		/**
		 * Pauses the loader.
		 * Doesn't pause the task that is actually loading but does mark this loader as being paused. 
		 * This ensures that no further tasks are executed that were waiting inside this loader.
		 */
		public function pause():void 
		{
			isPaused = true;
			
			notifyQueueOnChangeIsActive();
		}
		
		/**
		 * Resumes the loader.
		 * This might start the next waiting task if this loader has the highest priority 
		 * in relation to the other loaders in existence. 
		 * Starting the next task might happen immediatly if there aren't any other loaders active. If there are
		 * other loaders this loaders next task is executed when all other loaders with higher priority are finished.
		 * So, don't depend on the timing of this call to be instantaneous and don't make any assumptions about
		 * it in your code other than that this loader is now again elligable for loading its next task.
		 * 
		 * If however you want to be sure this loaders tasks are executed as soon as the currently loading task 
		 * is completed, reprioritize this loader via setPriority().
		 * 
		 * @see #setPriority()
		 * @see Priorities
		 */
		public function resume():void 
		{
			isPaused = false;
			
			notifyQueueOnChangeIsActive();
		}
		
		/**
		 * Called by the Queue when this Loader is next in line to actually load something.
		 */
		internal function loadNextTask():void
		{
			currentLoadTask = tasks.peek();
			currentLoadTask.addEventListener(TaskEvent.DONE, loadTaskDoneHandler);
			currentLoadTask.addEventListener(LoaderItemProgressEvent.PROGRESS, loadTaskProgressHandler);
			currentLoadTask.addEventListener(TaskEvent.ERROR, loadTaskErrorHandler);
			currentLoadTask.execute();
		}
		
		private function loadTaskProgressHandler(event:LoaderItemProgressEvent):void
		{
			dispatchEvent(event);
			
			//TODO: should we do this in a better way. what if a custom subclass does not use the progress stuff...???
			//if so/maybe the updating should also be handled in loadTaskDoneHandler.
			//on the other hand, we will lose the bytesadded on LoaderItemProgressEvent so that is a drawback...
			bytesLoaded += event.getBytesAdded();
			
			dispatchEvent(new LoaderProgressEvent(LoaderProgressEvent.PROGRESS, bytesLoaded / contentSize));
		}

		private function loadTaskDoneHandler(event:TaskEvent):void {
			//a file has loaded
			++filesLoaded;
			// do not expose LoadTask so pass each parameter along separately
			dispatchEvent(new LoaderItemEvent(LoaderItemEvent.DONE, currentLoadTask.getLoadedContent(), currentLoadTask.getUrl(), currentLoadTask.getData(), currentLoadTask.getLoaderType()));
			
			// this removes the finished task from the loader and dispatches the LoaderEvent.DONE event (via updateIsDoneLoading() if this loader is empty after removing the task)
			prepareNextLoadTask();
		}
		
		private function loadTaskErrorHandler(event:TaskEvent):void
		{
			//a file has not loaded, but we specify it as being done
			++filesLoaded;
			// do not expose LoadTask so pass each parameter along separately
			dispatchEvent(new LoaderItemEvent(LoaderItemEvent.ERROR, null, currentLoadTask.getUrl(), currentLoadTask.getData(), currentLoadTask.getLoaderType(), event.getMessage()));
			
			// this removes the finished task from the loader and dispatches the LoaderEvent.DONE event (via updateIsDoneLoading() if this loader is empty after removing the task)
			prepareNextLoadTask();
		}
		
		private function prepareNextLoadTask():void
		{
			// this removes the current load task from the tasks list as well
			destroyCurrentLoadTask();
			
			updateIsDoneLoading();
			
			// signal the manager that this loaders currentTask is done
			LoaderManager.getInstance().notifyTaskDone(this);
		}
		
		private function updateIsDoneLoading():void
		{
			if (size() == 0)
			{
				dispatchEvent(new LoaderEvent(LoaderEvent.DONE));
			}
		}
		
		/**
		 * Returns whether or not the loader is active, meaning it's not paused and still has items that need to be loaded.
		 */
		public function getIsActive():Boolean
		{
			return (isPaused == false && size() > 0);
		}
		
		/**
		 * Maybe all the loaders known to the LoaderManager were inactive so now the 
		 * LoaderManager might have to invoke loadNextTask on the appropriate loader to contine. 
		 */
		private function notifyQueueOnChangeIsActive():void
		{
			getIsActive() ? LoaderManager.getInstance().notifyIsActive(this) : LoaderManager.getInstance().notifyIsInActive(this);
		}
		
		public function getPriority():uint
		{
			return priority;
		}

		public function setPriority(priority:uint):void
		{
			if (priority != this.priority)
			{
				this.priority = Math.max(Priorities.LOWEST, Math.min(Priorities.HIGHEST, priority));
			
				LoaderManager.getInstance().rePrioritize(this);
			}
		}

		public function getIsPaused():Boolean
		{
			return isPaused;
		}
		
		/**
		 * Returns the number of items currently remaining in this loaders queue, 
		 * including the item that might currently be loading.
		 */
		public function size():uint
		{
			return tasks.size();
		}
		
		public function destroy():void
		{
			destroyCurrentLoadTask();
			destroyTasks();
			
			// signal the manager that this loaders currentTask is "done"
			// since the queue is cleared, the size == 0, so the loader will be
			// removed from the manager in loadTaskDoneHandler().
			LoaderManager.getInstance().notifyTaskDone(this);
		}
		
		private function destroyTasks():void
		{
			var loadTask:LoadTask;
			var iterator:IIterator = tasks.iterator();
			while (iterator.hasNext())
			{
				loadTask = iterator.next();
				loadTask.destroy();
			}
			
			tasks.clear();
		}
		
		/**
		 * Destroys the currently loading task, removes the event listeners and removes the task from the tasks list.
		 */
		private function destroyCurrentLoadTask():void
		{
			if (currentLoadTask)
			{	
				tasks.remove(currentLoadTask);
				
				currentLoadTask.removeEventListener(TaskEvent.DONE, loadTaskDoneHandler);
				currentLoadTask.removeEventListener(LoaderItemProgressEvent.PROGRESS, loadTaskProgressHandler);
				currentLoadTask.removeEventListener(TaskEvent.ERROR, loadTaskErrorHandler);
				currentLoadTask.destroy();
				currentLoadTask = null;
			}
		}
		
		/**
		 * Returns the total size of all the content that is added to the loader, in bytes.
		 */
		public function getContentSize():uint
		{
			return contentSize;
		}
		/**
		 * Updates the total size of all the content that is added to the loader to the given value in bytes.
		 */
		public function setContentSize(contentSize:uint):void
		{
			this.contentSize = contentSize;
		}
		
		/**
		 * gets the progress of all loading tasks in a fractional number between zero (nothing loaded) and one (all loaded).
		 * This only works when the contenSize is specified via the constructor or setContentSize.
		 * This method provides an alternative to listening to LoaderProgressEvent events.
		 * 
		 * for an alternative way of measuring progress when you do not have the contentSize, use getProgressOfFiles()
		 */
		public function getProgress():Number {
			return bytesLoaded / contentSize;
		}

		/**
		 * gets the progress of all loading tasks, relative to the number of total files added to the Loader, in a fractional number between zero (nothing loaded) and one (all loaded).
		 * This only works when there is at least one file added to this loader
		 * This method is different from getProgress() because it does not work with bytes, but with files
		 */
		public function getProgressOfFiles():Number{
			return filesLoaded / filesAdded;
		}

		/**
		 * the number of files that has either loaded succesfully or has failed to load.
		 * Used to get an indication of progress of the sequence of loading.
		 */
		public function getTotalFilesLoaded():uint {
			return filesLoaded;
		}
		
		/**
		 * the total number of files that were added to the Loader during it's lifetime
		 */
		public function getTotalFilesAdded():uint{
			return filesAdded;
		}
		

		override public function toString():String
		{
			return "Loader";
		}
		
	}
}