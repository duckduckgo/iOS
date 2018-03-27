
// Based on https://github.com/131/node-tld
var duckduckgoTLDParser = function() {

    var tlds = ${tlds}

	// public
	function extractDomain(url) {
		var host = url.hostname
		var parts = host.split(".")
	  	var stack = ""
	  	var tldLevel = 1 //unknown tld are 1st level
	  	
	  	for(var i = parts.length - 1, part; i >= 0; i--) {
	    	part = parts[i]
	    	stack = stack ? part + "." + stack : part

	    	if (!tlds[stack]) {
	    		break
	    	}

	    	tldLevel = tlds[stack]
	  	}

	  	if (parts.length <= tldLevel) {	
	    	return parts[0]
	  	}

	  	return parts.slice(-tldLevel - 1).join('.')
	}

	return {
		extractDomain: extractDomain		
	}

}()
