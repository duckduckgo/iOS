//
//  AutofillInterfaceUsernameTruncator.swift
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

import Foundation

struct AutofillInterfaceUsernameTruncator {
    static func truncateUsername(_ username: String, maxLength: Int) -> String {
        if username.count > maxLength {
            let ellipsis = "..."
            let minimumPrefixSize = 3

            let difference = username.count - maxLength + ellipsis.count
            var prefixCount = username.count - difference
            prefixCount = prefixCount < 0 ? minimumPrefixSize : prefixCount
            let prefix = username.prefix(prefixCount)

            return "\(prefix)\(ellipsis)"
        }

        return username
    }
}
