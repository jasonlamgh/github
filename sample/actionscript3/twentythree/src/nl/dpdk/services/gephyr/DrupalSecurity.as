package nl.dpdk.services.gephyr {
	import flash.utils.ByteArray;

	import mx.utils.SHA256;

	import nl.dpdk.utils.StringUtils;

	/**
	 * Handles all security related stuff with authentication keys and sessions.
	 * authentication info: http://drupal.org/node/394224
	 * 
	 * An instance of DrupalSecurity can also be used with custom implementations of connecting with drupal.
	 * This means if you have your own drupal stuff, it's possible to use this class standalone.
	 * 
	 * It calculates the hash from the  timestamp, domain nonce, method and key.
	 * The token may expire, I'm not sure if this is dependent on the system clock and the system clock of the server, but if this is the case, this might cause issues on a client that has it's system clock unsynched.
	 * 
	 * The external library com.hurlant.crypto is used, which is NOT released under the MIT license.
	 * See license.txt in the com package for more details.
	 * 
	 * @author Rolf Vreijdenberger
	 */
	public class DrupalSecurity {
		private var key : String;
		private var timestamp : String;
		private var nonce : String;
		private var requireSession : Boolean;
		private var domain : String;
		private var sessionId : String;

		public function DrupalSecurity(requireSession : Boolean = false, key : String = '', domain : String = '') {
			this.requireSession = requireSession;
			this.key = key;
			this.domain = domain;
		}

		private function generateNonce() : void {
			nonce = StringUtils.generateRandomString("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", 10);
		}

		public function getNonce() : String {
			return nonce;
		}

		public function getKey() : String {
			return key;
		}

		
		public function getDomain() : String {
			return domain;
		}

		private function generateTimeStamp() : void {
			timestamp =  DrupalUtils.getTimeStamp();
		}

		
		/**
		 * prepares this object for the generation of a new hash with the right values.
		 */
		public function prepare() : void {
			generateNonce();
			generateTimeStamp();
		}

		public function noSessionNoKey() : Boolean {
			return !useSession() && !hasKey();
		}

		public function sessionAndKey() : Boolean {
			return useSession() && hasKey();
		}

		public function useSession() : Boolean {
			return requireSession;
		}

		public function hasKey() : Boolean {
			return key != '';
		}

		public function sessionOnly() : Boolean {
			return useSession() && !hasKey();
		}

		public function keyOnly() : Boolean {
			return hasKey() && !useSession();
		}

		
		public function getTimeStamp() : String {
			return timestamp;
		}

		
		
		/**
		 * Gets the hash used to send to the drupal service when key authentication is needed.
		 * @param method the service and method name, eg: "user.get", "node.save" etc.
		 * all other values that are needed to calculate the hash will be primed by calling prepare().
		 * call prepare() first, it sets all the correct values for the timestamp and the nonce.
		 */
		public function getHash(method : String) : String {
			var seperator : String = ";";
			var input : String = "";
			var hmac : HMAC = new HMAC(new SHA256());
			input += getTimeStamp();
			input += seperator;
			input += getDomain();
			input += seperator;
			input += getNonce();
			input += seperator;
			input += method;
			var keyData : ByteArray = Hex.toArray(Hex.fromString(getKey()));
			var data : ByteArray = Hex.toArray(Hex.fromString(input));
			var result : ByteArray = hmac.compute(keyData, data);
			var hash : String = Hex.fromArray(result);
			/**
			trace("DrupalSecurity.getHash(method): timestamp: " + timestamp);
			trace("DrupalSecurity.getHash(method): domain: " + domain);
			trace("DrupalSecurity.getHash(method): nonce: " + nonce);
			trace("DrupalSecurity.getHash(method): method: " + method);
			trace("DrupalSecurity.getHash(method): input: " + input);
			trace("DrupalSecurity.getHash(method): key: " + getKey());
			trace("DrupalSecurity.getHash(method): hash: " + hash);
			 */
			return hash;
		}

		public function getSessionId() : String {
			return sessionId;
		}

		public function setSessionId(sessionId : String) : void {
			this.sessionId = sessionId;
		}
	}
}
