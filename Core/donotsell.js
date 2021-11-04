//
//  donotsell.js
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

(function () {
    function getTopLevelURL () {
        try {
            // FROM: https://stackoverflow.com/a/7739035/73479
            // FIX: Better capturing of top level URL so that trackers in embedded documents are not considered first party
            return new URL(window.location !== window.parent.location ? document.referrer : document.location.href)
        } catch (error) {
            return new URL(location.href)
        }
    }

    let gpcEnabled = $GPC_ENABLED$

    const topLevelUrl = getTopLevelURL()
    const domainParts = topLevelUrl && topLevelUrl.host ? topLevelUrl.host.split('.') : []
        
    const userExcluded = `$USER_UNPROTECTED_DOMAINS$`.split("\n").filter(domain => domain.trim() == topLevelUrl.host).length > 0
    if (userExcluded) {
        return;
    }
        
    while (domainParts.length > 1 && gpcEnabled) {
        const partialDomain = domainParts.join('.')
        const gpcExcluded = `$TEMP_UNPROTECTED_DOMAINS$`.split('\n').filter(domain => domain.trim() === partialDomain).length > 0
        console.log(partialDomain, gpcExcluded)
        if (gpcExcluded) {
            gpcEnabled = false
            break
        }
        domainParts.shift()
    }
    if (!gpcEnabled) {
        return
    }
    
    const scriptContent = `
        if (navigator.globalPrivacyControl === undefined) {
            Object.defineProperty(Navigator.prototype, 'globalPrivacyControl', {
                get: () => true,
                configurable: true,
                enumerable: true
            });
        } else {
            try {
                navigator.globalPrivacyControl = true;
            } catch (e) {
                console.error('globalPrivacyControl is not writable: ', e);
            }
        }
    `

    const e = document.createElement('script')
    e.textContent = scriptContent;
    (document.head || document.documentElement).appendChild(e)
    e.remove()
})()
