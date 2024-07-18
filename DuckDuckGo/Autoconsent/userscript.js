import AutoConsent from '@duckduckgo/autoconsent';
import { collectMetrics } from '@duckduckgo/autoconsent';
import * as rules from '@duckduckgo/autoconsent/rules/rules.json';

const autoconsent = new AutoConsent(
    (message) => {
        // console.log('sending', message);
        if (window.webkit.messageHandlers[message.type]) {
            window.webkit.messageHandlers[message.type].postMessage(message).then(resp => {
                // console.log('received', resp);
                autoconsent.receiveMessageCallback(resp);
            });
        }
    },
    null,
    rules,
);
window.autoconsentMessageCallback = (msg) => {
    autoconsent.receiveMessageCallback(msg);
}

if (window.top === window) {
    collectMetrics().then((results) => {
        // pass the results to the native code. ddgPerfMetrics is a custom JS interface
        const resultsJson = JSON.stringify(results);
        window.webkit.messageHandlers['ddgPerfMetrics']?.postMessage(location.href + ' ' + resultsJson);
        console.log(`PERF METRICS: ` + resultsJson);
        window.alert(`PERF METRICS: ` + resultsJson);
    });
}