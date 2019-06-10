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

	var parentEntityUrl = null
	var topLevelUrl = null

	// private
	function handleDetection(url, detectionMethod) {
		if (isAssociatedFirstPartyDomain(url)) {
			duckduckgoMessaging.log("first party url: " + url)
			return null
		}

		if (!duckduckgoBlockerData.blockingEnabled) {
			return {
				method: detectionMethod,
				block: false,
				reason: "protection disabled"
			}
		}

		if (currentDomainIsWhitelisted()) {
			duckduckgoMessaging.log("domain whitelisted: " + url)
			return {
				method: detectionMethod,
				block: false,
				reason: "domain whitelisted"
			}
		}

		duckduckgoMessaging.log("blocking: " + url)
		return {
			method: detectionMethod,
			block: true,
			reason: "tracker detected"
		}
	}

	// private
	function toURL(url, protocol) {
		try {
			return new URL(url.startsWith("//") ? protocol + url : url)
		} catch(error) {
			return null
		}
	}

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
	function currentDomainIsWhitelisted() {
		return duckduckgoBlockerData.whitelist[topLevelUrl.host]
	}

	// private
	function trackerWhitelisted(trackerUrl, type) {
		return abpMatch(trackerUrl, type, "whitelist", duckduckgoBlockerData.easylistWhitelist)
	}

	// from https://stackoverflow.com/a/7616484/73479
	// private 
	function hashCode(string) {
		var hash = 0, i, chr;
		if (string.length === 0) return hash;
  		for (i = 0; i < string.length; i++) {
    		chr   = string.charCodeAt(i);
    		hash  = ((hash << 5) - hash) + chr;
    		hash |= 0; 
  		}
  		return hash;
	}

	// private
	function getStatus(url) {
		return statuses[hashCode(event.url)]
	}

	// private
	function domainsMatch(url1, url2) {
		return duckduckgoTLDParser.extractDomain(url1) == duckduckgoTLDParser.extractDomain(url2)
	}

	// private
	function isDuckDuckGo(url) {
		return url.hostname.endsWith("duckduckgo.com")
	}

	// private
	function urlBelongsToThisSite(urlToCheck) {
		return domainsMatch(urlToCheck, topLevelUrl)
	}

	// private
	function urlBelongsToSiteParent(urlToCheck) {
		return parentEntityUrl && domainsMatch(parentEntityUrl, urlToCheck)
	}

	// private
	function urlBelongsToRelatedSite(urlToCheck) {
		if (!parentEntityUrl) {
			return false
		}

		var related = DisconnectMe.parentTracker(urlToCheck)	
		if (!related) {
			return false
		}

		var relatedUrl = new URL(topLevelUrl.protocol + related.parent);
		if (!domainsMatch(relatedUrl, parentEntityUrl)) {
			return false
		}

		return true
	}

	// private
	function isAssociatedFirstPartyDomain(trackerUrl) {
		var urlToCheck = toURL(trackerUrl, topLevelUrl.protocol)
		if (urlToCheck == null) {
			return false
		}

		if (urlBelongsToThisSite(urlToCheck)) {
			return true
		}

		if (urlBelongsToSiteParent(urlToCheck)) { 
			return true
		}

		if (urlBelongsToRelatedSite(urlToCheck)) {
			return true
		}

		return false
	}

	// private
	function getParentEntityUrl() {
		var parentEntity = DisconnectMe.parentTracker(topLevelUrl)
		if (parentEntity) {
			duckduckgoMessaging.log("topLevelUrl: " + topLevelUrl.protocol + " parentEntity: " + JSON.stringify(parentEntity))
			return new URL(topLevelUrl.protocol + parentEntity.parent)
		}
		return null
	}

	// private
	function disconnectMeMatch(trackerUrl) {
		var url = toURL(trackerUrl, topLevelUrl.protocol)
		if (!url) {
			return null
		}

		var result = DisconnectMe.parentTracker(url)
		if (result && result.banned) {			
			return handleDetection(trackerUrl, "disconnectme")
		}		

		return null
	}

	// private
	function abpMatch(trackerUrl, type, name, list) {
		if (Object.keys(list).length == 0) { return }

		var typeMask = ABPFilterParser.elementTypes[type.toUpperCase()]

		var config = {
			domain: document.location.hostname,
			elementTypeMask: typeMask
		}

		var result = ABPFilterParser.matches(list, trackerUrl, config)
		return result
	}

	// private
	function checkEasylist(trackerUrl, type, easylist, name) {
		if (abpMatch(trackerUrl, type, name, easylist)) {			
			return handleDetection(trackerUrl, name)
		}
		return null
	}

	// private
	function easylistPrivacyMatch(trackerUrl, type) {
		return checkEasylist(trackerUrl, type, duckduckgoBlockerData.easylistPrivacy, "easylist-privacy")
	}

	// private
	function easylistMatch(trackerUrl, type) {
		return checkEasylist(trackerUrl, type, duckduckgoBlockerData.easylist, "easylist")
	}

	// public 
	function loadSurrogate(url) {
		var withoutQueryString = url.split("?")[0]        	
		duckduckgoMessaging.log("looking for surrogate for " + withoutQueryString)

        var suggorateKeys = Object.keys(duckduckgoBlockerData.surrogates)
        for (var i = 0; i < suggorateKeys.length; i++) {
        	var key = suggorateKeys[i]
            if (withoutQueryString.endsWith(key)) {
                var surrogate = duckduckgoBlockerData.surrogates[key]
                var s = document.createElement("script")
                s.type = "application/javascript"
                s.async = true
                s.src = surrogate
                sp = document.getElementsByTagName("script")[0]
                sp.parentNode.insertBefore(s, sp)
                return true
            }
        }

        return false
	}

	// public
	function shouldBlock(trackerUrl, type, blockFunc) {
        var startTime = performance.now()
        
		if (trackerWhitelisted(trackerUrl, type)) {
			blockFunc(trackerUrl, false)

            duckduckgoMessaging.signpostEvent({event: "Request Allowed",
                                              url: trackerUrl,
                                              time: performance.now() - startTime})
			return false
		}

		var detectors = [
			disconnectMeMatch,
			easylistPrivacyMatch,
			easylistMatch
		]

		var result = null
		for (var i = 0; i < detectors.length; i++) {
			result = detectors[i](trackerUrl, type)
			if (result != null) {
				break;
			}
		}

		if (result == null) {
			blockFunc(trackerUrl, false)

            duckduckgoMessaging.signpostEvent({event: "Request Allowed",
                                              url: trackerUrl,
                                              time: performance.now() - startTime})
			return false;
		}

		blockFunc(trackerUrl, result.block)

        
        duckduckgoMessaging.trackerDetected({
	        url: trackerUrl,
	        blocked: result.block,
	        method: result.method,
	        type: type
        })
        
        if (result.block) {
            duckduckgoMessaging.signpostEvent({event: "Request Blocked",
                                              url: trackerUrl,
                                              time: performance.now() - startTime})
        } else {
            duckduckgoMessaging.signpostEvent({event: "Request Allowed",
                                              url: trackerUrl,
                                              time: performance.now() - startTime})
        }

		return result.block
	}

	// Init 
	(function() {
		topLevelUrl = getTopLevelURL()
		parentEntityUrl = getParentEntityUrl()
		duckduckgoMessaging.log("content blocking initialised")
	})()

	return { 
		loadSurrogate: loadSurrogate,
		shouldBlock: shouldBlock
	}
}()

