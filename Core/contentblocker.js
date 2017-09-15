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
	function handleDetection(event, parent, detectionMethod) {
		
		var blocked = true // TODO check whitelist

		webkit.messageHandlers.trackerDetectedMessage.postMessage({
			url: event.url,
			parentDomain: parent,
			blocked: blocked,
			method: detectionMethod
		});

		if (blocked) {
			console.info("DuckDuckGo is blocking: " + event.url)
			block(event)
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
	function block(event) {
		event.preventDefault();
		event.stopPropagation();
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

	var statuses = {}

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
	function isFirstPartyRequest(hostname1, hostname2) {
		// TODO discuss - only works for single item TLDs
	    hostname1 = hostname1.split('.').slice(-2).join('.')
    	hostname2 = hostname2.split('.').slice(-2).join('.')
    	return hostname1 == hostname2
	}

	// private
	function isDuckDuckGo(url) {
		return url.hostname.endsWith("duckduckgo.com")
	}

	// private
	function shouldSkip(event) {
		var topLevelUrl = getTopLevelURL()	
		var url = toURL(event.url, topLevelUrl.protocol)
		return url != null && (isDuckDuckGo(url) || isFirstPartyRequest(url.hostname, topLevelUrl.hostname))
	}

	// public
	function install(document) {
		document.addEventListener("beforeload", function(event) {
			var status = getStatus(event.url)
			if (status == "blocked") {
				console.info("DuckDuckGo blocking again: " + event.url)
				block(event)
				return
			} else if (status == "skipped") {
				console.log("DuckDuckGo is skipping " + event.url)				
				return;
			}

			console.log("DuckDuckGo checking " + event.url)

			if (shouldSkip(event)) {
				setStatus(event.url, "skipped")
				return
			}
		
			if (status = disconnectMeMatch(event)) {
				setStatus(event.url, status)
				return
			}

			// TODO other blockers here

		}, true)
		console.info("DuckDuckGo Content Blocker installed")
	}

	return { 
		install: install
	}
}()

duckduckgoContentBlocking.install(document)

