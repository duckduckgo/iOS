//
//  NewTabPagePreferencesStorage.swift
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

enum NewTabPageSection: String, Codable {
    case favorites
    case shortcuts
}

protocol NewTabPageSectionsPreferencesStorage {
    var sectionsOrder: [NewTabPageSection] { get }

    func isEnabled(_ section: NewTabPageSection) -> Bool
    func setSection(_ section: NewTabPageSection, enabled: Bool)

    func moveSections(_ fromOffsets: IndexSet, toOffset: Int)
}

final class InMemoryNewTabPageSectionsPreferencesStorage: NewTabPageSectionsPreferencesStorage {
    private(set) var sectionsOrder: [NewTabPageSection] = [.favorites, .shortcuts]
    private var enabledSections: Set<NewTabPageSection> = [.favorites, .shortcuts]

    func isEnabled(_ section: NewTabPageSection) -> Bool {
        enabledSections.contains(section)
    }

    func setSection(_ section: NewTabPageSection, enabled: Bool) {
        if enabled {
            enabledSections.insert(section)
        } else {
            enabledSections.remove(section)
        }
    }

    func moveSections(_ fromOffsets: IndexSet, toOffset: Int) {
        sectionsOrder.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }
}
