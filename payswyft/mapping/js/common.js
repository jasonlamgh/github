$(document).ready(function() 
{
	jQuery.Common 			= function(){};	
	jQuery.Common.Check		= function(){};
	jQuery.Common.Logger	= function(){};
	jQuery.Common.String 	= function(){};
	jQuery.Common.Validator = function(){};
	
	jQuery.Common.Check.FileReader = function(){
		if (window.File && window.FileReader && window.FileList && window.Blob) { return true; }
		return false;
	};
	
	jQuery.Common.Check.Flash = function(value) {
		var p = swfobject.getFlashPlayerVersion(); // returns a JavaScript object
		var v = p.major; // access the major, minor and release version numbers via their respective properties		
		if(v >= value) { return true; }		
		return false;
	};

			
	/*
	 *	<syntax>jQuery.Common.String.IsEmpty</syntax>
	 *	<parameters>value The initial value of the String object</parameters>
	 *	<description>returns true or false if the string value passed in empty, undefined, null or blank</description>
	 */
	jQuery.Common.String.IsEmpty = function(value) {
		return (!value || /^\s*$/.test(value));	
	};
	
	jQuery.Common.Logger.Console = function(value) {
		var isDebug = DEBUG ? true : false;
		if(isDebug){ console.log(value); }
	}
	
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