//
//  PolicyBucket.swift
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

protocol NavigationActionPolicy {

    func check(navigationAction: WKNavigationAction,
               completion: (WKNavigationActionPolicy, (() -> Void)?) -> Void)
    
}

class PolicyBucket {

    var policies = [NavigationActionPolicy]()

    func add(_ policy: NavigationActionPolicy) {
        policies.append(policy)
    }

    func checkPoliciesFor(navigationAction: WKNavigationAction,
                          _ completion: (WKNavigationActionPolicy, (() -> Void)?) -> Void) {

        // If we run out of policies, assume we're good to allow the navigation
        if policies.isEmpty {
            completion(.allow, nil)
            return
        }

        let policy = policies.remove(at: 0)
        policy.check(navigationAction: navigationAction) { policy, action in
            if policy == .cancel {
                completion(policy, action)
                return
            }
            self.checkPoliciesFor(navigationAction: navigationAction, completion)
        }

    }

}
