//
//  DocumentExtension.js
//  DuckDuckGo
//
//  Created by Mia Alexiou on 22/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

function getHrefFromPoint(x, y) {
    var element = document.elementFromPoint(x, y);
    while (element && !element.href) {
        element = element.parentNode
    }
    return getHrefFromElement(element)
}

function getHrefFromElement(element) {
    if (element) {
        return element.href
    }
    return null
}
