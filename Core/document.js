//
//  document.js
//  DuckDuckGo
//
//  Created by Mia Alexiou on 22/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

var duckduckgoDocument = function () {
    
    getHrefFromPoint = function(x, y) {
        var element = document.elementFromPoint(x, y);
        while (element && !element.href) {
            element = element.parentNode
        }
        return getHrefFromElement(element)
    };
    
    getHrefFromElement = function(element) {
        if (element) {
            return element.href
        }
        return null
    };
    
    return {
        getHrefFromPoint: getHrefFromPoint,
        getHrefFromElement: getHrefFromElement
    };
    
}();
