package nl.dpdk.services.gephyr {

	/**
	 * Utils class for drupal based stuff.
	 * @author rolf
	 */
	public class DrupalUtils {

		public static const TYPE_PAGE : String = "page";
		public static const TYPE_STORY : String = "story";
		public static const MENU_PRIMARY: String = "primary-links";
		public static const MENU_SECONDARY: String = "secondary-links";
		public static const MENU_NAVIGATION: String = "navigation";

		/**
		 * generates a timestamp for newly created or modified content such as nodes or users.
		 */
		public static function getTimeStamp() : String {
			return	int(new Date().getTime() / 1000).toString();
		}

		
		/**
		 * returns a simple drupal user object.
		 * @param name the name of the user
		 * @param email the email of the user
		 * @param uid Optional parameter, defaults to the uid of a new user. If another number is specified user.save will update the existing user
		 */
		public static function createUser(name : String, email : String, uid : uint = 0) : Object {
			var user : Object = new Object();
			user.name = name;
			user.email = email;
			user.uid = uid;
			return user;
		}

		/**
		 * returns a simple drupal node object, with a proper timestamp for creation date.
		 * @param type The type of the node, either a built in type such as DrupalUtils.TYPE_PAGE or TYPE_STORY or a custom type
		 * @param title The title of the node
		 * @param body Optional parameter, the body of the node
		 * @param nid Optional parameter, defaults to the nid of a new node
		 */
		public static function createNode(type : String, title : String, body : String = "", nid : int = 0) : Object {
			var node : Object = new Object();
			node.type = type;
			node.created = getTimeStamp();
			node.title = title;
			node.body = body;
			node.nid = nid;
			return node;
		}
	}
}
