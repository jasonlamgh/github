(function ($) {
    $.fn.ffapi = function (params) {
        if (typeof params == "object" && !params.length) {
            var setting = $.extend({
	            path: 	'swf/ffapi.swf',                
                cmd: 	'browse'				                                
            }, params);
                       
            var o 			= $(this[0]);
            var p			= o.parent()[0];				
	        var html 		= '';
	        var flashvars 	= 'alpha=0.01&width=108&height=36&cmd='+setting.cmd;

	        if (navigator.userAgent.match(/MSIE/)) {
	            var protocol = location.href.match(/^https/i) ? 'https://' : 'http://';
	            html += '<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="' + protocol + 'download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=10,0,0,0" width="100%" height="100%" id="' + setting.id + '" align="middle"><param name="allowScriptAccess" value="always" /><param name="allowFullScreen" value="false" /><param name="movie" value="' + setting.path + '" /><param name="loop" value="false" /><param name="menu" value="false" /><param name="quality" value="best" /><param name="bgcolor" value="#ffffff" /><param name="flashvars" value="' + flashvars + '"/><param name="wmode" value="transparent"/></object>';
	        } else {
	            html += '<embed id="' + setting.id+ '" src="' + setting.path + '" loop="false" menu="false" quality="best" bgcolor="#ffffff" width="100%" height="100%" name="' + setting.id + '" align="middle" allowScriptAccess="always" allowFullScreen="false" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" flashvars="' + flashvars + '" wmode="transparent" />';
	        }
			$('#'+setting.id+'-fcontent').append(html);
        }
    }	
})(jQuery);

