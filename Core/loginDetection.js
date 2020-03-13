c
 
    window.addEventListener("DOMContentLoaded", function(event) {

        var inputs = document.getElementsByTagName("input");
        if (inputs) {
            for (var i = 0; i < inputs.length; i++) {
                var input = inputs.item(i)
                if (input.type == "password") {
                    duckduckgoMessaging.loginFormDetected();
                    return;
                }
            }
        }

    });

    window.addEventListener("submit", function(event) {

    	var inputs = event.target.getElementsByTagName("input");
    	if (inputs) {
    		for (var i = 0; i < inputs.length; i++) {
    			var input = inputs.item(i)
    			if (input.type == "password") {
			        duckduckgoMessaging.possibleLogin("form", null);
			        return;
    			}
    		}
    	}

    });

    // not available before iOS 11
    try {
        const observer = new PerformanceObserver((list, observer) => {                                                
            const entries = list.getEntries().filter((entry) => { return entry.initiatorType == "xmlhttprequest" && entry.name.split("?")[0].match(/[Ll]ogin/) });
            if (entries.length > 0) {
                duckduckgoMessaging.possibleLogin("xhr",  entries[0].name);
            } 
        });
        observer.observe({entryTypes: ["resource"]});        
    } catch(error) {
        // no-op
    }
 
}) ()
