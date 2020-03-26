

(function() {

    const logger = duckduckgoDebugMessaging; // switch to console if helpful

    logger.log("*** installing loginDetection.js - IN");

    function inputVisible(input) {
        return !(input.offsetWidth === 0 && input.offsetHeight === 0) && !input.ariaHidden && !input.hidden;   
    }

    function checkIsLoginForm(form) {
        logger.log("*** checking form " + form);

        var inputs = form.getElementsByTagName("input");
        if (!inputs) {
            return
        }

        for (var i = 0; i < inputs.length; i++) {
            var input = inputs.item(i);
            if (input.type == "password" && inputVisible(input)) {
                logger.log("*** found password in form " + form);
                duckduckgoMessaging.loginFormDetected();
                return true;
            }
        }

        logger.log("*** no password field in form " + form);
        return false;
    }

    function submitHandler(event) {
        checkIsLoginForm(event.target)
    }

    function scanForForms() {
        logger.log("*** Scanning for forms");

        var forms = document.getElementsByTagName("form")
        if (!forms || forms.length == 0) {
            logger.log("*** No forms found");
            return
        }

        for (var i = 0; i < forms.length; i++) {
            var form = forms[i];
            form.addEventListener("submit", submitHandler);
            logger.log("*** adding form handler " + i);
        }

    }

    // *** Add listeners

    window.addEventListener("DOMContentLoaded", function(event) {                            
        // Wait before handling submit handlers because sometimes forms are created by JS after the DOM has loaded
        setTimeout(scanForForms, 1000);                            
    });

    window.addEventListener("submit", submitHandler);
    window.addEventListener("beforeunload", scanForForms);

    try {
        const observer = new PerformanceObserver((list, observer) => {                                                
            const entries = list.getEntries().filter((entry) => { 
                var found = entry.initiatorType == "xmlhttprequest" && entry.name.split("?")[0].match(/login|sign-in/);
                if (found) {
                    logger.log("*** XHR: observed login - " + entry.name.split("?")[0]);
                }
                return found;
            });

            if (entries.length == 0) {
                return;
            } 

            logger.log("*** XHR: checking forms - IN");
            scanForForms();
            logger.log("*** XHR: checking forms - OUT");

        });
        observer.observe({entryTypes: ["resource"]});        
    } catch(error) {
        // no-op
    }

    logger.log("*** installing loginDetection.js - OUT");
 
}) ()
