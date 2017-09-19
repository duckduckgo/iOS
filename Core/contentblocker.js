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

	// private	
	var statuses = {}

	// private
	function handleDetection(event, parent, detectionMethod) {
		var blocked = block(event)

		try {
			webkit.messageHandlers.trackerDetectedMessage.postMessage({
				url: event.url,
				parentDomain: parent,
				blocked: blocked,
				method: detectionMethod
			});
		} catch(error) {
			// ShareExtension has no message handles, so webkit variable never gets declared
			console.log(error + " while messaging to app")
		}

		return blocked ? "blocked" : "skipped"
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
		return new URL(top.location.href)
	}

	// private
	function disconnectMeMatch(event) {
		var topLevelUrl = getTopLevelURL()
		var url = toURL(event.url, topLevelUrl.protocol)
		if (!url) {
			return
		}

		var parent = DisconnectMe.parentTracker(url, topLevelUrl)
		if (parent) {
			return handleDetection(event, parent, "disconnectme")
		}		
	}

	// private
	function currentDomainIsWhitelisted() {
		if (!duckduckgoBlockerData.whitelist[getTopLevelURL().host]) {
			return false
		}

		return true
	}

	// private
	function block(event) {
		if (currentDomainIsWhitelisted()) {
			console.warn("DuckDuckGo blocking is disabled for this domain")
			setStatus(event.url, "skipped")
			return false
		}

		if (isFirstParty(event)) {
			setStatus(event.url, "skipped")
			return false
		}

		console.info("DuckDuckGo is blocking: " + event.url)
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
	function setStatus(url, status) {
		console.log(status + " : " + url)	
		statuses[hashCode(event.url)] = status
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
	function isFirstParty(event) {
		var topLevelUrl = getTopLevelURL()	
		var url = toURL(event.url, topLevelUrl.protocol)
		if (url != null && domainsMatch(url, topLevelUrl)) {
			console.log("skipping, is first party")
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
			return handleDetection(event, null, name)
		}

		return null		
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
	function alreadyChecked(event) {
		var status = getStatus(event.url)
		if (status == "blocked") {
			console.info("DuckDuckGo blocking again: " + event.url)
			block(event)
			return true
		} else if (status == "skipped") {
			console.log("DuckDuckGo is skipping " + event.url)				
			return true
		}		
		return false
	}

	// public
	function install(document) {
		document.addEventListener("beforeload", function(event) {
			if (alreadyChecked(event)) {
				return
			}

			console.log("DuckDuckGo checking " + event.url)

			if (status = disconnectMeMatch(event)) {
				setStatus(event.url, status)
				return
			}

			if (status = easylistPrivacyMatch(event)) {
				setStatus(event.url, status)
				return
			}

			if (status = easylistMatch(event)) {
				setStatus(event.url, status)
				return
			}

		}, true)
		console.info("DuckDuckGo Content Blocker installed")
	}

	return { 
		install: install
	}
}()

duckduckgoContentBlocking.install(document)

