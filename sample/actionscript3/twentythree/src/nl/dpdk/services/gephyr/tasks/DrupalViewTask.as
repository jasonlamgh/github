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
package nl.dpdk.services.gephyr.tasks {
	import nl.dpdk.commands.tasks.Task;
	import nl.dpdk.services.gephyr.DrupalEvent;
	import nl.dpdk.services.gephyr.DrupalService;

	/**
	 * The DrupalViewTask is a Task that gets all view data for a specific view from the drupal backend.
	 * When this Task is used in a Sequence, it gets viewdata from drupal.
	 * Often, the use of this task will be after the DrupalConnectTask has been executed in a sequence.
	 * 
	
	 * 
	 * @see nl.dpdk.commands.tasks.Task
	 * @see nl.dpdk.commands.tasks.sequence
	 * @see nl.dpdk.services.gephyr.DrupalService
	 * @see nl.dpdk.service.gephyr.tasks.DrupalConnectTask
	 * 
	 * @author rolf vreijdenberger
	 */
	public class DrupalViewTask extends Task 
	{
		private var ds:DrupalService;
		private var data:*;
		private var fields : Array;
		private var callback : Function;
		private var view : String;
		private var args : Array;
		private var offset : int;
		private var limit : int;

		
		
		/**
		 * Constructor
		 * @param ds a DrupalService object
		 * @param view the name of the view
		 * @param callback the callback method that will handle the data that comes back from the drupalservice.
		 */
		public function DrupalViewTask(ds:DrupalService, view:String, callback: Function = null, fields : Array = null, args : Array = null, offset : int = 0, limit : int = 999) {
			this.limit = limit;
			this.offset = offset;
			this.args = args;
			this.fields = fields;
			this.view = view;
			this.callback = callback;
			this.ds = ds;
		}

		private function onResult(event:DrupalEvent):void
		{
			this.data = event.getData();
			if(this.callback != null){
				this.callback(this.data);
			}
			done();
		}

		private function onError(event:DrupalEvent):void
		{
			fail(event.getError());
		}

		override protected function executeTaskHook():void
		{
			//we add the listeners here, instead of in the constructor.
			ds.addEventListener(DrupalEvent.ERROR_VIEWS_GET, onError);
			ds.addEventListener(DrupalEvent.VIEWS_GET, onResult);
			ds.addEventListener(DrupalEvent.ERROR, onError);
			ds.viewsGet(view, fields, args, offset, limit);
		}

		override protected function destroyTaskHook():void
		{
			ds.removeEventListener(DrupalEvent.ERROR_VIEWS_GET, onError);
			ds.removeEventListener(DrupalEvent.VIEWS_GET, onResult);
			ds.removeEventListener(DrupalEvent.ERROR, onError);
			this.ds = null;
			this.data = null;
			this.fields = null;
			this.args = null;
			this.callback = null;
		}

		/**
		 * gets the name of the view associated with this task
		 */
		public function getView():String{
			return view;
		}

		public function getData():*
		{
			return data;
		}

		override public function toString():String
		{
			return "DrupalViewTask: " + view;
		}
	}
}
