import AutoConsent from '@duckduckgo/autoconsent';
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
