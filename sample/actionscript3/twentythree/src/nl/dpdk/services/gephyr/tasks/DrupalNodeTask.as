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
	 * The DrupalNodeTask is a Task that gets a node from the drupal backend.
	 * When this Task is used in a Sequence, it gets a node from drupal.
	 * Often, the use of this task will be after the DrupalConnectTask has been executed in a sequence.
	 * 
	 * In the example below we will give two different methods to handle the incoming node data from drupal.
	 * 
	 * 
	 * usage:
	 * <code>
	 //the sequence that will load our data from drupal
	 private var sequence: Sequence;
	 //a list that holds nodes
	 private var nodes: List = new LinkedList();
	 //another list that holds nodes
	 private var theSameNodes: List = new LinkedList();
	  
	  
	 public function main():void{
		 //a drupalService that needs a session for security.
		 var service: DrupalService = new DrupalService("http://www.example.com/amfphp/gateway.php", true);
		 sequence = new Sequence();
		 //because we need a session, we first must connect. create a task to connect before getting any node data
		 sequence.add(new DrupalConnectTask(service));
		 //now get some node data! in this case nodes with id 1 to 100 and use the myNodeHandler method to handle the incoming node data.
		 for(var i:int = 1;i <= 100; ++i){
			 sequence.add(new DrupalNodeTask(service, i, myNodeHandler));
		 }
		 //add callback task to sequence of tasks to process all the nodes
		 sequence.add(new CallBackTask(allNodesLoaded);
		 sequence.addEventListener(SequenceEvent.DONE, onSequenceDone);
		 sequence.addEventListener(SequenceEvent.ERROR, onSequenceError);
		 sequence.addEventListener(SequenceEvent.NEXT, onSequenceNext);
		 //start the sequence.
		 sequence.execute();
	 }
	  
	  
	  
	 public function onSequenceNext(event: SequenceEvent):void{
	  	 var task: Task = sequence.getCurrent();
	     if(task is DrupalNodeTask){
	      	//a DrupalNodeTask has an extra method called getData() that returns the node data. fill the List with the nodes	      	
	     	 nodes.add(task.getData());
	      } 
	  }
	  
	  
	 public function myNodeHandler(node: Object):void{
		 theSameNodes.add(node);
	  }
	      
	      
	  public function allNodesLoaded():void{    
	   	//we now have a choice to either manipulate the 'nodes' or 'theSameNodes' Lists.
	   	//we showed two options just to give an example of different methods of handling nodes.
	 }
	      
	      
	      
	 * </code>
	 * 
	 * @see nl.dpdk.commands.tasks.Task
	 * @see nl.dpdk.commands.tasks.sequence
	 * @see nl.dpdk.services.gephyr.DrupalService
	 * @see nl.dpdk.service.gephyr.tasks.DrupalConnectTask
	 * 
	 * @author rolf vreijdenberger
	 * @author Mathijs Meijer
	 */
	public class DrupalNodeTask extends Task 
	{
		private var ds:DrupalService;
		private var nodeId:int;
		private var data:*;
		private var fields : Array;
		private var callback : Function;

		
		/**
		 * Constructor
		 * @param ds a DrupalService object
		 * @param nodeId the nodeId of the node we want from the Drupal backend
		 * @param callback a method that will be called (when the task finishes succesfully) with the node data as it's only argument
		 * This argument is not compulsory as the node data can also be retrieved from the SequenceEvent.NEXT
		 * @param fields an array specifying the fields we wish to retrieve from a node.
		 */
		public function DrupalNodeTask(ds:DrupalService, nodeId:int, callback: Function = null, fields:Array = null) {
			this.callback = callback;
			this.fields = fields;
			this.nodeId = nodeId;
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
			//this saves runtime memory when we would create a lot of tasks.
			//also, adding listeners in the constructor gives bugs, as all tasks will listen to the same dataservice at the same time.
			//this will generate a race condition in Sequence where all tasks will be executed serially with all of them immediately firing their 'done()' method.
			//therefore, we add them here, and remove them in the destroy().
			ds.addEventListener(DrupalEvent.ERROR_NODE_GET, onError);
			ds.addEventListener(DrupalEvent.NODE_GET, onResult);
			ds.addEventListener(DrupalEvent.ERROR, onError);
			ds.nodeGet(nodeId, fields);
		}

		override protected function destroyTaskHook():void
		{
			ds.removeEventListener(DrupalEvent.ERROR_NODE_GET, onError);
			ds.removeEventListener(DrupalEvent.NODE_GET, onResult);
			ds.removeEventListener(DrupalEvent.ERROR, onError);
			this.ds = null;
			this.data = null;
		}

		public function getNodeId():int
		{
			return nodeId;
		}

		public function getData():*
		{
			return data;
		}

		override public function toString():String
		{
			return "DrupalNodeTask: " + nodeId;
		}
	}
}
