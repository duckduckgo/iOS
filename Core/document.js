//
//  document.js
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

(function() {
    if (!window.__ddg__) {
        Object.defineProperty(window, "__ddg__", {
            enumerable: false,
            configurable: false,
            writable: false
        });
    }
    
    var getHrefFromPoint = function(x, y) {
        var element = document.elementFromPoint(x, y);
        while (element && !element.href) {
            element = element.parentNode
        }
        
        if (element) {
            return element.href;
        }
        
        return null;
    };
    
    Object.defineProperty(window.__ddg__, "getHrefFromPoint", {
        enumerable: false,
        configurable: false,
        writable: false,
        value: getHrefFromPoint
    })
    
})();
