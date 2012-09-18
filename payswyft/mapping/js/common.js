$(document).ready(function() 
{
	jQuery.Common 			= function(){};	
	jQuery.Common.Check		= function(){};
	jQuery.Common.CSV		= function(){};
	jQuery.Common.Logger	= function(){};
	jQuery.Common.String 	= function(){};
	jQuery.Common.Validator = function(){};
	
	/*
	 *	<syntax></syntax>
	 *	<parameters></parameters>
	 *	<description></description>
	 */
	jQuery.Common.Check.FileReader = function(){
		if (window.File && window.FileReader && window.FileList && window.Blob) { return true; }
		return false;
	};
	
	/*
	 *	<syntax></syntax>
	 *	<parameters></parameters>
	 *	<description></description>
	 */
	jQuery.Common.Check.Flash = function(value) {
		var p = swfobject.getFlashPlayerVersion(); // returns a JavaScript object
		var v = p.major; // access the major, minor and release version numbers via their respective properties		
		if(v >= value) { return true; }		
		return false;
	};
	
	/*
	 *	<syntax></syntax>
	 *	<parameters></parameters>
	 *	<description></description>
	 */
	jQuery.Common.CSV.Clean = function(value) {
		var regex = '';
		var csv = value;

		//("?(?:"|\$|-)*(\d)*(,\d{3}))

		// comma(s) not within double quotes	
		regex = /([^",]),([^",])/g;
		while (m = regex.exec(csv)) {
		    var start = m.index;
		    var end = m.index + m[0].length;
		    
		    csv = jQuery.Common.String.ReplaceByRangeIndex(csv, " ", start, end);
		}
		
		regex = /"/g;
		while (m = regex.exec(csv)) {
		    var start = m.index;
		    var end = m.index + m[0].length;
		    csv = jQuery.Common.String.ReplaceByRangeIndex(csv, " ", start, end);
		}
		
		// replace $, "
		regex = /[\$"]/g;
		csv = csv.replace(regex, '');
				
		return csv;
	}
	
	/*
	 *	<syntax></syntax>
	 *	<parameters></parameters>
	 *	<description></description>
	 */
/*
	jQuery.Common.CSV.IsValid = function(value) {
		var result 	= true;
		var regex	= '';		
				 
		// :TODO: throw custom error		
		regex = /([^"]+?),([^"]+)/gm;		 
		if(value.search(regex)!= -1)
			return false; 
		 
		return result;
	 } 
*/
			
	/*
	 *	<syntax></syntax>
	 *	<parameters></parameters>
	 *	<description></description>
	 */
	jQuery.Common.String.IsEmpty = function(value) {
		return (!value || /^\s*$/.test(value));	
	};
	
	/*
	 *	<syntax></syntax>
	 *	<parameters></parameters>
	 *	<description></description>
	 */
	jQuery.Common.String.ReplaceByRangeIndex = function(string, replace, start, end) {
	    var str = string;    
	    for (var i = start; i < end; i++) {
	        if (str.charAt(i) == ",") {
	            str = str.slice(0, (i)) + replace + str.slice((i+1), str.length);
	        }
	    }
	    return str;
	}
	
	/*
	 *	<syntax></syntax>
	 *	<parameters></parameters>
	 *	<description></description>
	 */
	jQuery.Common.Logger.Console = function(value) {
		var isDebug = DEBUG ? true : false;
		if(isDebug){ console.log(value); }
	}
	
	/*
	 *	<syntax></syntax>
	 *	<parameters></parameters>
	 *	<description></description>
	 */
	jQuery.Common.Validator.ErrorMessage = function(value) {
		var obj = {}
		var msg = {
		    "-1": {
		        "code": "-1",
		        "message": "UNKNOWN RESULT "
		    },
		    "00": {
		        "code": "00",
		        "message": "SUCCESS"
		    },
		    "20": {
		        "code": "20",
		        "message": "INVALID FILE"
		    },
		    "21": {
		        "code": "21",
		        "message": "INVALID CSV HEADER"
		    },
		    "22": {
		        "code": "22",
		        "message": "INVALID CSV DATA"
		    }
		}
		
		try {
		    obj.code = msg[value].code;
		    obj.message = msg[value].message;
		} catch (e) {
		    obj.code = "-1";
		    obj.message = msg["-1"].message;
		}
		
		return obj;
	}
});