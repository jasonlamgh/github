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
	import flash.events.EventDispatcher;
	import flash.net.ObjectEncoding;

	import nl.dpdk.services.remoting.RemotingEvent;
	import nl.dpdk.services.remoting.RemotingProxy;
	import nl.dpdk.services.remoting.ResultData;
	import nl.dpdk.services.remoting.StatusData;
	import nl.dpdk.utils.StringUtils;

	/**
	 * DrupalService is an amf remoting wrapper for the basic drupal services.
	 * http://drupal.org/node/109782
	 * 
	 * Make sure your services modules are configured correctly with the right permissions, keys etc.
	 * permissions allowing anonymous or logged in users to connect to services, based on their roles etc.
	 *  
	 * Authentication keys are a security risk in flash, as flash can be decompiled and hardcoding an authentication key will mean anyone can view the key.
	 * authentication info: http://drupal.org/node/394224
	 * For flash, security can also be had by creating multiple users with different roles in drupal, thereby giving them different security clearances.
	 * authentication keys are used so 1 specific call cannot be duplicated, even if it is intercepted by a man in the middle attack.
	 * But since the key can be read from flash by decompiling it, a hacker can then write a client that could potentially do malicious stuff to the site.
	 * This is where the domain name is important, as it specifies a domain for which the key is valid.
	 * DrupalService has a dependency on the com.hurlant.crypto package, which is licensed under BSD.
	 * 
	 * If there is any service not listed here, it's very easy to add them to this class.
	 * It's possible to subclass DrupalService and provide your own service calls.
	 * In that case, extend DrupalEvent for your own custom Events and override the error() method found in this class with your custom DrupalEvent.
	 * In this way, you can keep the core functionality and add your own, by using your subclass of DrupalService and DrupalEvent. 
	 * If there are security related issues, be sure to check out the code of a method call that handles it all, like users.save or the like.
	 * Isn't subclassing great :)
	 * 
	 * 

	 * 
	 * For the specifics to send to the drupal services, see documentation on drupal.org
	 * For the specifics on what to receive from drupal services, see documentatation on drupal.org and use an http sniffer.
	 * It is very easy to get data from drupal to flash, especially so with the cck module, check it out.
	 * 
	 * <sarcasm>Special thanks to the guy that created the method signatures for the services.</sarcasm>
	 * Maybe encapsulate the whole key and session stuff in 1 parameter, as an object?
	 * Maybe pick it up in drupal 7?
	 * 
	 * More information can be found on 
	 * - www.drupal.org/services
	 * - the book 'Flash with Drupal' by Travis Tidwell
	 * 
	 * 
	 * @see nl.dpdk.services.gephyr.DrupalEvent
	 * @see nl.dpdk.services.gephyr.DrupalUser
	 * @author Rolf Vreijdenberger
	 * @author Stephan de Bruin
	 */
	public class DrupalService extends EventDispatcher {
		//the gateway to the drupal services
		protected var gateway : String;
		//the currently logged in user, or null	
		protected var user : Object;

		
		
		protected var systemService : RemotingProxy;
		protected var userService : RemotingProxy;
		protected var taxonomyService : RemotingProxy;
		protected var nodeService : RemotingProxy;
		protected var searchService : RemotingProxy;
		protected var viewsService : RemotingProxy;
		protected var menuService : RemotingProxy;

		//class that holds data about the security policy, can be used by subclasses to get all parameters for the security policy used.
		protected var security : DrupalSecurity;

		/**
		 * DrupalService constructor.
		 * @param gateway the amfphp gateway to connect to.
		 * @param requireSession set to true if drupal is configured to use session data. be sure to call drupalservice.systemConnect() before attempting any other calls
		 * @param key a key that is used for all calls that need a security/authentication key. 
		 * @param domain the domain the key is valid for
		 * Remember that using an api key in flash is a security risk as flash can be decompiled.
		 * 
		 */
		public function DrupalService(gateway : String, requireSession : Boolean = false, key : String = '', domain : String = '') {

			this.gateway = gateway;
			//handles the security issues for drupal
			this.security = new DrupalSecurity(requireSession, key, domain);
			
			/**
			 * we make different remotingproxies for different services, 
			 * since there are different services which have the same methods (eg: node.get and user.get).
			 * In this way we avoid naming collisions but we have more overhead.
			 * An alternative would be to switch services on the remotinproxy itself when making a service call.
			 * We would still need two proxies then for the handlers for node.get/node.save and user.get/user.save
			 * 
			 * we really don't need amf 3 here, but for custom services provided in a possible subclass, it can be great.
			 * for example, with amf3 you can send bytearrays to save pictures on the filesystem made in flash (http://drupal.org/node/269851, http://blip.tv/file/1399795)
			 */
			systemService = new RemotingProxy(gateway, "system", ObjectEncoding.AMF3);
			userService = new RemotingProxy(gateway, "user", ObjectEncoding.AMF3);
			taxonomyService = new RemotingProxy(gateway, "taxonomy", ObjectEncoding.AMF3);
			nodeService = new RemotingProxy(gateway, "node", ObjectEncoding.AMF3);
			searchService = new RemotingProxy(gateway, "search", ObjectEncoding.AMF3);
			viewsService = new RemotingProxy(gateway, "views", ObjectEncoding.AMF3);
			menuService = new RemotingProxy(gateway, "menu", ObjectEncoding.AMF3);

			/**
			 * all event listeners on the different drupal services are added here
			 */
			systemService.addEventListener(RemotingEvent.ERROR_IO, onConnectError);
			systemService.addEventListener(RemotingEvent.ERROR_ASYNC, onConnectError);
			systemService.addEventListener(RemotingEvent.ERROR_SECURITY, onConnectError);
			userService.addEventListener(RemotingEvent.ERROR_IO, onConnectError);
			userService.addEventListener(RemotingEvent.ERROR_ASYNC, onConnectError);
			userService.addEventListener(RemotingEvent.ERROR_SECURITY, onConnectError);
			taxonomyService.addEventListener(RemotingEvent.ERROR_IO, onConnectError);
			taxonomyService.addEventListener(RemotingEvent.ERROR_ASYNC, onConnectError);
			taxonomyService.addEventListener(RemotingEvent.ERROR_SECURITY, onConnectError);
			nodeService.addEventListener(RemotingEvent.ERROR_IO, onConnectError);
			nodeService.addEventListener(RemotingEvent.ERROR_ASYNC, onConnectError);
			nodeService.addEventListener(RemotingEvent.ERROR_SECURITY, onConnectError);
			searchService.addEventListener(RemotingEvent.ERROR_IO, onConnectError);
			searchService.addEventListener(RemotingEvent.ERROR_ASYNC, onConnectError);
			searchService.addEventListener(RemotingEvent.ERROR_SECURITY, onConnectError);
			viewsService.addEventListener(RemotingEvent.ERROR_IO, onConnectError);
			viewsService.addEventListener(RemotingEvent.ERROR_ASYNC, onConnectError);
			viewsService.addEventListener(RemotingEvent.ERROR_SECURITY, onConnectError);
			menuService.addEventListener(RemotingEvent.ERROR_IO, onConnectError);
			menuService.addEventListener(RemotingEvent.ERROR_ASYNC, onConnectError);
			menuService.addEventListener(RemotingEvent.ERROR_SECURITY, onConnectError);
			
			/**
			 * all default drupal service handlers are added here
			 */
			systemService.addHandler('connect', onSystemConnectResult, onSystemConnectStatus);
			systemService.addHandler('mail', onSystemMailResult, onSystemMailStatus);
			nodeService.addHandler('get', onNodeGetResult, onNodeGetStatus);
			nodeService.addHandler('save', onNodeSaveResult, onNodeSaveStatus);
			nodeService.addHandler('delete', onNodeDeleteResult, onNodeDeleteStatus);
			userService.addHandler('get', onUserGetResult, onUserGetStatus);
			userService.addHandler('save', onUserSaveResult, onUserSaveStatus);
			userService.addHandler('login', onUserLoginResult, onUserLoginStatus);
			userService.addHandler('logout', onUserLogoutResult, onUserLogoutStatus);
			userService.addHandler('delete', onUserDeleteResult, onUserDeleteStatus);
			taxonomyService.addHandler('getTree', onTaxonomyGetTreeResult, onTaxonomyGetTreeStatus);
			taxonomyService.addHandler('selectNodes', onTaxonomySelectNodesResult, onTaxonomySelectNodesStatus);
			searchService.addHandler('nodes', onSearchNodesResult, onSearchNodesStatus);
			searchService.addHandler('users', onSearchUsersResult, onSearchUsersStatus);
			viewsService.addHandler('get', onViewsGetResult, onViewsGetStatus);
			menuService.addHandler('get', onMenuGetResult, onMenuGetStatus);
		}

		private function onMenuGetStatus(status : StatusData) : void {
			error(DrupalEvent.ERROR_MENU_GET, status.getDescription());
		}

		
		
		private function onViewsGetStatus(status : StatusData) : void {
			error(DrupalEvent.ERROR_VIEWS_GET, status.getDescription());
		}

		private function onViewsGetResult(result : ResultData) : void {
			dispatchEvent(new DrupalEvent(DrupalEvent.VIEWS_GET, result.getResult()));
		}

		private function onSearchUsersStatus(status : StatusData) : void {
			error(DrupalEvent.ERROR_SEARCH_USERS, status.getDescription());
		}

		private function onSearchNodesStatus(status : StatusData) : void {
			error(DrupalEvent.ERROR_SEARCH_USERS, status.getDescription());
		}

		private function onTaxonomySelectNodesStatus(status : StatusData) : void {
			error(DrupalEvent.ERROR_TAXONOMY_SELECTNODES, status.getDescription());
		}

		private function onTaxonomyGetTreeStatus(status : StatusData) : void {
			error(DrupalEvent.ERROR_TAXONOMY_GETTREE, status.getDescription());
		}

		private function onUserDeleteStatus(status : StatusData) : void {
			error(DrupalEvent.ERROR_USER_DELETE, status.getDescription());
		}

		private function onUserLogoutStatus(status : StatusData) : void {
			error(DrupalEvent.ERROR_USER_LOGOUT, status.getDescription());
		}

		private function onUserLoginStatus(status : StatusData) : void {
			error(DrupalEvent.ERROR_USER_LOGIN, status.getDescription());
		}

		private function onUserSaveStatus(status : StatusData) : void {
			error(DrupalEvent.ERROR_USER_SAVE, status.getDescription());
		}

		private function onUserGetStatus(status : StatusData) : void {
			error(DrupalEvent.ERROR_USER_GET, status.getDescription());
		}

		private function onNodeDeleteStatus(status : StatusData) : void {
			error(DrupalEvent.ERROR_NODE_DELETE, status.getDescription());
		}

		private function onNodeSaveStatus(status : StatusData) : void {
			error(DrupalEvent.ERROR_NODE_SAVE, status.getDescription());
		}

		private function onNodeGetStatus(status : StatusData) : void {
			error(DrupalEvent.ERROR_NODE_GET, status.getDescription());
		}

		private function onSystemMailStatus(status : StatusData) : void {
			error(DrupalEvent.ERROR_SYSTEM_MAIL, status.getDescription());
		}

		private function onSystemConnectStatus(status : StatusData) : void {
			error(DrupalEvent.ERROR_SYSTEM_CONNECT, status.getDescription());
		}

		
		private function onSearchUsersResult(data : ResultData) : void {
			dispatchEvent(new DrupalEvent(DrupalEvent.SEARCH_USERS, data.getResult()));
		}

		private function onSearchNodesResult(data : ResultData) : void {
			dispatchEvent(new DrupalEvent(DrupalEvent.SEARCH_NODES, data.getResult()));
		}

		
		
		
		/**
		 * Dispatch an event in case of an Error.
		 * Override this method to dispatch more specific events for custom implementations.
		 * The events dispatchted should be of a subclass of DrupalEvent in that case.
		 */
		protected function error(type : String, error : String) : void {
			dispatchEvent(new DrupalEvent(type, null, error));
		}

		
		
		
		
		/**
		 * This function is called after system.connect has returned a result. 
		 * Sets the getSessionId() to be used with all other calls.
		 */
		private function onSystemConnectResult(data : ResultData) : void {
			//this call always returns sessid, and a user object with anonymous user data (o.sessid, o.user)
			security.setSessionId(data.getResult().sessid);
			dispatchEvent(new DrupalEvent(DrupalEvent.SYSTEM_CONNECT, data.getResult()));
		}

		/**
		 * This function is called after menu.get has returned a result. 
		 */
		private function onMenuGetResult(data : ResultData) : void {
			dispatchEvent(new DrupalEvent(DrupalEvent.MENU_GET, data.getResult()));
		}

		
		/**
		 * This function is called after system.mail has returned a result. 
		 */
		private function onSystemMailResult(data : ResultData) : void {
			dispatchEvent(new DrupalEvent(DrupalEvent.SYSTEM_MAIL, data.getResult()));
		}

		
		/**
		 * when system.connect fails.
		 * this method might be called from a subclass with a specific service implementation
		 */
		protected final function onConnectError(event : RemotingEvent) : void {
			error(DrupalEvent.ERROR, event.getMessage());
		}

		
		/**
		 * This function is called after node.get has returned a result.
		 */
		private function onNodeGetResult(data : ResultData) : void {
			dispatchEvent(new DrupalEvent(DrupalEvent.NODE_GET, data.getResult()));
		}

		
		/**
		 * This function is called after node.save has returned a result.
		 */
		private function onNodeSaveResult(data : ResultData) : void {
			dispatchEvent(new DrupalEvent(DrupalEvent.NODE_SAVE, data.getResult()));
		}

		/**
		 * This function is called after node.delete has returned a result.
		 */
		private function onNodeDeleteResult(data : ResultData) : void {
			dispatchEvent(new DrupalEvent(DrupalEvent.NODE_DELETE, data.getResult()));
		}

		
		/**
		 * This function is called after user.get has returned a result.
		 */
		private function onUserGetResult(data : ResultData) : void {
			dispatchEvent(new DrupalEvent(DrupalEvent.USER_GET, data.getResult()));
		}

		
		/**
		 * This function is called after user.save has returned a result.
		 */				
		private function onUserSaveResult(data : ResultData) : void {
			dispatchEvent(new DrupalEvent(DrupalEvent.USER_SAVE, data.getResult()));
		}

		/**
		 * This function is called after user.login has returned a result.
		 */	
		private function onUserLoginResult(data : ResultData) : void {
			//the logged in user object is stored in the DrupalService.
			//on logout, it is removed again
			//bugfix 2009-11-15: robin van emden, change the session
			user = data.getResult();
			//change the sessionId, it is changed for a logged in user
			setSessionId(user.sessid);
			dispatchEvent(new DrupalEvent(DrupalEvent.USER_LOGIN, user));
		}

		
		/**
		 * This function is called after user.logout has returned a result.
		 */	
		private function onUserLogoutResult(data : ResultData) : void {
			if(StringUtils.toBoolean(data.getResult())) {
				//logout succeeded, remove the currently logged in user
				user = null;
			}
			dispatchEvent(new DrupalEvent(DrupalEvent.USER_LOGOUT, data.getResult()));
		}

		
		/**
		 * This function is called after user.delete has returned a result.
		 */	
		private function onUserDeleteResult(data : ResultData) : void {
			dispatchEvent(new DrupalEvent(DrupalEvent.USER_DELETE, data.getResult()));
		}

		
		/**
		 * This function is called after taxonomy.getTree has returned a result.
		 */		
		private function onTaxonomyGetTreeResult(data : ResultData) : void {
			dispatchEvent(new DrupalEvent(DrupalEvent.TAXONOMY_GETTREE, data.getResult()));
		}

		
		/**
		 * This function is called after taxonomy.selectNodes has returned a result.
		 */	
		private function onTaxonomySelectNodesResult(data : ResultData) : void {
			dispatchEvent(new DrupalEvent(DrupalEvent.TAXONOMY_SELECTNODES, data.getResult()));
		}

		
		/**
		 * Get a specific node.
		 * 
		 * @param nid the ID of the drupal node.
		 * @param fields Fields to be given back.
		 */
		public function nodeGet(nid : uint, fields : Array = null) : void {
			//does not use authentication keys
			if(security.useSession()) {
				nodeService.get(getSessionId(), nid, fields);
			} else {
				nodeService.get(nid, fields);
			}
		}

		
		/**
		 * Saves or updates a new node.
		 * @param node Object containing node data.
		 * Upon creation, node object must include "title", "type" and "created". 
		 * Upon update, node object must include "nid" and "changed".
		 * node.save (create): Needs 'type' and 'title' in your object.
		 * node.save (update): Needs 'nid' and 'changed' set to 'true' or a timestamp. : plus your changes of course ;)
		 * 
		 * @see http://drupal.org/node/219365#comment-1264254
		 */
		public function nodeSave(node : Object) : void {
			security.prepare();
			if(security.sessionAndKey()) {
				nodeService.save(security.getHash("node.save"), security.getDomain(), security.getTimeStamp(), security.getNonce(), getSessionId(), node);
			}else if (security.keyOnly()) {
				nodeService.save(security.getHash("node.save"), security.getDomain(), security.getTimeStamp(), security.getNonce(), node);
			}else if(security.sessionOnly()) {
				nodeService.save(getSessionId(), node);
			} else if(security.noSessionNoKey()) {
				nodeService.save(node);
			}
		}

		
		
		/**
		 * delete node.
		 * @param nid the nid of the node to delete.
		 */
		public function nodeDelete(nid : uint) : void {
			security.prepare();
			if(security.sessionAndKey()) {
				nodeService.invoke("delete", security.getHash("node.delete"), security.getDomain(), security.getTimeStamp(), security.getNonce(), getSessionId(), nid);
			}else if (security.keyOnly()) {
				nodeService.invoke("delete", security.getHash("node.delete"), security.getDomain(), security.getTimeStamp(), security.getNonce(), nid);
			}else if(security.sessionOnly()) {
				nodeService.invoke("delete", getSessionId(), nid);
			} else if(security.noSessionNoKey()) {
				nodeService.invoke("delete", nid);
			}
		}

		/**
		 * get the menu.
		 * To use the default types, check DrupalUtils.MENU_* types.
		 * @param mid the menuId. Defaults to "primary-links => DrupalUtils.MENU_PRIMARY
		 * @param fields list of fields to return. If left empty, all fields will be returned 
		 */
		public function menuGet(mid : String = "primary-links", fields : Array = null) : void {
			fields = fields == null ? new Array() : fields;
			security.prepare();
			if(security.sessionAndKey()) {
				menuService.invoke("get", security.getHash("menu.get"), security.getDomain(), security.getTimeStamp(), security.getNonce(), getSessionId(), mid, fields);
			}else if (security.keyOnly()) {
				menuService.invoke("get", security.getHash("menu.get"), security.getDomain(), security.getTimeStamp(), security.getNonce(), mid, fields);
			}else if(security.sessionOnly()) {
				menuService.invoke("get", getSessionId(), mid, fields);
			} else if(security.noSessionNoKey()) {
				menuService.invoke("get", mid, fields);
			}
		}

		
		/**
		 * Get details for a specific user.
		 * 
		 * @param uid The userid for the user we want to retrieve.
		 * When the call succeeds a DrupalEvent.USER_GET is dispatched.
		 * the data in this event consists of a user object with the properties:
		 * uid,name ,pass,mail,mode,sort,threshold, theme ,signature,
		 * signature_format ,created,access,login,status,timezone,language,picture,init,data,roles
		 */
		public function userGet(uid : uint) : void {
			security.prepare();
			if(security.sessionAndKey()) {
				userService.get(security.getHash("user.get"), security.getDomain(), security.getTimeStamp(), security.getNonce(), getSessionId(), uid);
			}else if (security.keyOnly()) {
				userService.get(security.getHash("user.get"), security.getDomain(), security.getTimeStamp(), security.getNonce(), uid);
			}else if(security.sessionOnly()) {
				userService.get(getSessionId(), uid);
			} else if(security.noSessionNoKey()) {
				userService.get(uid);
			}
		}

		/**
		 * Save a new user or update an existing user.
		 * A new user object needs to have the name and mail field as a minimum.
		 * @param user A user object with the fields name,created,pass,mail,status,uid;
		 * user.save (create): Needs 'name' and 'mail' in your object.
		 * user.save (update): Needs 'uid' (user id). : Does not need a changed value like node.save
		 * 
		 * @see #userGet
		 * @see http://drupal.org/node/219365#comment-1264254
		 */
		public function userSave( user : Object) : void {
			security.prepare();
			if(security.sessionAndKey()) {
				userService.save(security.getHash("user.save"), security.getDomain(), security.getTimeStamp(), security.getNonce(), getSessionId(), user);
			}else if (security.keyOnly()) {
				userService.save(security.getHash("user.save"), security.getDomain(), security.getTimeStamp(), security.getNonce(), user);
			}else if(security.sessionOnly()) {
				userService.save(getSessionId(), user);
			} else if(security.noSessionNoKey()) {
				userService.save(user);
			}
		}

		/**
		 * deletes a specific user.
		 * 
		 * @param uid The user ID.
		 */
		public function userDelete(uid : uint) : void {
			security.prepare();
			if(security.sessionAndKey()) {
				userService.invoke("delete", security.getHash("user.delete"), security.getDomain(), security.getTimeStamp(), security.getNonce(), getSessionId(), uid);
			}else if (security.keyOnly()) {
				userService.invoke("delete", security.getHash("user.delete"), security.getDomain(), security.getTimeStamp(), security.getNonce(), uid);
			}else if(security.sessionOnly()) {
				userService.invoke("delete", getSessionId(), uid);
			} else if(security.noSessionNoKey()) {
				userService.invoke("delete", uid);
			}
		}

		
		/**
		 * Login as a user.
		 * As a logged in user, you will have the permissions of the user to manipulate data and access certain service alls.
		 * When a login succeeds, the currently logged in users' user object can be retrieved from the DrupalService by getUser()
		 * 
		 * @param username the username
		 * @param password the password
		 */
		public function userLogin(username : String, password : String) : void {
			security.prepare();
			if(security.sessionAndKey()) {
				userService.login(security.getHash("user.login"), security.getDomain(), security.getTimeStamp(), security.getNonce(), getSessionId(), username, password);
			}else if (security.keyOnly()) {
				userService.login(security.getHash("user.login"), security.getDomain(), security.getTimeStamp(), security.getNonce(), username, password);
			}else if(security.sessionOnly()) {
				userService.login(getSessionId(), username, password);
			} else if(security.noSessionNoKey()) {
				userService.login(username, password);
			}
		}

		
		/**
		 * Logout the currently logged in user.
		 */
		public function userLogout() : void {
			security.prepare();
			if(security.sessionAndKey()) {
				userService.logout(security.getHash("user.logout"), security.getDomain(), security.getTimeStamp(), security.getNonce(), getSessionId());
			}else if (security.keyOnly()) {
				userService.logout(security.getHash("user.logout"), security.getDomain(), security.getTimeStamp(), security.getNonce());
			}else if(security.sessionOnly()) {
				userService.logout(getSessionId());
			} else if(security.noSessionNoKey()) {
				userService.logout();
			}
		}

		
		/**
		 * Get the taxonomy tree for a specific vocabulary
		 * 
		 * @param vid The vocabulary ID 
		 */
		public function taxonomyGetTree(vid : uint) : void {
			security.prepare();
			if(security.sessionAndKey()) {
				taxonomyService.getTree(security.getHash("taxonomy.getTree"), security.getDomain(), security.getTimeStamp(), security.getNonce(), getSessionId(), vid);
			}else if (security.keyOnly()) {
				taxonomyService.getTree(security.getHash("taxonomy.getTree"), security.getDomain(), security.getTimeStamp(), security.getNonce(), vid);
			}else if(security.sessionOnly()) {
				taxonomyService.getTree(getSessionId(), vid);
			} else if(security.noSessionNoKey()) {
				taxonomyService.getTree(vid);
			}
		}

		
		/**
		 * Get the nodes for a specific term ID
		 * @param tids array containing the term id's (these apparently need to be strings.not sure though.)
		 * @param fields  A list of fields to return.
		 * @param operator How to interpret multiple IDs in the array. Can be "or" or "and".
		 * @param depth How many levels deep to traverse the taxonomy tree. Can be a nonnegative integer or "all".
		 */
		public function taxonomySelectNodes(tids : Array, fields : Array = null, operator : String = "", depth : String = "") : void {
			fields = fields == null ? new Array() : fields;
			security.prepare();
			if(security.sessionAndKey()) {
				taxonomyService.selectNodes(security.getHash("taxonomy.selectNodes"), security.getDomain(), security.getTimeStamp(), security.getNonce(), getSessionId(), tids, fields, operator, depth);
			}else if (security.keyOnly()) {
				taxonomyService.selectNodes(security.getHash("taxonomy.selectNodes"), security.getDomain(), security.getTimeStamp(), security.getNonce(), tids, fields, operator, depth);
			}else if(security.sessionOnly()) {
				taxonomyService.selectNodes(getSessionId(), tids, fields, operator, depth);
			} else if(security.noSessionNoKey()) {
				taxonomyService.selectNodes(tids, fields, operator, depth);
			}
		}

		
		
		
		
		public function viewsGet(name : String, fields : Array = null, args : Array = null, offset : int = 0, limit : int = 999) : void {
			//does not use authentication keys
			if(security.useSession()) {
				viewsService.get(getSessionId(), name, fields, args, offset, limit);
			} else {
				viewsService.get(name, fields, args, offset, limit);
			}
		}

		
		
		
		/**
		 * Connect to the system, this gets you a getSessionId() and stuff
		 * In order to authenticate to Services, you must first request an anonymous session id. You do this with the system.connect method.
		 */
		public function systemConnect() : void {
			//does not use authentication keys
			systemService.connect();
		}

		/**
		 * sends a mail from the drupal system
		 * @param mailKey  A key to identify the mail sent, for altering.
		 * @param to The mail address or addresses where the message will be send to.
		 * @param subject  Subject of the e-mail to be sent. This must not contain any newline characters, or the mail may not be sent properly.
		 * @param body Message to be sent. Drupal will format the correct line endings for you.
		 * @param from Sets From, Reply-To, Return-Path and Error-To to this value, if given.
		 * @param headers an Associative array (object in flash) containing the headers to add. This is typically used to add extra headers (From, Cc, and Bcc).
		 */
		public function systemMail(mailKey : String, to : String, subject : String, body : String, from : String = "", headers : Array = null) : void {
			headers = headers == null ? new Array() : headers;
			security.prepare();
			if(security.sessionAndKey()) {
				systemService.mail(security.getHash("system.mail"), security.getDomain(), security.getTimeStamp(), security.getNonce(), getSessionId(), mailKey, to, subject, body, from, headers);
			}else if (security.keyOnly()) {
				systemService.mail(security.getHash("system.mail"), security.getDomain(), security.getTimeStamp(), security.getNonce(), mailKey, to, subject, body, from, headers);
			}else if(security.sessionOnly()) {
				systemService.mail(getSessionId(), mailKey, to, subject, body, from, headers);
			} else if(security.noSessionNoKey()) {
				systemService.mail(mailKey, to, subject, body, from, headers);
			}
		}

		
		/**
		 * destroy the drupalservice, clean it up
		 * override in subclass to clean up your custom stuff. make sure to call super.destroy()
		 */
		public function destroy() : void {
			systemService.removeEventListener(RemotingEvent.ERROR_IO, onConnectError);
			systemService.removeEventListener(RemotingEvent.ERROR_ASYNC, onConnectError);
			systemService.removeEventListener(RemotingEvent.ERROR_SECURITY, onConnectError);
			userService.removeEventListener(RemotingEvent.ERROR_IO, onConnectError);
			userService.removeEventListener(RemotingEvent.ERROR_ASYNC, onConnectError);
			userService.removeEventListener(RemotingEvent.ERROR_SECURITY, onConnectError);
			taxonomyService.removeEventListener(RemotingEvent.ERROR_IO, onConnectError);
			taxonomyService.removeEventListener(RemotingEvent.ERROR_ASYNC, onConnectError);
			taxonomyService.removeEventListener(RemotingEvent.ERROR_SECURITY, onConnectError);
			nodeService.removeEventListener(RemotingEvent.ERROR_IO, onConnectError);
			nodeService.removeEventListener(RemotingEvent.ERROR_ASYNC, onConnectError);
			nodeService.removeEventListener(RemotingEvent.ERROR_SECURITY, onConnectError);
			searchService.removeEventListener(RemotingEvent.ERROR_IO, onConnectError);
			searchService.removeEventListener(RemotingEvent.ERROR_ASYNC, onConnectError);
			searchService.removeEventListener(RemotingEvent.ERROR_SECURITY, onConnectError);
			viewsService.removeEventListener(RemotingEvent.ERROR_IO, onConnectError);
			viewsService.removeEventListener(RemotingEvent.ERROR_ASYNC, onConnectError);
			viewsService.removeEventListener(RemotingEvent.ERROR_SECURITY, onConnectError);
			menuService.removeEventListener(RemotingEvent.ERROR_IO, onConnectError);
			menuService.removeEventListener(RemotingEvent.ERROR_ASYNC, onConnectError);
			menuService.removeEventListener(RemotingEvent.ERROR_SECURITY, onConnectError);
			
			systemService.destroy();
			userService.destroy();
			taxonomyService.destroy();
			nodeService.destroy();
			searchService.destroy();
			viewsService.destroy();
			menuService.destroy();
			security = null;
			user = null;
		}

		
		
		
		
		/**
		 * searches users
		 */
		public function searchUsers(keys : String) : void {
			//does not use authentication keys
			if(security.useSession()) {
				searchService.save(getSessionId(), keys);
			} else {
				searchService.save(keys);
			}
		}

		/**
		 * searches nodes
		 */
		public function searchNodes(keys : String, simple : String = "") : void {
			//does not use authentication keys
			if(security.useSession()) {
				searchService.save(getSessionId(), keys, simple);
			} else {
				searchService.save(keys, simple);
			}
		}

		override public function toString() : String {
			return "DrupalService";
		}

		/**
		 * gets the sessionId from drupal.
		 * This is only available after a sucessful call to systemConnect() or via loginUser().
		 * Which method you need to call first to get a sessionId is also dependent on how the services module is configured.
		 * You can also set the sessionId via setSessionId().
		 */
		public function getSessionId() : String {
			return security.getSessionId();
		}

		/**
		 * sets the sessionId. 
		 * This might be useful if you would like to use multipe DrupalServices from within the same flash client and one of them gets the sessionId first. 
		 * The other can then use the same sessionId (which might be coupled to a logged in user for example).
		 * It can also be useful if you are logged in via a drupal frontend and want to pass in the sessionid to  a flash file, so you can immediately use the flash file as a logged in user.
		 * A way to pass in the sessionId could be via the FlashVarsRegistry, which uses flash variables.
		 * @see nl.dpdk.utils.FlashVarsRegistry
		 * @param sessionId the sessionId that will be passed to the drupal backend when a sessionId is required.
		 */
		public function setSessionId(sessionId : String) : void {
			security.setSessionId(sessionId);
		}

		/**
		 * gets the currently logged in user, or an empty object when no user is logged in.
		 */
		public function getUser() : Object {
			return user ? user : new Object();
		}
		
		/**
		 * sets data (a drupal user object) on the service as the currently logged in user.
		 * Normally you will get this user obect via a call to userLogin(), which will add the user object to the service automatically.
		 * In case you are logged in via the drupal site itself, you could pass a user Object to flash (for example via ExternalInterface).
		 * This might be useful because you don't want to log in via the drupal site itself AND via flash if you have a hybrid php/flash site.
		 * If you want to have only the functionality for when you are logged in via drupal, either pass in a valid sessionId via setSession() or make a call to userLogin()
		 * @param user a user object
		 * @see #userLogin
		 * @see #setSessionId
		 */
		public function setUser(user: Object) : void {
			this.user = user;
		}

		/**
		 * gets the drupal security object configured for this service
		 */
		public function getSecurity() : DrupalSecurity {
			return security;
		}
	}
}
