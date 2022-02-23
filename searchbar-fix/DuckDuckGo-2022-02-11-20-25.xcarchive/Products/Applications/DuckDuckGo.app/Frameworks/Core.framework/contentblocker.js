//
//  contentblocker.js
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

    function surrogateInjected (data) {
        try {
            webkit.messageHandlers.trackerDetectedMessage.postMessage(data)
        } catch (error) {
            // webkit might not be defined
        }
    }

    // tld.js
    const tldjs = {

        parse: function (url) {
            if (url.startsWith('//')) {
                url = 'http:' + url
            }

            try {
                const parsed = new URL(url)
                return {
                    domain: parsed.hostname,
                    hostname: parsed.hostname
                }
            } catch (error) {
                return {
                    domain: '',
                    hostname: ''
                }
            }
        }

    }
    // tld.js

    // util.js
    const utils = {

        extractHostFromURL: function (url, shouldKeepWWW) {
            if (!url) return ''

            const urlObj = tldjs.parse(url)
            let hostname = urlObj.hostname || ''

            if (!shouldKeepWWW) {
                hostname = hostname.replace(/^www\./, '')
            }

            return hostname
        }

    }
    // util.js

    // Base64
    /**
*
*  Base64 encode / decode
*  http://www.webtoolkit.info/
*
**/
    const Base64 = {

        // private property
        _keyStr: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=',

        // public method for encoding
        encode: function (input) {
            let output = ''
            let chr1, chr2, chr3, enc1, enc2, enc3, enc4
            let i = 0

            input = Base64._utf8_encode(input)

            while (i < input.length) {
                chr1 = input.charCodeAt(i++)
                chr2 = input.charCodeAt(i++)
                chr3 = input.charCodeAt(i++)

                enc1 = chr1 >> 2
                enc2 = ((chr1 & 3) << 4) | (chr2 >> 4)
                enc3 = ((chr2 & 15) << 2) | (chr3 >> 6)
                enc4 = chr3 & 63

                if (isNaN(chr2)) {
                    enc3 = enc4 = 64
                } else if (isNaN(chr3)) {
                    enc4 = 64
                }

                output = output +
        this._keyStr.charAt(enc1) + this._keyStr.charAt(enc2) +
        this._keyStr.charAt(enc3) + this._keyStr.charAt(enc4)
            }

            return output
        },

        // private method for UTF-8 encoding
        _utf8_encode: function (string) {
            string = string.replace(/\r\n/g, '\n')
            let utftext = ''

            for (let n = 0; n < string.length; n++) {
                const c = string.charCodeAt(n)

                if (c < 128) {
                    utftext += String.fromCharCode(c)
                } else if ((c > 127) && (c < 2048)) {
                    utftext += String.fromCharCode((c >> 6) | 192)
                    utftext += String.fromCharCode((c & 63) | 128)
                } else {
                    utftext += String.fromCharCode((c >> 12) | 224)
                    utftext += String.fromCharCode(((c >> 6) & 63) | 128)
                    utftext += String.fromCharCode((c & 63) | 128)
                }
            }

            return utftext
        }

    }
    // Base64

    // Buffer
    class Buffer {
        static from (string, type) {
            return new Buffer(string)
        }

        constructor (string) {
            this.string = string
        }

        toString (type) {
            return Base64.encode(this.string)
        }
    }
    // Buffer

    // trackers.js - https://raw.githubusercontent.com/duckduckgo/privacy-grade/298ddcbdd9d55808233643d90639578cd063a439/src/classes/trackers.js
    class Trackers {
        constructor (ops) {
            this.tldjs = ops.tldjs
            this.utils = ops.utils
        }

        setLists (lists) {
            lists.forEach(list => {
                if (list.name === 'tds') {
                    this.entityList = this.processEntityList(list.data.entities)
                    this.trackerList = this.processTrackerList(list.data.trackers)
                    this.domains = list.data.domains
                } else if (list.name === 'surrogates') {
                    this.surrogateList = this.processSurrogateList(list.data)
                }
            })
        }

        processTrackerList (data) {
            for (const name in data) {
                if (data[name].rules) {
                    for (const i in data[name].rules) {
                        data[name].rules[i].rule = new RegExp(data[name].rules[i].rule, 'ig')
                    }
                }
            }
            return data
        }

        processEntityList (data) {
            const processed = {}
            for (const entity in data) {
                data[entity].domains.forEach(domain => {
                    processed[domain] = entity
                })
            }
            return processed
        }

        processSurrogateList (text) {
            const b64dataheader = 'data:application/javascript;base64,'
            const surrogateList = {}
            const splitSurrogateList = text.trim().split('\n\n')

            splitSurrogateList.forEach(sur => {
                // remove comment lines
                const lines = sur.split('\n').filter((line) => {
                    return !(/^#.*/).test(line)
                })

                // remove first line, store it
                const firstLine = lines.shift()

                // take identifier from first line
                const pattern = firstLine.split(' ')[0].split('/')[1]
                const b64surrogate = Buffer.from(lines.join('\n').toString(), 'binary').toString('base64')
                surrogateList[pattern] = b64dataheader + b64surrogate
            })
            return surrogateList
        }

        getTrackerData (urlToCheck, siteUrl, request, ops) {
            ops = ops || {}

            if (!this.entityList || !this.trackerList) {
                throw new Error('tried to detect trackers before rules were loaded')
            }

            // single object with all of our requeest and site data split and
            // processed into the correct format for the tracker set/get functions.
            // This avoids repeat calls to split and util functions.
            const requestData = {
                ops: ops,
                siteUrl: siteUrl,
                request: request,
                siteDomain: this.tldjs.parse(siteUrl).domain,
                siteUrlSplit: this.utils.extractHostFromURL(siteUrl).split('.'),
                urlToCheck: urlToCheck,
                urlToCheckDomain: this.tldjs.parse(urlToCheck).domain,
                urlToCheckSplit: this.utils.extractHostFromURL(urlToCheck).split('.')
            }

            // finds a tracker definition by iterating over the whole trackerList and finding the matching tracker.
            const tracker = this.findTracker(requestData)

            if (!tracker) {
                return null
            }

            // finds a matching rule by iterating over the rules in tracker.data and sets redirectUrl.
            const matchedRule = this.findRule(tracker, requestData)

            const redirectUrl = (matchedRule && matchedRule.surrogate) ? this.surrogateList[matchedRule.surrogate] : false

            // sets tracker.exception by looking at tracker.rule exceptions (if any)
            const matchedRuleException = matchedRule ? this.matchesRuleDefinition(matchedRule, 'exceptions', requestData) : false

            const trackerOwner = this.findTrackerOwner(requestData.urlToCheckDomain)

            const websiteOwner = this.findWebsiteOwner(requestData)

            const firstParty = (trackerOwner && websiteOwner) ? trackerOwner === websiteOwner : false

            const fullTrackerDomain = requestData.urlToCheckSplit.join('.')

            const { action, reason } = this.getAction({
                firstParty,
                matchedRule,
                matchedRuleException,
                defaultAction: tracker.default,
                redirectUrl
            })

            return {
                action,
                reason,
                firstParty,
                redirectUrl,
                matchedRule,
                matchedRuleException,
                tracker,
                fullTrackerDomain
            }
        }

        /*
         * Pull subdomains off of the reqeust rule and look for a matching tracker object in our data
         */
        findTracker (requestData) {
            const urlList = Array.from(requestData.urlToCheckSplit)

            while (urlList.length > 1) {
                const trackerDomain = urlList.join('.')
                urlList.shift()

                const matchedTracker = this.trackerList[trackerDomain]
                if (matchedTracker) {
                    return matchedTracker
                }
            }
        }

        findTrackerOwner (trackerDomain) {
            return this.entityList[trackerDomain]
        }

        /*
        * Set parent and first party values on tracker
        */
        findWebsiteOwner (requestData) {
            // find the site owner
            const siteUrlList = Array.from(requestData.siteUrlSplit)

            while (siteUrlList.length > 1) {
                const siteToCheck = siteUrlList.join('.')
                siteUrlList.shift()

                if (this.entityList[siteToCheck]) {
                    return this.entityList[siteToCheck]
                }
            }
        }

        /*
         * Iterate through a tracker rule list and return the first matching rule, if any.
         */
        findRule (tracker, requestData) {
            let matchedRule = null
            // Find a matching rule from this tracker
            if (tracker.rules && tracker.rules.length) {
                matchedRule = tracker.rules.find(ruleObj => {
                    if (this.requestMatchesRule(requestData, ruleObj)) {
                        return true
                    }
                    return false
                })
            }
            return matchedRule
        }

        requestMatchesRule (requestData, ruleObj) {
            if (requestData.urlToCheck.match(ruleObj.rule)) {
                if (ruleObj.options) {
                    return this.matchesRuleDefinition(ruleObj, 'options', requestData)
                } else {
                    return true
                }
            } else {
                return false
            }
        }

        /* Check the matched rule  options against the request data
        *  return: true (all options matched)
        */
        matchesRuleDefinition (rule, type, requestData) {
            if (!rule[type]) {
                return false
            }

            const ruleDefinition = rule[type]

            const matchTypes = (ruleDefinition.types && ruleDefinition.types.length)
                ? ruleDefinition.types.includes(requestData.request.type)
                : true

            const matchDomains = (ruleDefinition.domains && ruleDefinition.domains.length)
                ? ruleDefinition.domains.some(domain => domain.match(requestData.siteDomain))
                : true

            return (matchTypes && matchDomains)
        }

        getAction (tracker) {
            // Determine the blocking decision and reason.
            let action, reason
            if (tracker.firstParty) {
                action = 'ignore'
                reason = 'first party'
            } else if (tracker.matchedRuleException) {
                action = 'ignore'
                reason = 'matched rule - exception'
            } else if (!tracker.matchedRule && tracker.defaultAction === 'ignore') {
                action = 'ignore'
                reason = 'default ignore'
            } else if (tracker.matchedRule && tracker.matchedRule.action === 'ignore') {
                action = 'ignore'
                reason = 'matched rule - ignore'
            } else if (!tracker.matchedRule && tracker.defaultAction === 'block') {
                action = 'block'
                reason = 'default block'
            } else if (tracker.matchedRule) {
                if (tracker.redirectUrl) {
                    action = 'redirect'
                    reason = 'matched rule - surrogate'
                } else {
                    action = 'block'
                    reason = 'matched rule - block'
                }
            }

            return { action, reason }
        }
    }

    // trackers.js

    // surrogates
    const surrogates = `
    $SURROGATES$
    `
    // surrogates

    // tracker data set
    const trackerData = $TRACKER_DATA$
    // tracker data set

    const blockingEnabled = $BLOCKING_ENABLED$

    // overrides
    Trackers.prototype.findTrackerOwner = function (domain) {
        let parts = domain.split('.')
        while (parts.length > 1) {
            const entityName = trackerData.domains[parts.join('.')]
            if (entityName) {
                return entityName
            }
            parts = parts.slice(1)
        }
        return null
    }
    Object.freeze(Trackers.prototype)

    // create an instance to use
    const trackers = new Trackers({
        tldjs: tldjs,
        utils: utils
    })

    // update algorithm with the data it needs
    trackers.setLists([{
        name: 'tds',
        data: trackerData
    },
    {
        name: 'surrogates',
        data: surrogates
    }
    ])

    const topLevelUrl = getTopLevelURL()

    let unprotectedDomain = false
    const domainParts = topLevelUrl && topLevelUrl.host ? topLevelUrl.host.split('.') : []

    // walk up the domain to see if it's unprotected
    while (domainParts.length > 1 && !unprotectedDomain) {
        const partialDomain = domainParts.join('.')

        unprotectedDomain = `
          $TEMP_UNPROTECTED_DOMAINS$
          `.split('\n').filter(domain => domain.trim() === partialDomain).length > 0

        domainParts.shift()
    }

    if (!unprotectedDomain && topLevelUrl.host != null) {
        unprotectedDomain = `
          $USER_UNPROTECTED_DOMAINS$
          `.split('\n').filter(domain => domain.trim() === topLevelUrl.host).length > 0
    }

    let trackerAllowlist = {}
    const trackerAllowlistEntries = `
            $TRACKER_ALLOWLIST_ENTRIES$
          `

    if (trackerAllowlistEntries) {
        trackerAllowlist = JSON.parse(trackerAllowlistEntries)
    }

    function isTrackerAllowlisted (siteURL, request) {
        // check that allowlist has entries
        if (!Object.keys(trackerAllowlist).length) {
            return false
        }

        const parsedRequest = tldjs.parse(request)
        const requestDomainParts = Array.from(parsedRequest.domain.split('.'))

        let allowListEntry = null
        while (requestDomainParts.length > 1) {
            const requestDomain = requestDomainParts.join('.')

            allowListEntry = trackerAllowlist[requestDomain]
            if (allowListEntry) {
                break
            }
            requestDomainParts.shift()
        }

        if (allowListEntry) {
            return _matchesRule(siteURL, request, allowListEntry)
        } else {
            return false
        }
    }

    function _matchesRule (siteURL, request, allowListEntryList) {
        let matchedEntry = null

        if (allowListEntryList && allowListEntryList.length) {
            for (const entryObj of allowListEntryList) {
                if (request.match(entryObj.rule)) {
                    matchedEntry = entryObj
                    break
                }
            }
        }

        if (matchedEntry) {
            if (matchedEntry.domains.includes('<all>')) {
                return true
            }

            const siteDomainParts = Array.from(siteURL.host.split('.'))

            while (siteDomainParts.length > 1) {
                const siteDomain = siteDomainParts.join('.')
                if (matchedEntry.domains.includes(siteDomain)) {
                    return true
                }
                siteDomainParts.shift()
            }
        }

        return false
    }

    // private
    function getTopLevelURL () {
        try {
            // FROM: https://stackoverflow.com/a/7739035/73479
            // FIX: Better capturing of top level URL so that trackers in embedded documents are not considered first party
            return new URL(window.location !== window.parent.location ? document.referrer : document.location.href)
        } catch (error) {
            return new URL(location.href)
        }
    }

    const loadedSurrogates = {}

    // private
    function loadSurrogate (surrogatePattern) {
        const s = document.createElement('script')
        s.type = 'application/javascript'
        s.async = true
        s.src = trackers.surrogateList[surrogatePattern]
        const scripts = document.getElementsByTagName('script')
        if (scripts && scripts.length > 0) {
            scripts[0].parentNode.insertBefore(s, scripts[0])
        }
    }

    // public
    function shouldBlock (trackerUrl, type) {
        seenUrls.add(trackerUrl)
        const startTime = performance.now()

        if (!blockingEnabled) {
            return false
        }

        const result = trackers.getTrackerData(trackerUrl.toString(), topLevelUrl.toString(), {
            type: type
        }, null)

        if (result == null) {
            return false
        }

        let blocked = false
        if (unprotectedDomain) {
            result.reason = 'unprotectedDomain'
        } else if (result.action !== 'ignore') {
            // other actions are "block" or "redirect" - anything that is not ignored should be blocked. Surrogates are handled below since
            //  we can't do a redirect.
            blocked = true
        }

        const isSurrogate = !!(result.matchedRule && result.matchedRule.surrogate)

        // Tracker blocking is dealt with by content rules
        // Only handle surrogates here
        if (blocked && isSurrogate && !isTrackerAllowlisted(topLevelUrl, trackerUrl)) {
            if (!loadedSurrogates[result.matchedRule.surrogate]) {
                loadSurrogate(result.matchedRule.surrogate)
                loadedSurrogates[result.matchedRule.surrogate] = true
            }

            const pageUrl = window.location.href
            surrogateInjected({
                url: trackerUrl,
                blocked: blocked,
                reason: result.reason,
                isSurrogate: isSurrogate,
                pageUrl: pageUrl
            })

            duckduckgoDebugMessaging.signpostEvent({
                event: 'Surrogate Injected',
                url: trackerUrl,
                time: performance.now() - startTime
            })

            return true
        }

        return false
    }

    const seenUrls = new Set()
    function hasNotSeen (url) {
        return !seenUrls.has(url)
    }

    function processPage () {
        [...document.scripts].filter(hasNotSeen).forEach((el) => {
            if (shouldBlock(el.src, 'SCRIPT')) {
                duckduckgoDebugMessaging.log('blocking load')
            }
        });
        [...document.images].filter(hasNotSeen).forEach((el) => {
            // If the image's natural width is zero, then it has not loaded so we
            // can assume that it may have been blocked.
            if (el.naturalWidth === 0) {
                if (shouldBlock(el.src, 'IMG')) {
                    duckduckgoDebugMessaging.log('blocking load')
                }
            }
        });
        [...document.querySelectorAll('link')].filter(hasNotSeen).forEach((el) => {
            if (shouldBlock(el.href, 'LINK')) {
                duckduckgoDebugMessaging.log('blocking load')
            }
        });
        [...document.querySelectorAll('iframe')].filter(hasNotSeen).forEach((el) => {
            if (shouldBlock(el.src, 'IFRAME')) {
                duckduckgoDebugMessaging.log('blocking load')
            }
        })
    }

    function debounce (func, wait) {
        let timeout
        return function () {
            clearTimeout(timeout)
            timeout = setTimeout(() => {
                func.apply(this, arguments)
            }, wait)
        }
    }

    const observer = new MutationObserver(debounce((mutations, o) => {
        processPage()
    }, 100))
    const rootElement = document.body || document.documentElement
    observer.observe(rootElement, { childList: true, subtree: true });

    // Init
    (function () {
        duckduckgoDebugMessaging.log('installing load detection')
        window.addEventListener('load', function (event) {
            processPage()
        }, false)

        try {
            duckduckgoDebugMessaging.log('installing image src detection')

            const originalImageSrc = Object.getOwnPropertyDescriptor(Image.prototype, 'src')
            Object.defineProperty(Image.prototype, 'src', {
                writable: true, // Needs to be writable for the content blocking rules script. Will be locked down in that script
                get: function () {
                    return originalImageSrc.get.call(this)
                },
                set: function (value) {
                    const instance = this
                    if (shouldBlock(value, 'image')) {
                        duckduckgoDebugMessaging.log('blocking image src: ' + value)
                    } else {
                        originalImageSrc.set.call(instance, value)
                    }
                }
            })
        } catch (error) {
            duckduckgoDebugMessaging.log('failed to install image src detection')
        }

        try {
            duckduckgoDebugMessaging.log('installing xhr detection')

            const xhr = XMLHttpRequest.prototype
            const originalOpen = xhr.open

            xhr.open = function () {
                const args = arguments
                const url = arguments[1]
                if (shouldBlock(url, 'xmlhttprequest')) {
                    args[1] = 'about:blank'
                }
                duckduckgoDebugMessaging.log('sending xhr ' + url + ' to ' + args[1])
                return originalOpen.apply(this, args)
            }
        } catch (error) {
            duckduckgoDebugMessaging.log('failed to install xhr detection')
        }

        duckduckgoDebugMessaging.log('content blocking initialised')
    })()

    return {
        shouldBlock: shouldBlock
    }
})()
