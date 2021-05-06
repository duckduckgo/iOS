//
//  NavigationActionPolicy.swift
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

public protocol NavigationActionPolicy {

    /// The completion handler must be called or else `webView:decidePolicyForNavigationAction:decisionHandler:` will not be called and will crash the app.
    func check(navigationAction: WKNavigationAction,
               completion: @escaping (WKNavigationActionPolicy, (() -> Void)?) -> Void)

}

public struct NavigationActionPolicyChecker {

    public static func checkAllPolicies(_ policies: [NavigationActionPolicy],
                                        forNavigationAction action: WKNavigationAction,
                                        _ completion: @escaping (WKNavigationActionPolicy, (() -> Void)?) -> Void) {

        guard let nextPolicy = policies.first else {
            completion(.allow, nil)
            return
        }

        nextPolicy.check(navigationAction: action) { result, cancellationAction in
            if result == .cancel {
                completion(result, cancellationAction)
            } else {
                Self.checkAllPolicies(Array(policies.dropFirst()), forNavigationAction: action, completion)
            }
        }
    }

}
