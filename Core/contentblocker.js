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

	}

	// private
	function toURL(url) {
		try {
			return new URL(url)
		} catch(error) {
			return null
		}
	}

	// private
	function disconnectMeMatch(event) {
		var topLevelUrl = new URL(top.location.href)

		var eventUrl = event.url
		if (eventUrl.startsWith("//")) {
			console.log("fixing URL " + eventUrl)
			eventUrl = topLevelUrl.protocol + eventUrl
		}

		var url = toURL(eventUrl)
		if (!url) {
			console.log(eventUrl + " is not fully qualified")
			return
		}

		var parent = DisconnectMe.parentTracker(url, top.location.href)
		if (parent) {
			console.log("DisconnectMe matched " + eventUrl)
			handleDetection(event, parent, "disconnectme")
			return true
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

	var cache = {}

	// private
	function seenBefore(url) {
		return cache[hashCode(event.url)]
	}

	// private 
	function remember(url) {
		cache[hashCode(event.url)] = true
	}

	// public
	function install(document) {
		document.addEventListener("beforeload", function(event) {
			if (seenBefore(event.url)) {
				console.info("DuckDuckGo blocking again: " + event.url)
				return
			}

			console.log("DuckDuckGo checking " + event.url)

			if (disconnectMeMatch(event)) {
				remember(event.url)
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

