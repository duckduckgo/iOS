/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

// Adaptation of https://github.com/mozilla-mobile/firefox-ios/blob/master/Client/Assets/Favicons.js


var duckduckgoFavicon = function() {
    
     var selectors = {
        "link[rel~='icon']": 0,
        "link[rel='apple-touch-icon']": 1,
        "link[rel='apple-touch-icon-precomposed']": 2
    };
    
    var cachedFavicon = null;
    
    getFavicon = function() {
        if (!cachedFavicon) {
            cachedFavicon = findFavicons()[0]
        }
        return cachedFavicon
    };
    
    function findFavicons() {
        var favicons = [];
        for (var selector in selectors) {
            var icons = document.head.querySelectorAll(selector);
            for (var i = 0; i < icons.length; i++) {
                var href = icons[i].href;
                favicons.push(href)
            }
        }
        if (favicons.length === 0) {
            var href = document.location.origin + "/favicon.ico";
            favicons.push(href)
        }
        return favicons;
    };
    
    return {
        getFavicon: getFavicon
    };
    
}();
