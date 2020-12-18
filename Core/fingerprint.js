//
//  fingerprint.js
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

(function protect () {
    // Property values to be set and their original values.
    const fingerprintPropertyValues = {
        'screen': {
            'availTop': {
                'object': 'screen',
                'origValue': screen.availTop,
                'targetValue': 0
            },
            'availLeft': {
                'object': 'screen',
                'origValue': screen.availLeft,
                'targetValue': 0
            },
            'availWidth': {
                'object': 'screen',
                'origValue': screen.availWidth,
                'targetValue': screen.width
            },
            'availHeight': {
                'object': 'screen',
                'origValue': screen.availHeight,
                'targetValue': screen.height
            },
            'screenY': {
                'object': 'window',
                'origValue': window.screenY,
                'targetValue': 0
            },
            'screenLeft': {
                'object': 'window',
                'origValue': window.screenLeft,
                'targetValue': 0
            },
            'colorDepth': {
                'object': 'screen',
                'origValue': screen.colorDepth,
                'targetValue': 24
            },
            'pixelDepth': {
                'object': 'screen',
                'origValue': screen.pixelDepth,
                'targetValue': 24
            }
        },
        'options': {
            'doNotTrack': {
                'object': 'navigator',
                'origValue': navigator.doNotTrack,
                'targetValue': false
            }
        }
    }

    /*
     * Return device specific battery value that prevents fingerprinting.
     * On Desktop/Laptop - fully charged and plugged in.
     * On Mobile, should not plugged in with random battery values every load.
     * Property event functions are also defined, for setting later.
     */
    function getBattery () {
        let battery = {}
        battery.value = {
            charging: true,
            chargingTime: 0,
            dischargingTime: Infinity,
            level: 1
        }
        battery.properties = ['onchargingchange', 'onchargingtimechange', 'ondischargingtimechange', 'onlevelchange']
        return battery
    }

    /**
     * For each property defined on the object, update it with the target value.
     */
    function buildScriptProperties () {
        let script = ''
        for (const category in fingerprintPropertyValues) {
            for (const [name, prop] of Object.entries(fingerprintPropertyValues[category])) {
                // Don't update if existing value is undefined or null
                if (!(prop.origValue === undefined)) {
                    script += `Object.defineProperty(${prop.object}, "${name}", { value: ${prop.targetValue} });\n`
                }
            }
        }
        return script
    }

    /**
     *  Build a script that overwrites the Battery API if present in the browser.
     *  It will return the values defined in the getBattery function to the client,
     *  as well as prevent any script from listening to events.
     */
    function buildBatteryScript () {
        if (navigator.getBattery) {
            const battery = getBattery()
            let batteryScript = `
                navigator.getBattery = function getBattery () {
                let battery = ${JSON.stringify(battery.value)}
            `
            for (const prop of battery.properties) {
                // Prevent setting events via event handlers
                batteryScript += `
                    Object.defineProperty(battery, '${prop}', {
                        enumerable: true,
                        configurable: false,
                        writable: false,
                        value: undefined
                    })
                `
            }

            // Wrap event listener functions so handlers aren't added
            for (const handler of ['addEventListener']) {
                batteryScript += `
                    battery.${handler} = function ${handler} () {
                        return
                    }
                `
            }
            batteryScript += `
                return Promise.resolve(battery)
                }
            `
            return batteryScript
        } else {
            return ''
        }
    }
    
    /**
     * Temporary storage can be used to determine hard disk usage and size.
     * This will limit the max storage to 4GB without completely disabling the
     * feature.
     */
    function modifyTemporaryStorage () {
        const script = `
            if (navigator.webkitTemporaryStorage) {
                try {
                    const org = navigator.webkitTemporaryStorage.queryUsageAndQuota
                    navigator.webkitTemporaryStorage.queryUsageAndQuota = function queryUsageAndQuota (callback, err) {
                        const modifiedCallback = function (usedBytes, grantedBytes) {
                            const maxBytesGranted = 4 * 1024 * 1024 * 1024
                            const spoofedGrantedBytes = Math.min(grantedBytes, maxBytesGranted)
                            callback(usedBytes, spoofedGrantedBytes)
                        }
                        org.call(navigator.webkitTemporaryStorage, modifiedCallback, err)
                    }
                }
                catch(e) {}
            }
        `
        return script
    }

    /**
     * All the steps for building the injection script. Should only be done at initial page load.
     */
    function buildInjectionScript () {
        let script = buildScriptProperties()
        script += modifyTemporaryStorage()
        script += buildBatteryScript()
        return script
    }

    /**
     * Inject all the overwrites into the page.
     */
    function inject (scriptToInject, removeAfterExec) {
        // Inject into main page
        let e = document.createElement('script')
        e.textContent = scriptToInject;
        (document.head || document.documentElement).appendChild(e)

        if (removeAfterExec) {
            e.remove()
        }
    }

    const injectionScript = buildInjectionScript()
    inject(injectionScript)
})()
