//
//  contentblockerrules.js
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

// "use strict";

(function() {

  let topLevelUrl = getTopLevelURL();
    
  let unprotectedDomain = `
        ${unprotectedDomains}
    `.split("\n").filter(domain => domain.trim() == topLevelUrl.host).length > 0;
    
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

  if (!window.__firefox__) {
      Object.defineProperty(window, "__firefox__", {
        enumerable: false,
        configurable: false,
        writable: false,
        value: {
        userScripts: {},
        includeOnce: function(userScript, initializer) {
            if (!__firefox__.userScripts[userScript]) {
                __firefox__.userScripts[userScript] = true;
                if (typeof initializer === 'function') {
                    initializer();
                }
                return false;
            }
            return true;
            }
        }
    });
  }

  if (webkit.messageHandlers.processRule) {
    install();
  }

  function install() {
    Object.defineProperty(window.__firefox__, "TrackingProtectionStats", {
      enumerable: false,
      configurable: false,
      writable: false,
      value: { enabled: false }
    });

    Object.defineProperty(window.__firefox__.TrackingProtectionStats, "setEnabled", {
      enumerable: false,
      configurable: false,
      writable: false,
      value: function(enabled, securityToken) {
        if (securityToken !== SECURITY_TOKEN) {
          return;
        }

        if (enabled === window.__firefox__.TrackingProtectionStats.enabled) {
          return;
        }

        window.__firefox__.TrackingProtectionStats.enabled = enabled;

        injectStatsTracking(enabled);
      }
    })

    function sendMessage(url, resourceType) {
      if (url) {
        const pageUrl = window.location.href
        webkit.messageHandlers.processRule.postMessage({ 
          url: url,
          resourceType: resourceType === undefined ? null : resourceType,
          blocked: !unprotectedDomain,
          pageUrl: pageUrl
        });
      }
    }

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

        sendMessage(event.url, type)
    }, false)


    function onLoadNativeCallback() {
      // Send back the sources of every script and image in the DOM back to the host application.
      [].slice.apply(document.scripts).forEach(function(el) { sendMessage(el.src, "script"); });
      [].slice.apply(document.images).forEach(function(el) {
        // If the image's natural width is zero, then it has not loaded so we
        // can assume that it may have been blocked.
        if (el.naturalWidth === 0) {
          sendMessage(el.src, "image");
        }
      });
    }

    let originalOpen = null;
    let originalSend = null;
    let originalImageSrc = null;
    let originalFetch = null;
    let mutationObserver = null;

    function injectStatsTracking(enabled) {
      // This enable/disable section is a change from the original Focus iOS version.
      if (enabled) {
        if (originalOpen) {
          return;
        }
        window.addEventListener("load", onLoadNativeCallback, false);
      } else {
        window.removeEventListener("load", onLoadNativeCallback, false);

        if (originalOpen) { // if one is set, then all the enable code has run
          XMLHttpRequest.prototype.open = originalOpen;
          XMLHttpRequest.prototype.send = originalSend;
          Image.prototype.src = originalImageSrc;
          mutationObserver.disconnect();

          originalOpen = originalSend = originalImageSrc = mutationObserver = null;
        }
        return;
      }

      // -------------------------------------------------
      // Send ajax requests URLs to the host application
      // -------------------------------------------------
      var xhrProto = XMLHttpRequest.prototype;
      if (!originalOpen) {
        originalOpen = xhrProto.open;
        originalSend = xhrProto.send;
      }

      xhrProto.open = function(method, url) {
        this._url = url;
        return originalOpen.apply(this, arguments);
      };

      xhrProto.send = function(body) {
        // Only attach the `error` event listener once for this
        // `XMLHttpRequest` instance.
        if (!this._tpErrorHandler) {
          // If this `XMLHttpRequest` instance fails to load, we
          // can assume it has been blocked.
          this._tpErrorHandler = function() {
            sendMessage(this._url);
          };
          this.addEventListener("error", this._tpErrorHandler);
        }
        return originalSend.apply(this, arguments);
      };

      // -------------------------------------------------
      // Detect when new sources get set on Image and send them to the host application
      // -------------------------------------------------
      if (!originalImageSrc) {
        originalImageSrc = Object.getOwnPropertyDescriptor(Image.prototype, "src");
      }
      
      delete Image.prototype.src;
      Object.defineProperty(Image.prototype, "src", {
        get: function() {
          return originalImageSrc.get.call(this);
        },
        set: function(value) {
          // Only attach the `error` event listener once for this
          // Image instance.
          if (!this._tpErrorHandler) {
            // If this `Image` instance fails to load, we can assume
            // it has been blocked.
            this._tpErrorHandler = function() {
              sendMessage(this.src, "image");
            };
            this.addEventListener("error", this._tpErrorHandler);
          }

          originalImageSrc.set.call(this, value);
        }
      });

      // -------------------------------------------------
      // Detect when fetch is called and pass the resource to the host application
      // -------------------------------------------------
      if (!originalFetch) {
        originalFetch = window.fetch;
      }
      window.fetch = function() {
        if (arguments.length === 0) {
          return originalFetch.apply(window, arguments);
        }

        if (typeof arguments[0] === 'string') {
          sendMessage(arguments[0], 'fetch');
        } else if (arguments[0].url) {
          // Argument is a Request object
          sendMessage(arguments[0].url, 'fetch');
        }

        return originalFetch.apply(window, arguments);
      }

      // -------------------------------------------------
      // Listen to when new <script> elements get added to the DOM
      // and send the source to the host application
      // -------------------------------------------------
      mutationObserver = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
          mutation.addedNodes.forEach(function(node) {
            // Only consider `<script src="*">` elements.
            if (node.tagName === "SCRIPT" && node.src) {
              // Send all scripts that are added, we won't add it to the stats unless script blocking is enabled anyways
              sendMessage(node.src, "script");
            } else if (node.tagName === "IMG" && node.src) {
              sendMessage(node.src, "image");
            }
          });
        });
      });

      mutationObserver.observe(document.documentElement, {
        childList: true,
        subtree: true
      });
    }

    // Default to on because there is a delay in being able to enable/disable
    // from native, and we don't want to miss events
    window.__firefox__.TrackingProtectionStats.enabled = true;
    injectStatsTracking(true);
  }

})();
