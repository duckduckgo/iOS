//
//  detection.js
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

(function() {

    duckduckgoMessaging.log("installing beforeload detection")

    document.addEventListener("beforeload", function(event) {

        if (event.target.nodeName == "LINK") {
            type = event.target.rel
        } else if (event.target.nodeName == "IMG") {
            type = "image"
        } else if (event.target.nodeName == "IFRAME") {
            type = "subdocument"
        } else {
            type = event.target.nodeName
        }

        duckduckgoContentBlocking.shouldBlock(event.url, type, function(url, block) {
            if (!block) { return }

            duckduckgoMessaging.log("blocking beforeload")
            if (duckduckgoContentBlocking.loadSurrogate(event.url)) {                
                duckduckgoMessaging.log("surrogate loaded for " + event.url)
            }
            event.preventDefault()
            event.stopPropagation()
        })
    }, true)


    try {
        duckduckgoMessaging.log("installing image src detection")

        var originalImageSrc = Object.getOwnPropertyDescriptor(Image.prototype, 'src')
        delete Image.prototype.src;
        Object.defineProperty(Image.prototype, 'src', {
            get: function() {
                return originalImageSrc.get.call(this)
            },
            set: function(value) {

                var instance = this
                duckduckgoContentBlocking.shouldBlock(value, "image", function(url, block) {
                    if (block) {
                        duckduckgoMessaging.log("blocking image src: " + url)
                    } else {
                        originalImageSrc.set.call(instance, value);
                        duckduckgoMessaging.log("allowing image src: " + url)
                    }
                })
                
            }
        })

    } catch(error) {
        duckduckgoMessaging.log("failed to install image src detection")
    }

    try {
        duckduckgoMessaging.log("installing xhr detection")

        var xhr = XMLHttpRequest.prototype
        var originalOpen = xhr.open

        xhr.open = function(method, url) {
            var trackerUrl = null
            duckduckgoContentBlocking.shouldBlock(url, "xmlhttprequest", function(url, block) {                                                  
                trackerUrl = block ? "about:blank" : url 
            })
            duckduckgoMessaging.log("sending xhr " + url + " to " + trackerUrl)
            return originalOpen.apply(this, [method, trackerUrl]);
        }

    } catch(error) {
        duckduckgoMessaging.log("failed to install xhr detection")
    }
 
}) ()
