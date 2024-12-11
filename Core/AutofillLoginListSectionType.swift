//
//  AutofillLoginListSectionType.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

public enum AutofillLoginListSectionType: Comparable {

    case enableAutofill
    case suggestions(title: String, items: [AutofillLoginItem])
    case credentials(title: String, items: [AutofillLoginItem])

    public static func < (lhs: AutofillLoginListSectionType, rhs: AutofillLoginListSectionType) -> Bool {
        if case .credentials(let leftTitle, _) = lhs,
           case .credentials(let rightTitle, _) = rhs {
            if leftTitle == miscSectionHeading {
                return false
            } else if rightTitle == miscSectionHeading {
                return true
            }

            return leftTitle.localizedCaseInsensitiveCompare(rightTitle) == .orderedAscending
        }
        return true
    }

    public static let miscSectionHeading = "#"

}
