//
//  messaging.js
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

var duckduckgoMessaging = function() {

	function cache(name, value) {
		try {
			webkit.messageHandlers.cacheMessage.postMessage({
				name: name, 
				data: value
			});
		} catch(error) {
			// webkit might not be defined
		}
	}

	function trackerDetected(data) {
		try {
			webkit.messageHandlers.trackerDetectedMessage.postMessage(data);
		} catch(error) {
			// webkit might not be defined
		}
	}

	function log() {
		try {
			webkit.messageHandlers.log.postMessage(JSON.stringify(arguments));
		} catch(error) {
			// webkit might not be defined
		}
	}

	return {

		cache: cache,
		trackerDetected: trackerDetected,
		log: log
        
	}
}()
