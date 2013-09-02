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
package nl.dpdk.services.gephyr {
	import flash.events.Event;

	/**
	 * Event class for most basic drupal service calls.
	 * It is advisable to listen to at least the ERROR event 
	 * and only register for (error)events you are interested in receiving for those calls that are actually made on the DrupalService.
	 * 
	 * For service calls that are custom made, just subclass this class and the DrupalService to add your own.
	 * @see nl.dpdk.services.gephyr.DrupalService
	 * @author Rolf Vreijdenberger
	 * @author Stephan de Bruin
	 */
	public class DrupalEvent extends Event {
		/**
		 * low level service error, for connection specific stuff: I/O ASYNC and SECURITY errors
		 */
		public static const ERROR : String = "generic drupal service error";
		
		
		public static const SYSTEM_CONNECT : String = "system.connect called succesfully";
		public static const SYSTEM_MAIL : String = "system.mail called succesfully";
		public static const ERROR_SYSTEM_CONNECT : String = "system.connect failed";
		public static const ERROR_SYSTEM_MAIL : String = "system.mail failed";
		
		public static const NODE_GET : String = "node.get called successfully";
		public static const NODE_SAVE : String = "node.save called successfully";
		public static const NODE_DELETE : String = "node.delete called successfully";
		public static const ERROR_NODE_GET : String = "node.get failed";
		public static const ERROR_NODE_SAVE : String = "node.save failed";
		public static const ERROR_NODE_DELETE : String = "node.delete failed";
	
		public static const USER_GET : String = "user.get called successfully";
		public static const USER_SAVE : String = "user.save called successfully";
		public static const USER_LOGIN : String = "user.login called successfully";
		public static const USER_LOGOUT : String = "user.logout called successfully";
		public static const USER_DELETE : String = "user.delete called successfully";
		public static const ERROR_USER_GET : String = "user.get failed";
		public static const ERROR_USER_SAVE : String = "user.save failed";
		public static const ERROR_USER_LOGIN : String = "user.login failed";
		public static const ERROR_USER_LOGOUT : String = "user.logout failed";
		public static const ERROR_USER_DELETE : String = "user.delete failed";
		
		public static const TAXONOMY_GETTREE : String = "taxonomy.getTree called successfully";
		public static const TAXONOMY_SELECTNODES : String = "taxonomy.selectNodes called successfully"; 
		public static const ERROR_TAXONOMY_GETTREE : String = "taxonomy.getTree failed";
		public static const ERROR_TAXONOMY_SELECTNODES : String = "taxonomy.selectNodes failed"; 
		
		public static const SEARCH_USERS : String = "search.users called successfully"; 
		public static const SEARCH_NODES : String = "search.nodes called successfully"; 
		public static const ERROR_SEARCH_USERS : String = "search.users failed"; 
		public static const ERROR_SEARCH_NODES : String = "search.nodes failed"; 

		public static const MENU_GET : String = "menu.get called successfully"; 
		public static const ERROR_MENU_GET : String = "menu.get failed"; 
		
		public static const VIEWS_GET : String = "views.get called sucessfully";
		public static const ERROR_VIEWS_GET : String = "views.get failed";

		private var error : String;
		private var data : *;


		public function DrupalEvent(type : String, data: * = null , error : String = null) {
			super(type);
			this.data = data;
			this.error = error;
		
		
		}
		
		/**
		 * the data associated with the event.
		 * The data structure returned will depend on the type of call made on the DrupalService.
		 */
		public function getData() : * {
			return data;
		}
		
		/**
		 * the message associated with the event when it has a type of ERROR_<..>
		 */
		public function getError() : String {
			return error;
		}
		
		public override function toString():String{
			return "DrupalEvent of type: " + type;
		}
	}
}