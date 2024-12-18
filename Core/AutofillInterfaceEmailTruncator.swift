//
//  AutofillInterfaceEmailTruncator.swift
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

public struct AutofillInterfaceEmailTruncator {
    public static func truncateEmail(_ email: String, maxLength: Int) -> String {
        let emailComponents = email.components(separatedBy: "@")
        if emailComponents.count > 1 && email.count > maxLength {
            let ellipsis = "..."
            let minimumPrefixSize = 3
            
            let difference = email.count - maxLength + ellipsis.count
            if let username = emailComponents.first,
               let domain = emailComponents.last {
                
                var prefixCount = username.count - difference
                prefixCount = prefixCount < 0 ? minimumPrefixSize : prefixCount
                let prefix = username.prefix(prefixCount)
                
                return "\(prefix)\(ellipsis)@\(domain)"
            }
        }
        
        return email
    }
}
