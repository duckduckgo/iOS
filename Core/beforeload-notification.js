//
//  beforeload-notification.js
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

var duckduckgoBeforeLoadNotification = function() {

    function install(document) {
        document.addEventListener("beforeload", function(event) {
          var url = toFullURL(event.url)
          sendBeforeLoadMessage(url)
        }, true);
    }
    
    function sendBeforeLoadMessage(url) {
        try {
            webkit.messageHandlers.beforeLoadNotification.postMessage(url);
        } catch(error) {
            // webkit might not be defined
        }
    }
    
    function toFullURL(url) {
        try {
            return url.startsWith("//") ? document.location.protocol + url : url
        } catch(error) {
            return null
        }
    }
    
    return {
        install: install
    }
}()

duckduckgoBeforeLoadNotification.install(document)
