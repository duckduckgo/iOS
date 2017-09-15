//
//  disconnectme.js
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

var DisconnectMe = function() {

	// private
	function isCurrentDomain(parentDomain, currentDomain) {

		if (parentDomain == currentDomain) {
			return true
		}

		if (currentDomain.endsWith("." + parentDomain)) {
			return true
		}

		return false
	}

	// public
	function parentTracker(urlToCheck, topLevelUrl) {
		var domainToCheck = urlToCheck.hostname
		var currentDomain = topLevelUrl.hostname		

		var domainNameParts = domainToCheck.split(".")
		var max = domainNameParts.length;

		for (var i = max - 2; i >= 0; i--) {
			var hostname = domainNameParts.slice(i, max).join(".");
			var parent = duckduckgoBlockerData.disconnectme[hostname]

			if (parent) {
				console.log("DisconnectMe matched " + domainToCheck + " with " + parent)
 				if (isCurrentDomain(parent, currentDomain)) {
					console.log("DisconnectMe skipping " + domainToCheck + " as " + parent + " matches " + currentDomain)
 					return false
 				}
				return parent
			}		
		}

		return null
	}

	return {
		parentTracker: parentTracker
	}
}()
