//
//  InitHelpers.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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
import BrowserServicesKit
@testable import Core
import Common

extension PrivacyPractices {
    
    public convenience init(termsOfServiceStore: TermsOfServiceStore) {
        self.init(tld: TLD(),
                  termsOfServiceStore: termsOfServiceStore,
                  entityMapping: EntityMapping())
    }
    
    public convenience init(entityMapping: EntityMapping) {
        self.init(tld: TLD(),
                  termsOfServiceStore: EmbeddedTermsOfServiceStore(),
                  entityMapping: entityMapping)
    }

    public convenience init(termsOfServiceStore: TermsOfServiceStore,
                            entityMapping: EntityMapping) {
        self.init(tld: TLD(),
                  termsOfServiceStore: termsOfServiceStore,
                  entityMapping: entityMapping)
    }

}

extension SiteRating {
    
    public convenience init(url: URL,
                            httpsForced: Bool = false,
                            entityMapping: EntityMapping = EntityMapping(),
                            privacyPractices: PrivacyPractices? = nil) {
        self.init(url: url,
                  httpsForced: httpsForced,
                  entityMapping: entityMapping,
                  privacyPractices: privacyPractices ?? PrivacyPractices(entityMapping: entityMapping))
    }
    
    public convenience init(url: URL,
                            httpsForced: Bool = false,
                            entityMapping: EntityMapping = EntityMapping()) {
        
        let privacyPractices = PrivacyPractices(entityMapping: entityMapping)
        
        self.init(url: url,
                  httpsForced: httpsForced,
                  entityMapping: entityMapping,
                  privacyPractices: privacyPractices)
    }
}

extension HTTPCookie {
    
    static func make(name: String = "name",
                     value: String = "value",
                     domain: String = "example.com",
                     path: String = "/",
                     policy: HTTPCookieStringPolicy? = nil) -> HTTPCookie {
        
        var properties: [HTTPCookiePropertyKey: Any] = [
            .name: name,
            .value: value,
            .domain: domain,
            .path: path
        ]
        
        if policy != nil {
            properties[HTTPCookiePropertyKey.sameSitePolicy] = policy
        }
        
        return HTTPCookie(properties: properties)!    }
    
}
