//
//  WebsiteAccountExtension.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import Common

extension SecureVaultModels.WebsiteAccount {

    func name(tld: TLD, autofillDomainNameUrlMatcher: AutofillDomainNameUrlMatcher) -> String {
        if let title = self.title, !title.isEmpty {
            return title
        } else {
            return autofillDomainNameUrlMatcher.normalizeUrlForWeb(domain)
        }
    }

    func faviconLetter(tld: TLD, autofillDomainNameUrlSort: AutofillDomainNameUrlSort) -> String? {
        return autofillDomainNameUrlSort.firstCharacterForGrouping(self, tld: tld)?.uppercased()
    }
}
