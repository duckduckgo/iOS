

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

    // *** Add listeners

    window.addEventListener("DOMContentLoaded", function(event) {
                            
            // Wait before handling submit handlers because sometimes forms are created by JS after the DOM has loaded
            setTimeout(() => {

                var forms = document.getElementsByTagName("form")
                if (!forms) {
                    return
                }

                for (var i = 0; i < forms.length; i++) {
                    var form = forms[i];
                    form.addEventListener("submit", submitHandler);
                    logger.log("*** adding form handler " + i);
                }

            }, 1000);
                            
    });

    window.addEventListener("submit", submitHandler);

    try {
        const observer = new PerformanceObserver((list, observer) => {                                                
            const entries = list.getEntries().filter((entry) => { 
                var found = entry.initiatorType == "xmlhttprequest" && entry.name.split("?")[0].match(/login|sign-in/);
                if (found) {
                    logger.log("*** observed login XHR " + entry.name.split("?")[0]);
                }
                return found;
            });

            if (entries.length == 0) {
                return;
            } 

            var forms = document.getElementsByTagName("form")
            if (!forms) {
                return
            }

            for (var i = 0; i < forms.length; i++) {
                if (checkIsLoginForm(forms[i])) {
                    return;
                }
            }

        });
        observer.observe({entryTypes: ["resource"]});        
    } catch(error) {
        // no-op
    }

    logger.log("*** installing loginDetection.js - OUT");
 
}) ()
