
(function () {
    const duckduckgoDebugMessaging = (function () {
        let log = () => {}
        let signpostEvent = () => {}

        if ($IS_DEBUG$) {
            signpostEvent = function signpostEvent (data) {
                try {
                    webkit.messageHandlers.signpostMessage.postMessage(data)
                } catch (error) {}
            }

            log = function log () {
                try {
                    webkit.messageHandlers.log.postMessage(JSON.stringify(arguments))
                } catch (error) {}
            }
        }

        return {
            signpostEvent,
            log
        }
    }())

    const logger = duckduckgoDebugMessaging // switch to console if helpful

    logger.log('installing loginDetection.js - IN')

    function loginFormDetected () {
        try {
            webkit.messageHandlers.loginFormDetected.postMessage({})
        } catch (error) {
            // webkit might not be defined
        }
    }

    function inputVisible (input) {
        return !(input.offsetWidth === 0 && input.offsetHeight === 0) && !input.ariaHidden && !input.hidden
    }

    function checkIsLoginForm (form) {
        logger.log('checking form ' + form)

        const inputs = form.getElementsByTagName('input')
        if (!inputs) {
            return
        }

        for (let i = 0; i < inputs.length; i++) {
            const input = inputs.item(i)
            if (input.type === 'password' && inputVisible(input)) {
                logger.log('found password in form ' + form)
                loginFormDetected()
                return true
            }
        }

        logger.log('no password field in form ' + form)
        return false
    }

    function submitHandler (event) {
        checkIsLoginForm(event.target)
    }

    function scanForForms () {
        logger.log('Scanning for forms')

        const forms = document.forms
        if (!forms || forms.length === 0) {
            logger.log('No forms found')
            return
        }

        for (let i = 0; i < forms.length; i++) {
            const form = forms[i]
            form.removeEventListener('submit', submitHandler)
            form.addEventListener('submit', submitHandler)
            logger.log('adding form handler ' + i)
        }
    }

    // *** Add listeners

    window.addEventListener('DOMContentLoaded', function (event) {
    // Wait before adding submit handlers because sometimes forms are created by JS after the DOM has loaded
        setTimeout(scanForForms, 1000)
    })

    window.addEventListener('click', scanForForms)
    window.addEventListener('beforeunload', scanForForms)

    window.addEventListener('submit', submitHandler)

    try {
        const observer = new PerformanceObserver((list, observer) => {
            const entries = list.getEntries().filter((entry) => {
                const found = entry.initiatorType === 'xmlhttprequest' && entry.name.split('?')[0].match(/login|sign-in/)
                if (found) {
                    logger.log('XHR: observed login - ' + entry.name.split('?')[0])
                }
                return found
            })

            if (entries.length === 0) {
                return
            }

            logger.log('XHR: checking forms - IN')
            const forms = document.forms
            if (!forms || forms.length === 0) {
                logger.log('XHR: No forms found')
                return
            }

            for (let i = 0; i < forms.length; i++) {
                if (checkIsLoginForm(forms[i])) {
                    logger.log('XHR: found login form')
                    break
                }
            }
            logger.log('XHR: checking forms - OUT')
        })
        observer.observe({ entryTypes: ['resource'] })
    } catch (error) {
    // no-op
    }

    logger.log('installing loginDetection.js - OUT')
})()
