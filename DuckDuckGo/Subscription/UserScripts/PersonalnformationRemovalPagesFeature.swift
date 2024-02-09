//
//  identityTheftRestorationPagesFeature.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

#if SUBSCRIPTION
import BrowserServicesKit
import Common
import Foundation
import WebKit
import UserScript
import Combine

@available(iOS 15.0, *)
final class PersonalInformationRemovalPagesFeature: Subfeature, ObservableObject {
    
    struct Constants {
        static let featureName = "useIdentityTheftRestoration"
        static let os = "ios"
        static let empty = ""
    }
    
    struct OriginDomains {
        static let duckduckgo = "duckduckgo.com"
        static let abrown = "abrown.duckduckgo.com"
    }
    
    struct Handlers {
        static let getAccessToken = "getAccessToken"
    }
        
    
    var broker: UserScriptMessageBroker?
    var featureName: String = Constants.featureName

    var messageOriginPolicy: MessageOriginPolicy = .only(rules: [
        .exact(hostname: OriginDomains.duckduckgo),
        .exact(hostname: OriginDomains.abrown)
    ])
    
    var originalMessage: WKScriptMessage?

    func with(broker: UserScriptMessageBroker) {
        self.broker = broker
    }

    func handler(forMethodNamed methodName: String) -> Subfeature.Handler? {
        switch methodName {
        case Handlers.getAccessToken: return getAccessToken
        default:
            return nil
        }
    }

    func getAccessToken(params: Any, original: WKScriptMessage) async throws -> Encodable? {
        let authToken = AccountManager().authToken ?? Constants.empty
        return Subscription(token: authToken)
    }

}
#endif
