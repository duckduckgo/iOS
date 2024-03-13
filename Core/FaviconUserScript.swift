//
//  FaviconUserScript.swift
//  Core
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

import WebKit
import UserScript

public protocol FaviconUserScriptDelegate: NSObjectProtocol {

    func faviconUserScript(_ script: FaviconUserScript, didRequestUpdateFaviconForHost host: String, withUrl url: URL?)

}

public class FaviconUserScript: NSObject, UserScript {

    public var source: String = """

(function() {

    function getFavicon() {
        return findFavicons()[0];
    };

    function findFavicons() {

         var selectors = [
            "link[rel~='icon']",
            "link[rel='apple-touch-icon']",
            "link[rel='apple-touch-icon-precomposed']"
        ];

        var favicons = [];
        while (selectors.length > 0) {
            var selector = selectors.pop()
            var icons = document.head.querySelectorAll(selector);
            for (var i = 0; i < icons.length; i++) {
                var href = icons[i].href;

                // Exclude SVGs since we can't handle them
                if (href.indexOf("svg") >= 0 || (icons[i].type && icons[i].type.indexOf("svg") >= 0)) {
                    continue;
                }

                favicons.push(href)
            }
        }
        return favicons;
    };

    try {
        var favicon = getFavicon();
        webkit.messageHandlers.faviconFound.postMessage(favicon);
    } catch(error) {
        // webkit might not be defined
    }

}) ();

"""

    public var injectionTime: WKUserScriptInjectionTime = .atDocumentEnd

    public var forMainFrameOnly: Bool = true

    public var messageNames: [String] = ["faviconFound"]

    public weak var delegate: FaviconUserScriptDelegate?

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        let url: URL?
        if let body = message.body as? String {
            url = URL(string: body)
        } else {
            url = nil
        }

        let host = message.messageHost
        delegate?.faviconUserScript(self, didRequestUpdateFaviconForHost: host, withUrl: url)
    }

}
