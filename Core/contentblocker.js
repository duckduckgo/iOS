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
	function handleDetection(event, parent, detectionMethod) {
		var blocked = block(event)
        duckduckgoMessaging.trackerDetected({
	        url: event.url,
	        networkName: parent,
	        blocked: blocked,
	        method: detectionMethod
        })
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
		// can throw a security exception if called from a frame with document loaded from different url to top (mainly when blocking is disabled)
		try {
			return new URL(top.location.href)
		} catch(error) {
			return new URL(location.href)
		}
	}

	// private
	function disconnectMeMatch(event) {
		var url = toURL(event.url, topLevelUrl.protocol)
		if (!url) {
			return false
		}

		var result = DisconnectMe.parentTracker(url)
		if (result && result.banned) {
			handleDetection(event, result.parent, "disconnectme")
			return true
		}		

		return false
	}

	// private
	function currentDomainIsWhitelisted() {
		return duckduckgoBlockerData.whitelist[topLevelUrl.host]
	}

	// private
	function block(event) {
		if (!duckduckgoBlockerData.blockingEnabled) {
			return false
		}

		if (currentDomainIsWhitelisted()) {
			return false
		}

		if (isAssociatedFirstPartyDomain(event)) {
			return false
		}

		event.preventDefault()
		event.stopPropagation()
		return true
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
	function isAssociatedFirstPartyDomain(event) {
		var urlToCheck = toURL(event.url, topLevelUrl.protocol)
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

	function checkEasylist(event, easylist, name) {
		var config = {
			domain: document.location.hostname,
			elementTypeMaskMap: ABPFilterParser.elementTypeMaskMap
		}

		if (ABPFilterParser.matches(easylist, event.url, config)) {
			var url = toURL(event.url, topLevelUrl.protocol)
			if (!url) {
				return false
			}

			var parent = null
			var result = DisconnectMe.parentTracker(url)
			if (result != null) {
				parent = result.parent
			}

			handleDetection(event, parent, name)
			return true
		}

		return false
	}

	// private
	function easylistPrivacyMatch(event) {
		return checkEasylist(event, duckduckgoBlockerData.easylistPrivacy, "easylist-privacy")
	}

	// private
	function easylistMatch(event) {
		return checkEasylist(event, duckduckgoBlockerData.easylist, "easylist")
	}

	// private
	function getParentEntityUrl() {
		var parentEntity = DisconnectMe.parentTracker(topLevelUrl)
		if (parentEntity) {
			return new URL(topLevelUrl.protocol + parentEntity.parent)
		}
		return null
	}

	// public
	function install(document) {
		topLevelUrl = getTopLevelURL()
		parentEntityUrl = getParentEntityUrl()

		document.addEventListener("beforeload", function(event) {
			disconnectMeMatch(event) || easylistPrivacyMatch(event) || easylistMatch(event)
		}, true)
	}

	return { 
		install: install
	}
}()

duckduckgoContentBlocking.install(document)

