//
//  fullscreenvideo.js
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

// WKWebView doesn't define the fullscreenEnabled property, although it does support webkitEnterFullscreen.
// The workaround is to override fullscreenEnabled (if it isn't already defined), and add a custom implementation of the requestFullscreen function.
// The implementation calls through to webkitEnterFullscreen, which is defined on HTMLVideoElement.

(function() {
    let canEnterFullscreen = HTMLVideoElement.prototype.webkitEnterFullscreen !== undefined;
    let browserHasExistingFullScreenSupport = document.fullscreenEnabled || document.webkitFullscreenEnabled;

    // YouTube Mobile won't exit fullscreen correctly if requestFullscreen is overridden. Reference: https://github.com/brave/brave-ios/pull/2002
    let isMobile = /mobile/i.test(navigator.userAgent);

    if (!browserHasExistingFullScreenSupport && canEnterFullscreen && !isMobile) {
        Object.defineProperty(document, "fullscreenEnabled", {
            value: true
        });

        HTMLElement.prototype.requestFullscreen = function() {
            let video = this.querySelector("video");

            if (video) {
                video.webkitEnterFullscreen();
                return true;
            }

            return false;
        };
    }
})();
