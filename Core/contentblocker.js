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

var duckduckgoContentBlocking = function() {

    // tld.js
    var tldjs = {

        parse: function(url) {

            if (url.startsWith("//")) {
                url = "http:" + url;
            }

            try {
                var parsed = new URL(url);
                return {
                    domain: parsed.hostname,
                    hostname: parsed.hostname
                }
            } catch {
                return {
                    domain: "",
                    hostname: ""
                }
            }
        }

    };
    // tld.js

    // util.js
    var utils = {

        extractHostFromURL: function(url, shouldKeepWWW) {
            if (!url) return ''

            let urlObj = tldjs.parse(url)
            let hostname = urlObj.hostname || ''

            if (!shouldKeepWWW) {
                hostname = hostname.replace(/^www\./, '')
            }

            return hostname
        }

    };
    // util.js

    // Buffer
    class Buffer {
        static from(string, type) {
            return new Buffer(string);
        }

        constructor(string) {
            this.string = string;
        }

        toString(type) {
            let string = this.string;
            var aUTF16CodeUnits = new Uint16Array(string.length);
            Array.prototype.forEach.call(aUTF16CodeUnits, function (el, idx, arr) { arr[idx] = string.charCodeAt(idx); });
            return btoa(String.fromCharCode.apply(null, new Uint8Array(aUTF16CodeUnits.buffer)));
        }
    }
    // Buffer

    // trackers.js - https://raw.githubusercontent.com/duckduckgo/privacy-grade/298ddcbdd9d55808233643d90639578cd063a439/src/classes/trackers.js
    (function () {
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
            for (let name in data) {
                if (data[name].rules) {
                    for (let i in data[name].rules) {
                        data[name].rules[i].rule = new RegExp(data[name].rules[i].rule, 'ig')
                    }
                }
            }
            return data
        }

        processEntityList (data) {
            const processed = {}
            for (let entity in data) {
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

            const {action, reason} = this.getAction({
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
            let urlList = Array.from(requestData.urlToCheckSplit)

            while (urlList.length > 1) {
                let trackerDomain = urlList.join('.')
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
            let siteUrlList = Array.from(requestData.siteUrlSplit)

            while (siteUrlList.length > 1) {
                let siteToCheck = siteUrlList.join('.')
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
                tracker.rules.some(ruleObj => {
                    if (this.requestMatchesRule(requestData, ruleObj)) {
                        matchedRule = ruleObj
                        return true
                    }
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
                ? ruleDefinition.types.includes(requestData.request.type) : true

            const matchDomains = (ruleDefinition.domains && ruleDefinition.domains.length)
                ? ruleDefinition.domains.some(domain => domain.match(requestData.siteDomain)) : true

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

            return {action, reason}
        }
        }
        
        if (typeof module !== 'undefined' && typeof module.exports !== 'undefined')
            module.exports = Trackers
        else
            window.Trackers = Trackers

    })()
    // trackers.js

    // surrogates
    let surrogates = `
    ${surrogates}
    `
    // surrogates
        
    // tracker data set
    let trackerData = ${trackerData}
    // tracker data set

    let trackers = new Trackers({
        tldjs: tldjs,
        utils: utils
    });

    // update algorithm with the data it needs
    trackers.setLists([{ 
            name: "tds",
            data: trackerData
        },
        {
            name: "surrogates",
            data: surrogates
        }
    ]);

	let topLevelUrl = getTopLevelURL()

    let whitelist = `
    ${whitelist}
    `

	// private 
	function getTopLevelURL() {
		try {
			// FROM: https://stackoverflow.com/a/7739035/73479
			// FIX: Better capturing of top level URL so that trackers in embedded documents are not considered first party
			return new URL(window.location != window.parent.location ? document.referrer : document.location.href)
		} catch(error) {
			return new URL(location.href)
		}
	}

    // private
    function loadSurrogate(surrogatePattern) {
        var s = document.createElement("script")
        s.type = "application/javascript"
        s.async = true
        s.src = trackers.surrogateList[surrogatePattern]
        sp = document.getElementsByTagName("script")[0]
        sp.parentNode.insertBefore(s, sp)
    }

	// public
	function shouldBlock(trackerUrl, type, blockFunc) {
        let startTime = performance.now()
        
        // TODO check the whitelist

        let result = trackers.getTrackerData(trackerUrl.toString(), topLevelUrl.toString(), {
        	type: type
        }, null);

		if (result == null) {
            duckduckgoDebugMessaging.signpostEvent({event: "Request Allowed",
                                                   url: trackerUrl,
                                                   time: performance.now() - startTime})
			return false;
		}

		var blocked = false;
		if (result.action === 'block') {
			blocked = true;
		} else if (result.matchedRule && result.matchedRule.surrogate) {
			blocked = true;
		}

        duckduckgoMessaging.trackerDetected({
	        url: trackerUrl,
	        blocked: blocked,
	        reason: result.reason,
        })
        
        if (blocked) {

            if (result.matchedRule && result.matchedRule.surrogate) {
            	loadSurrogate(result.matchedRule.surrogate)
            }

            duckduckgoDebugMessaging.signpostEvent({event: "Tracker Blocked",
                                                   url: trackerUrl,
                                                   time: performance.now() - startTime})
        } else {
            duckduckgoDebugMessaging.signpostEvent({event: "Tracker Allowed",
                                                   url: trackerUrl,
                                                   time: performance.now() - startTime})
        }

		return blocked;
	}

	// Init 
	(function() {
		duckduckgoDebugMessaging.log("content blocking initialised")
	})()

	return { 
		shouldBlock: shouldBlock
	}
}()
