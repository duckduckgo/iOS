//
//  BookmarkletPolicy.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

import Foundation
import WebKit

public class BookmarkletPolicy: NavigationActionPolicy {

    private let evaluateJavaScript: (String) -> Void
    private let js: () -> String?

    public init(js: @autoclosure @escaping () -> String?, evaluateJavaScript: @escaping (String) -> Void) {
        self.js = js
        self.evaluateJavaScript = evaluateJavaScript
    }

    public func check(navigationAction: WKNavigationAction, completion: (WKNavigationActionPolicy, (() -> Void)?) -> Void) {
        guard let js = js() else {
            completion(.allow, nil)
            return
        }

        completion(.cancel) {
            self.evaluateJavaScript(js)
        }
    }

}
